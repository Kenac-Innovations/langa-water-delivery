package zw.co.kenac.takeu.backend.walletmodule.service.impl;

import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.domain.PageRequest;
import org.springframework.scheduling.annotation.Async;
import org.springframework.security.access.method.P;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import zw.co.kenac.takeu.backend.constant.AppConstant;
import zw.co.kenac.takeu.backend.exception.custom.CurrencyNotFound;
import zw.co.kenac.takeu.backend.exception.custom.ResourceNotFoundException;
import zw.co.kenac.takeu.backend.model.DeliveryEntity;
import zw.co.kenac.takeu.backend.model.enumeration.*;
import zw.co.kenac.takeu.backend.repository.DeliveryRepository;
import zw.co.kenac.takeu.backend.service.internal.CommissionService;
import zw.co.kenac.takeu.backend.walletmodule.dto.*;
import zw.co.kenac.takeu.backend.walletmodule.models.*;
import zw.co.kenac.takeu.backend.walletmodule.repo.*;
import zw.co.kenac.takeu.backend.walletmodule.service.TransactionService;
import zw.co.kenac.takeu.backend.walletmodule.service.WalletAccountService;
import zw.co.kenac.takeu.backend.walletmodule.service.WalletBalanceService;
import zw.co.kenac.takeu.backend.walletmodule.utils.JsonUtil;
import zw.co.paynow.core.Payment;
import zw.co.paynow.core.Paynow;
import zw.co.paynow.responses.MobileInitResponse;
import zw.co.paynow.responses.StatusResponse;
import zw.co.paynow.responses.WebInitResponse;
import zw.co.paynow.constants.MobileMoneyMethod;
import zw.co.kenac.takeu.backend.service.internal.FirebaseService;
import zw.co.kenac.takeu.backend.dto.PaginatedResponse;
import zw.co.kenac.takeu.backend.dto.CustomPagination;
import org.springframework.context.ApplicationEventPublisher;
import zw.co.kenac.takeu.backend.event.StartPollingEvent;

import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;
import java.util.UUID;
import java.util.concurrent.ThreadLocalRandom;
import java.util.stream.Collectors;

/**
 * Created by DylanDzvene
 * Email: dyland@kenac.co.zw
 * Created on: 4/25/2025
 */


@Service
@RequiredArgsConstructor
@Transactional
@Slf4j
public class TransactionServiceImpl implements TransactionService {
    private final TransactionRepo transactionRepo;
    private final WalletAccountRepo walletAccountRepo;
    private final WalletBalanceRepo walletBalanceRepo;
    private final WalletBalanceService walletBalanceService;
    private final WalletAccountService walletAccountService;
    private final SubTransactionRepo subTransactionRepo;
    private final CurrenciesRepo currenciesRepo;
    private final CommissionService commissionService;
    private final DeliveryRepository deliveryRepository;
    @Value("${paynow.integration-key}")
    private String integrationKey;
    @Value("${paynow.integration-id}")
    private String integrationId;
    @Value("${paynow.callbackUrl}")
    private String callBackUrl;
    @Value("${paynow.returnUrl}")
    private String returnUrl;
    private final FirebaseService firebaseService;
    private final ApplicationEventPublisher eventPublisher;



    @Override
    @Transactional
    public Transaction processCashPayment(ProcessPaymentResponseDTO paymentResponseDTO) {
        Transaction transaction = transactionRepo.findById(paymentResponseDTO.getTxnId()).orElseThrow(() -> new ResourceNotFoundException("Transaction not found with ID::" + paymentResponseDTO.getTxnId()));
        if (!transaction.getStatus().equals(TransactionStatus.PENDING)) {// already processed transaction
            return transaction;
        }
        if (!paymentResponseDTO.getStatus().equals(TransactionStatus.COMPLETED)) {
            transaction.setStatus(paymentResponseDTO.getStatus());// todo , also update the delivery status
            return transactionRepo.save(transaction);
        }


        if (!transaction.getPaymentMethod().equals(PaymentMethod.E_MONEY)) {
            return null; //todo throw an error here
        }
        transaction.setStatus(paymentResponseDTO.getStatus());
        // create debit System Suspense
        SubTransaction subTransactionDriver = SubTransaction.builder()
                .currencies(transaction.getCurrencies())
                .amount(transaction.getCommissionAmount())
                .type(TransactionEntryType.DEBIT)
                .currencies(transaction.getCurrencies())
                .transaction(transaction)
                .walletAccount(transaction.getSourceWallet())
                .paymentMethod(PaymentMethod.E_MONEY)// chero iri cash based TXN our charges are Emoney based hence they have to reflect that
                .reference(UUID.randomUUID().toString())
                .build();

        SubTransaction subTransactionCharge = SubTransaction.builder()
                .currencies(transaction.getCurrencies())
                .amount(transaction.getCommissionAmount())
                .type(TransactionEntryType.CREDIT)
                .transaction(transaction)
                .currencies(transaction.getCurrencies())

                .walletAccount(transaction.getCommissionWallet())
                .paymentMethod(PaymentMethod.E_MONEY)
                .reference(UUID.randomUUID().toString())
                .build();

        List<SubTransaction> subTransactionList = subTransactionRepo.saveAll(List.of(subTransactionDriver, subTransactionCharge));

        if (subTransactionList.isEmpty() || subTransactionList.size() != List.of(subTransactionDriver, subTransactionCharge).size()) {
            log.error("==========> Error in saving sub transactions");
            throw new RuntimeException("Error in saving sub transactions");
        }
        // tiri safe apa
        // time to process balance changes
        List<WalletBalance> walletBalanceList = walletBalanceService.processBalanceChanges(subTransactionList);


        return transactionRepo.save(transaction);
    }

    @Override
    public Transaction processEMoneyPayment(ProcessPaymentResponseDTO paymentResponseDTO) {// TODO MAKE SURE TO MAKE THIS ASYNC
        Transaction transaction = transactionRepo.findById(paymentResponseDTO.getTxnId()).orElseThrow(() -> new ResourceNotFoundException("Transaction not found with ID::" + paymentResponseDTO.getTxnId()));
        if (!transaction.getStatus().equals(TransactionStatus.PENDING)) {// already processed transaction
            return transaction;
        }
        if (!paymentResponseDTO.getStatus().equals(TransactionStatus.COMPLETED)) {
            transaction.setStatus(paymentResponseDTO.getStatus());// todo notify the user about the failed transaction
            return transactionRepo.save(transaction);
        }


//        if (!transaction.getPaymentMethod().equals(PaymentMethod.E_MONEY)) {
//            return null; //todo throw an error here
//        }
        transaction.setStatus(paymentResponseDTO.getStatus());
//        // create debit System Suspense
//        SubTransaction subTransactionSuspense = SubTransaction.builder()
//                .currencies(transaction.getCurrencies())
//                .amount(transaction.getPrincipalAmount().subtract(transaction.getCommissionAmount()))
//                .type(TransactionEntryType.DEBIT)
//                .currencies(transaction.getCurrencies())
//                .transaction(transaction)
//                .walletAccount(transaction.getSourceWallet())
//                .paymentMethod(transaction.getPaymentMethod())
//                .reference(UUID.randomUUID().toString())
//                .build();

        SubTransaction subTransactionDriver = SubTransaction.builder()
                .currencies(transaction.getCurrencies())
               // .amount(transaction.getPrincipalAmount().subtract(transaction.getCommissionAmount()))
                .amount(transaction.getCommissionAmount())// only removing the charge
                .type(TransactionEntryType.DEBIT)
                .transaction(transaction)
                .currencies(transaction.getCurrencies())
                .walletAccount(transaction.getDestinationWallet())
                .paymentMethod(transaction.getPaymentMethod())
                .reference(UUID.randomUUID().toString())
                .build();
//        SubTransaction subTransactionCharge = SubTransaction.builder()
//                .currencies(transaction.getCurrencies())
//                .amount(transaction.getCommissionAmount())
//                .type(TransactionEntryType.CREDIT)
//                .transaction(transaction)
//                .currencies(transaction.getCurrencies())
//
//                .walletAccount(transaction.getCommissionWallet())
//                .paymentMethod(transaction.getPaymentMethod())
//                .reference(UUID.randomUUID().toString())
//                .build();

        List<SubTransaction> subTransactionList = subTransactionRepo.saveAll(List.of(subTransactionDriver));

        if (subTransactionList.isEmpty() || subTransactionList.size() != List.of(subTransactionDriver).size()) {
            log.error("==========> Error in saving sub transactions");
            throw new RuntimeException("Error in saving sub transactions");
        }
        // tiri safe apa
        // time to process balance changes
        List<WalletBalance> walletBalanceList = walletBalanceService.processBalanceChanges(subTransactionList);


        return transactionRepo.save(transaction);
    }

    @Override
    public TransactionDto createTransaction(CreateTxnDTO createTxnDTO) {
        // todo first check if the driver is individual or under organization

//        // here we use the wallet Id 1 for default
//        if (createTxnDTO.getPaymentMethod().equals(PaymentMethod.E_MONEY)) {
//            return createEMoneyMasterTxn(createTxnDTO);
//        } else {
//            // means cash payment
//            return createCashMasterTxn(createTxnDTO);
//        }
        return createEMoneyMasterTxn(createTxnDTO);

    }

    public TransactionDto createEMoneyMasterTxn(CreateTxnDTO createTxnDTO) {

        Currencies currency = currenciesRepo.findById(createTxnDTO.getCurrencyId()).orElseThrow(() -> new CurrencyNotFound("Currency not Found with ID :" + createTxnDTO.getCurrencyId()));
        // source account will be System suspense;
        WalletAccount walletAccountSource = walletAccountService.getSystemWallet(WalletAccountType.SYSTEM_MAIN_SUSPENSE);
        WalletAccount walletAccountDestination;
        // destination wallet will be driver wallet kana Org Wallet
        if (createTxnDTO.getDriverId() == 0) {// simulating Organisational Driver
            walletAccountDestination = walletAccountService.getWalletAccountByOrganisationId(1L); //todo to get the actual orginatision ID and put it here
        } else {
            walletAccountDestination = walletAccountService.getWalletAccountByDriverId(createTxnDTO.getDriverId());
        }


        // source account will be System suspense;
        WalletAccount chargeWallet = walletAccountService.getSystemWallet(WalletAccountType.SYSTEM_CHARGE_SUSPENSE);

        // Calculate commission or use the provided calculated commission
        BigDecimal commissionAmount;
        if (createTxnDTO.getCalculatedCommission() != null) {
            commissionAmount = createTxnDTO.getCalculatedCommission();
            log.info("Using provided commission amount: {}", commissionAmount);
        } else {
            commissionAmount = calculateCommission(createTxnDTO.getPrincipal());
            log.info("Calculated commission amount: {}", commissionAmount);
        }
        log.info("======> Using provided commission amount: {}", JsonUtil.toJson(createTxnDTO));
        DeliveryEntity deliveryEntity = deliveryRepository.findById(createTxnDTO.getDeliveryId()).orElse(null);

        Transaction transaction = Transaction.builder()
                .driverId(createTxnDTO.getDriverId())
                .clientId(createTxnDTO.getClientId())
                .commissionAmount(commissionAmount)
                .principalAmount(createTxnDTO.getPrincipal())
                .currencies(currency)
                .narration(AppConstant.DELIVERY_REQUEST)
                .commissionWallet(chargeWallet)
                .delivery(deliveryEntity)// todo to be linked to actual entity
                .sourceWallet(walletAccountSource)
                .destinationWallet(walletAccountDestination)
                .status(TransactionStatus.PENDING)
                .paymentMethod(createTxnDTO.getPaymentMethod())
                .reference(UUID.randomUUID().toString())
                .type(TransactionType.COMMISSION)
                .build();

        Transaction transactionResponse = transactionRepo.save(transaction);


        // todo call the payment Gateway and return the payment
        // transactionDto.setPaymentLink("Dylan is the best ");// todo to be replaced


        return convertToDTO(transactionResponse);
    }

    public TransactionDto createCashMasterTxn(CreateTxnDTO createTxnDTO) {
        Currencies currency = currenciesRepo.findById(createTxnDTO.getCurrencyId()).orElseThrow(() -> new CurrencyNotFound("Currency not Found with ID :" + createTxnDTO.getCurrencyId()));
        // the source will be driver wallet this is the source of the charge and the destination we put it in the charge

        WalletAccount walletAccountSource;

        if (createTxnDTO.getDriverId() == 2) {// simulating Organisational Driver
            walletAccountSource = walletAccountService.getWalletAccountByOrganisationId(1L); //todo to get the actual orginatision ID and put it here
        } else {
            walletAccountSource = walletAccountService.getWalletAccountByDriverId(createTxnDTO.getDriverId());
        }


        // source account will be System suspense;
        WalletAccount chargeWallet = walletAccountService.getSystemWallet(WalletAccountType.SYSTEM_CHARGE_SUSPENSE);

        // Calculate commission or use the provided calculated commission
        BigDecimal commissionAmount;
        if (createTxnDTO.getCalculatedCommission() != null) {
            commissionAmount = createTxnDTO.getCalculatedCommission();
            log.info("Using provided commission amount: {}", commissionAmount);
        } else {
            commissionAmount = calculateCommission(createTxnDTO.getPrincipal());
            log.info("Calculated commission amount: {}", commissionAmount);
        }
        DeliveryEntity deliveryEntity = deliveryRepository.findById(createTxnDTO.getDeliveryId()).orElse(null);

        Transaction transaction = Transaction.builder()
                .driverId(createTxnDTO.getDriverId())
                .clientId(createTxnDTO.getClientId())
                .commissionAmount(commissionAmount)
                .principalAmount(createTxnDTO.getPrincipal())
                .currencies(currency)
                .narration(AppConstant.DELIVERY_REQUEST)
                .commissionWallet(chargeWallet)
                .delivery(deliveryEntity)// todo to be linked to actual entity
                .sourceWallet(walletAccountSource)
                .destinationWallet(null)
                .status(TransactionStatus.PENDING)
                .paymentMethod(createTxnDTO.getPaymentMethod())
                .reference(UUID.randomUUID().toString())
                .type(TransactionType.PAYMENT)
                .build();

        Transaction transactionResponse = transactionRepo.save(transaction);

        // todo call the payment Gateway and return the payment
        TransactionDto transactionDto = convertToDTO(transactionResponse);
        transactionDto.setPaymentLink("Dylan is the best ");// todo to be replaced


        return transactionDto;
    }


    public Transaction createOrganizationalDriverCashTxn() {
        return null;
    }

    @Override
    @Transactional
    public Transaction transferFunds(TransactionDto transactionDto) {

        return null;
    }

    @Override
    public Page<TransactionDto> getTransactionsByWalletId(Long walletId, Pageable pageable, TransactionStatus status) {
        WalletAccount wallet = walletAccountRepo.findById(walletId)
                .orElseThrow(() -> new ResourceNotFoundException("Wallet not found with Id: " + walletId));

        Page<Transaction> transactions;
        if (status != null) {
            transactions = transactionRepo.findBySourceWalletOrDestinationWalletAndStatusOrderByDateCreatedDesc(
                    wallet, wallet, status, pageable);
        } else {
            transactions = transactionRepo.findBySourceWalletOrDestinationWalletOrderByDateCreatedDesc(
                    wallet, wallet, pageable);
        }

        return transactions.map(this::convertToDTO);
    }

    @Override
    public PaginatedResponse<TransactionDto> getTransactionsByDriverId(Long driverId, int pageNumber, int pageSize, TransactionStatus status) {
        log.info("Getting transactions for driver: {} with status: {}", driverId, status);
        PageRequest pageRequest = PageRequest.of(pageNumber - 1, pageSize);
        Page<Transaction> transactions;
        
        if (status != null) {
            transactions = transactionRepo.findByDriverIdAndStatusOrderByDateCreatedDesc(driverId, status, pageRequest);
        } else {
            transactions = transactionRepo.findByDriverIdOrderByDateCreatedDesc(driverId, pageRequest);
        }
        
        List<TransactionDto> transactionDtos = transactions.getContent().stream()
                .map(this::convertToDTO)
                .collect(Collectors.toList());
        
        return new PaginatedResponse<>(
            transactionDtos,
            new CustomPagination(
                transactions.getTotalElements(),
                transactions.getTotalPages(),
                transactions.getNumber() + 1,
                transactions.getSize()
            )
        );
    }

    @Override
    public List<Transaction> getTransactionsByOrganizationId(Long organizationId) {
        return transactionRepo.findByOrganizationIdOrderByDateCreatedDesc(organizationId);
    }

    @Override
    public Transaction getTransactionById(String id) {
        return transactionRepo.findById(id)
                .orElseThrow(() -> new ResourceNotFoundException("Transaction not found with Id: " + id));
    }

    private WalletAccount getSystemWallet(WalletAccountType type) {
        return walletAccountRepo.findByOwnerTypeAndType(WalletOwnerType.TAKEU_SYSTEM, type)
                .orElseThrow(() -> new ResourceNotFoundException("System " + type + " wallet not found"));
    }

    private WalletAccount getDriverWallet(Long driverId, WalletAccountType type) {
        return walletAccountRepo.findByOwnerIdAndOwnerTypeAndType(driverId, WalletOwnerType.DRIVER, type)
                .orElseThrow(() -> new ResourceNotFoundException("Driver " + type + " wallet not found for driver: " + driverId));
    }

    private WalletAccount getOrganizationWallet(Long orgId, WalletAccountType type) {
        return walletAccountRepo.findByOwnerIdAndOwnerTypeAndType(orgId, WalletOwnerType.ORGANIZATION, type)
                .orElseThrow(() -> new ResourceNotFoundException("Organization " + type + " wallet not found for org: " + orgId));
    }

    private void updateWalletBalance(WalletAccount wallet, BigDecimal amount, Transaction transaction) {
        // Get current balance
        BigDecimal currentBalance = walletAccountService.getCurrentBalance(wallet.getId());
        BigDecimal newBalance = currentBalance.add(amount);

        // Create new balance record
        WalletBalance walletBalance = WalletBalance.builder()
                .wallet(wallet)
                .amount(amount)
                .runningBalance(newBalance)
                .transactionRef(transaction.getReference())
                .transaction(null)
                .build();

        walletBalanceRepo.save(walletBalance);
    }

    private BigDecimal calculateCommission(BigDecimal amount) {
        // Use the CommissionService to calculate commission based on active commission rate
        try {
            return commissionService.calculateCommissionForAmount(amount);
        } catch (Exception e) {
            log.error("Error calculating commission: {}", e.getMessage());
            // Fall back to default calculation if commission service fails
            return amount.multiply(BigDecimal.valueOf(0.1));
        }
    }

    private String generateReference() {
        return "TXN" + System.currentTimeMillis() + ThreadLocalRandom.current().nextInt(1000, 9999);
    }

    private TransactionDto convertToDTO(Transaction t) {
        return TransactionDto.builder()
                .id(t.getId())
                .clientId(t.getClientId())
                .paymentLink(null)
                .status(t.getStatus().isSuccessful()?TransactionStatus.COMPLETED:t.getStatus())
                .destinationWalletNumber(t.getDestinationWallet() != null ? t.getDestinationWallet().getId() : null)
                .commissionWalletNumber(t.getCommissionWallet() != null ? t.getCommissionWallet().getId() : null)
                .driverId(t.getDriverId())
                .narration(t.getNarration())
                .pollUrl(t.getPollUrl())
                .organizationId(t.getOrganizationId())
                .principalAmount(t.getPrincipalAmount())
                .commissionAmount(t.getCommissionAmount())
                .paymentMethod(t.getPaymentMethod())
                .reference(t.getReference())
                .sourceWalletNumber(t.getSourceWallet() != null ? t.getSourceWallet().getId() : null)
                .type(t.getType())
                .createdDate(t.getDateCreated())
                .build();
    }

    @Override
    @Transactional
    public TransactionDto depositToDriverWallet(DriverDepositRequestDTO request) {
        Currencies currency = currenciesRepo.findById(request.getCurrencyId())
                .orElseThrow(() -> new CurrencyNotFound("Currency not found with ID: " + request));
        WalletAccount driverWallet = walletAccountService.getWalletAccountByDriverId(request.getDriverId());
        WalletAccount systemWallet = walletAccountService.getSystemWallet(WalletAccountType.SYSTEM_MAIN_SUSPENSE);
        Transaction transaction = Transaction.builder()
                .type(TransactionType.DEPOSIT)
                .status(TransactionStatus.PENDING)
                .currencies(currency)
                .principalAmount(request.getAmount())
                .commissionAmount(BigDecimal.ZERO) // No commission for deposits
                .paymentMethod(request.getPaymentMethod())
                .sourceWallet(systemWallet)
                .destinationWallet(driverWallet)
                .driverId(request.getDriverId())
                .dateCreated(LocalDateTime.now())
                .clientId(0L) // System operation, no client involved
                .reference(UUID.randomUUID().toString())
                .narration("Driver wallet deposit")
                .build();

        Transaction transactionResponse = transactionRepo.save(transaction);
        List<PaymentItem> paymentItems = new ArrayList<>();
        paymentItems.add(PaymentItem.builder()
                .amount(request.getAmount())
                .description(transaction.getNarration())
                .name("Wallet Top-up").build());
        Payment payment = createPaynowPayment(
                transaction.getId(),
                paymentItems
        );
        TransactionDto transactionDto = convertToDTO(transactionResponse);
        if (request.getPaymentMethod().equals(PaymentMethod.VISA)){
            WebInitResponse response = initiateWebPayment(
                    payment
            );
            transactionDto.setPaymentLink(response.getRedirectURL());
            transactionDto.setPollUrl(response.getPollUrl());
            transaction.setPollUrl(response.getPollUrl());
        }else if (request.getPaymentMethod().equals(PaymentMethod.ECOCASH)) {
            // LEA
            MobileInitResponse response = initiateMobilePayment(payment,request.getPhoneNumber(),"");
            transactionDto.setPollUrl(response.getPollUrl());
            transaction.setPollUrl(response.getPollUrl());
        }


        transactionRepo.save(transaction);

        return transactionDto;
    }

    @Override
    public Transaction processWalletDepositPayment(ProcessPaymentResponseDTO paymentResponseDTO) {// todo incoming request to be pushed into a queue  for fault tolerant
        Transaction transaction = transactionRepo.findById(paymentResponseDTO.getTxnId())
                .orElseThrow(() -> new ResourceNotFoundException("Transaction not found with ID::" + paymentResponseDTO.getTxnId()));


        if (!transaction.getStatus().equals(TransactionStatus.PENDING)) {
            return transaction; // Already processed transaction
        }
        // If status is not PAID OR DELIVERED OR AWAITING_DELIVERY, just update status and return
        if (!paymentResponseDTO.getStatus().isSuccessful()) {
            transaction.setStatus(paymentResponseDTO.getStatus());
            // Update Firebase with the transaction status
            firebaseService.updateTransactionStatus(
                    transaction.getId(),
                    transaction.getStatus(),
                    transaction.getNarration()
            );
            return transactionRepo.save(transaction);
        }

        // Update transaction status based on response
        transaction.setStatus(paymentResponseDTO.getStatus());

        // Create subtransactions
        SubTransaction systemDebit = SubTransaction.builder()
                .currencies(transaction.getCurrencies())
                .amount(transaction.getPrincipalAmount())
                .type(TransactionEntryType.DEBIT)
                .transaction(transaction)
                .walletAccount(transaction.getSourceWallet())
                .paymentMethod(transaction.getPaymentMethod())
                .reference(UUID.randomUUID().toString())
                .build();

        SubTransaction driverCredit = SubTransaction.builder()
                .currencies(transaction.getCurrencies())
                .amount(transaction.getPrincipalAmount())
                .type(TransactionEntryType.CREDIT)
                .transaction(transaction)
                .walletAccount(transaction.getDestinationWallet())
                .paymentMethod(transaction.getPaymentMethod())
                .reference(UUID.randomUUID().toString())
                .build();

        List<SubTransaction> subTransactions = subTransactionRepo.saveAll(List.of(systemDebit, driverCredit));

        if (subTransactions.isEmpty() || subTransactions.size() != 2) {
            log.error("========> Error in saving deposit sub-transactions");
            throw new RuntimeException("Error in saving deposit sub-transactions");
        }

        List<WalletBalance> walletBalances = walletBalanceService.processBalanceChanges(subTransactions);
        // Update Firebase with the transaction status
        firebaseService.updateTransactionStatus(
                transaction.getId(),
                transaction.getStatus(),
                transaction.getNarration()
        );
        // Set final status to COMPLETED and save
        transaction.setStatus(TransactionStatus.COMPLETED);
        return transactionRepo.save(transaction);

    }

    @Override
    @Transactional
    public Transaction withdrawFromDriverWallet(Long driverId, BigDecimal amount, Long currencyId, PaymentMethod paymentMethod) {
        // Get the currency
        Currencies currency = currenciesRepo.findById(currencyId)
                .orElseThrow(() -> new CurrencyNotFound("Currency not found with ID: " + currencyId));

        // Get driver wallet
        WalletAccount driverWallet = walletAccountService.getWalletAccountByDriverId(driverId);

        // Get system main suspense wallet (destination for withdrawn funds)
        WalletAccount systemWallet = walletAccountService.getSystemWallet(WalletAccountType.SYSTEM_MAIN_SUSPENSE);

        // Check if driver has enough balance
        WalletBalanceType balanceType = WalletBalanceType.valueOf(paymentMethod.name());
        WalletBalancesResponseDto balanceInfo = walletAccountService.getAllCurrentBalanceForWalletByCurrencyAndBalanceType(
                driverWallet.getId(), currencyId, balanceType);

        if (balanceInfo.runningBalance().compareTo(amount) < 0) {
            throw new RuntimeException("Insufficient funds in driver wallet. Available: " +
                    balanceInfo.runningBalance() + " " + currency.getName());
        }

        // Create the transaction
        Transaction transaction = Transaction.builder()
                .type(TransactionType.WITHDRAWAL)
                .status(TransactionStatus.PENDING)
                .currencies(currency)
                .principalAmount(amount)
                .commissionAmount(BigDecimal.ZERO) // No commission for withdrawals
                .paymentMethod(paymentMethod)
                .sourceWallet(driverWallet)
                .destinationWallet(systemWallet)
                .driverId(driverId)
                .clientId(0L) // System operation, no client involved
                .reference(UUID.randomUUID().toString())
                .narration("Driver wallet withdrawal")
                .build();

        transaction = transactionRepo.save(transaction);

        // Create subtransactions
        SubTransaction driverDebit = SubTransaction.builder()
                .currencies(currency)
                .amount(amount)
                .type(TransactionEntryType.DEBIT)
                .transaction(transaction)
                .walletAccount(driverWallet)
                .paymentMethod(paymentMethod)
                .reference(UUID.randomUUID().toString())
                .build();

        SubTransaction systemCredit = SubTransaction.builder()
                .currencies(currency)
                .amount(amount)
                .type(TransactionEntryType.CREDIT)
                .transaction(transaction)
                .walletAccount(systemWallet)
                .paymentMethod(paymentMethod)
                .reference(UUID.randomUUID().toString())
                .build();

        List<SubTransaction> subTransactions = subTransactionRepo.saveAll(List.of(driverDebit, systemCredit));

        if (subTransactions.isEmpty() || subTransactions.size() != 2) {
            log.error("Error in saving withdrawal sub-transactions");
            throw new RuntimeException("Error in saving withdrawal sub-transactions");
        }

        // Process balance changes
        List<WalletBalance> walletBalances = walletBalanceService.processBalanceChanges(subTransactions);

        // Update transaction status to completed
        transaction.setStatus(TransactionStatus.COMPLETED);
        return transactionRepo.save(transaction);
    }

    @Override
    public WebInitResponse initiateWebPayment(Payment payment) {
        log.info("Initiating web payment for reference: {}", payment.getAuthEmail());
        try {
            Paynow paynow = new Paynow(
                    integrationId,
                    integrationKey
            );

            // Set the result and return URLs
            paynow.setResultUrl(callBackUrl);
            paynow.setReturnUrl(returnUrl);

            // Send the payment request
            WebInitResponse response = paynow.send(payment);

            if (!response.isRequestSuccess()) {
                log.error("========> Failed to initiate web payment: {}", response.errors());
                throw new RuntimeException("Failed to initiate web payment: " + response.errors());
            }

            log.info("========> Web payment initiated successfully. Poll URL: {}", response.pollUrl());
            // Publish event to start polling
            eventPublisher.publishEvent(new StartPollingEvent(this, response.pollUrl(), true));
            return response;

        } catch (Exception e) {
            log.error("======> Error initiating web payment", e);
            throw new RuntimeException("Error initiating web payment: " + e.getMessage());
        }
    }

    @Override
    public MobileInitResponse initiateMobilePayment(Payment payment, String mobileNumber, String email) {
        log.info("=========> Initiating mobile payment for reference: {}", payment.getMerchantReference());

        try {
            Paynow paynow = new Paynow(integrationId, integrationKey);
            MobileInitResponse response = paynow.sendMobile(payment, mobileNumber, zw.co.paynow.constants.MobileMoneyMethod.ECOCASH);
            if (!response.isRequestSuccess()) {
                log.error("=====> Failed to initiate mobile payment: {}", response.errors());
                throw new RuntimeException("Failed to initiate mobile payment: " + response.errors());
            }
            log.info("Mobile payment initiated successfully. Poll URL: {}", response.pollUrl());
            // Publish event to start polling
            eventPublisher.publishEvent(new StartPollingEvent(this, response.pollUrl(), false));
            return response;

        } catch (Exception e) {
            log.error("Error initiating mobile payment", e);
            throw new RuntimeException("Error initiating mobile payment: " + e.getMessage());
        }
    }

    @Override
//    public StatusResponse checkPaymentStatus(String pollUrl) {
//        log.info("*******> Checking payment status for poll URL: {}", pollUrl);
//
//        try {
//
//            Paynow paynow = new Paynow(integrationId, integrationKey);
//
//
//            StatusResponse status = paynow.pollTransaction(pollUrl);
//
//            log.info("========> Payment status checked successfully. Status: {}", status.paid() ? "PAID" : "UNPAID");
//            return status;
//
//        } catch (Exception e) {
//            log.error("========> Error checking payment status {}", e.getMessage());
//            throw new RuntimeException("=======> Error checking payment status: " + e.getMessage());
//        }
//    }
    /**
     * Polls for payment status with exponential backoff and multiple retries.
     *
     * @param pollUrl The URL to poll for payment status
     * @return The final status response after polling
     */
    @Async
    public void checkPaymentStatus(String pollUrl, boolean isWebBased) {
        log.info("*******> Starting payment status polling for URL: {}", pollUrl);

        // Configuration parameters - consider moving these to application properties
        final int MAX_ATTEMPTS = 10;
        final long INITIAL_DELAY_MS_FIRST = isWebBased ? 20000 : 5000; // 10 seconds for web, 5 seconds for mobile
        final long INITIAL_DELAY_MS =  2000; // 10 seconds for web, 5 seconds for mobile
        final long MAX_DELAY_MS = 15000;    // 30 seconds
        final long TIMEOUT_MS = 200000;

        Paynow paynow = new Paynow(integrationId, integrationKey);
        StatusResponse lastStatus = null;

        int attempt = 0;
        long delay = INITIAL_DELAY_MS;
        long startTime = System.currentTimeMillis();
        try{
            Thread.sleep(INITIAL_DELAY_MS_FIRST);// SO DELAY TO GIVE TIME FOR THE USER TO DO THE TXN
        }catch (Exception e){

        }

        while (attempt < MAX_ATTEMPTS && (System.currentTimeMillis() - startTime) < TIMEOUT_MS) {
            try {
                attempt++;
                log.info("========> Polling attempt {}/{} for payment status", attempt, MAX_ATTEMPTS);

                lastStatus = paynow.pollTransaction(pollUrl);

                log.info("========> Payment status: {}", lastStatus.paid() ? "PAID" : "UNPAID");
                log.info("========> Payment status2: {}", JsonUtil.toJson(lastStatus));

                // If payment is complete, exit immediately
                if (lastStatus.paid()) {
                    log.info("========> Payment confirmed successful after {} attempts", attempt);
                    processWalletDepositPayment(ProcessPaymentResponseDTO.builder()
                            .txnId(lastStatus.getMerchantReference())
                            .status(TransactionStatus.valueOf(lastStatus.getStatus().name())).narration("").build());
                    return;
                }else if (lastStatus.getStatus().equals(zw.co.paynow.constants.TransactionStatus.CREATED)) {
                    log.info("========> This means it was Created but still waiting for feedback", attempt);
                } else  {
                    log.info("========> Payment confirmed successful after {} attempts", attempt);
                    processWalletDepositPayment(ProcessPaymentResponseDTO.builder()
                            .txnId(lastStatus.getMerchantReference())
                            .status(TransactionStatus.valueOf(lastStatus.getStatus().name())).narration(lastStatus.getStatus().name()).build());
                    log.info("========> ********* Enum issue after {} attempts", lastStatus.getStatus().name());
                    return;
                }

                // If this isn't our last attempt, wait before trying again
                if (attempt < MAX_ATTEMPTS) {
                    log.info("========> Payment not confirmed yet. Waiting {}ms before next attempt", delay);
                    Thread.sleep(delay);

                    // Exponential backoff with a maximum delay cap
                    delay = Math.min(delay * 2, MAX_DELAY_MS);
                }

            } catch (InterruptedException e) {
                Thread.currentThread().interrupt();
                log.error("========> Polling interrupted: {}", e.getMessage());
                throw new RuntimeException("Polling was interrupted", e);
            } catch (Exception e) {
                log.error("========> Error on polling attempt {}: {}", attempt, e.getMessage());

                // Only wait if this isn't the last attempt
                if (attempt < MAX_ATTEMPTS) {
                    try {
                        log.info("========> Waiting {}ms before retry after error", delay);
                        Thread.sleep(delay);
                        delay = Math.min(delay * 2, MAX_DELAY_MS);
                    } catch (InterruptedException ie) {
                        Thread.currentThread().interrupt();
                        throw new RuntimeException("Polling was interrupted during error recovery", ie);
                    }
                }
            }
        }

        // Check why we exited the loop
        if ((System.currentTimeMillis() - startTime) >= TIMEOUT_MS) {
            log.warn("========> Payment polling timed out after {}ms", TIMEOUT_MS);
        } else {
            log.warn("========> Payment polling exhausted maximum attempts ({})", MAX_ATTEMPTS);
        }

        // Return the last status we received, or throw an exception if we never got one
        if (lastStatus != null) {
            return;
        } else {
            throw new RuntimeException("Failed to retrieve payment status after multiple attempts");
        }
    }

    @Override
    public Payment createPaynowPayment(String reference, List<PaymentItem> items) {
        log.info("Creating Paynow payment for reference: {}", reference);

        try {
            // Create Paynow instance with your integration credentials
            Paynow paynow = new Paynow(
                    integrationId,
                    integrationKey
            );

            // Create a new payment
            Payment payment = paynow.createPayment(reference);//todo remember to fix here "kennedyn@kenac.co.zw"

            // Add items to the payment
            for (PaymentItem item : items) {
                payment.add(item.getName(), item.getAmount().doubleValue());
            }

            log.info("Paynow payment created successfully with {} items", items.size());
            return payment;

        } catch (Exception e) {
            log.error("Error creating Paynow payment", e);
            throw new RuntimeException("Error creating Paynow payment: " + e.getMessage());
        }
    }
    public Payment createPaynowPaymentMobile(String reference, List<PaymentItem> items) {
        log.info("Creating Paynow payment for reference: {}", reference);

        try {
            // Create Paynow instance with your integration credentials
            Paynow paynow = new Paynow(
                    integrationId,
                    integrationKey
            );

            // Create a new payment
            Payment payment = paynow.createPayment(reference,"dylandzvenetashinga@gmail.com");//todo remember to fix here "kennedyn@kenac.co.zw"

            // Add items to the payment
            for (PaymentItem item : items) {
                payment.add(item.getName(), item.getAmount().doubleValue());
            }

            log.info("Paynow payment created successfully with {} items", items.size());
            return payment;

        } catch (Exception e) {
            log.error("Error creating Paynow payment", e);
            throw new RuntimeException("Error creating Paynow payment: " + e.getMessage());
        }
    }

    @Override
    @Transactional
    public Transaction processPaynowCallback(String pollUrl, StatusResponse status) {
        log.info("Processing Paynow callback for poll URL: {}", pollUrl);

        try {
            // Extract transaction reference from poll URL or status
            String reference = status.getMerchantReference();

            // Find the existing transaction
            Transaction transaction = transactionRepo.findById(reference)
                    .orElseThrow(() -> new ResourceNotFoundException("Transaction not found with reference: " + reference));

            // Update transaction status based on Paynow status
            if (status.paid()) {
                transaction.setStatus(TransactionStatus.COMPLETED);

                // Process the payment if it's completed
                if (transaction.getPaymentMethod().equals(PaymentMethod.E_MONEY)) {
                    processEMoneyPayment(ProcessPaymentResponseDTO.builder()
                            .txnId(transaction.getId())
                            .status(TransactionStatus.COMPLETED)
                            .build());
                } else {
                    processCashPayment(ProcessPaymentResponseDTO.builder()
                            .txnId(transaction.getId())
                            .status(TransactionStatus.COMPLETED)
                            .build());
                }
            } else {
                transaction.setStatus(TransactionStatus.FAILED);
            }

            // Save the updated transaction
            transaction = transactionRepo.save(transaction);

            // Update Firebase with the transaction status
            firebaseService.updateTransactionStatus(
                transaction.getId(),
                transaction.getStatus(),
                transaction.getNarration()
            );

            log.info("Paynow callback processed successfully. Transaction status: {}", transaction.getStatus());
            return transaction;

        } catch (Exception e) {
            log.error("Error processing Paynow callback", e);
            throw new RuntimeException("Error processing Paynow callback: " + e.getMessage());
        }
    }
}

