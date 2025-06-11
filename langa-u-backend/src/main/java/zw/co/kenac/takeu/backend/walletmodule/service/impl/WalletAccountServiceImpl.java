package zw.co.kenac.takeu.backend.walletmodule.service.impl;

import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import zw.co.kenac.takeu.backend.exception.custom.CurrencyNotFound;
import zw.co.kenac.takeu.backend.exception.custom.ResourceNotFoundException;
import zw.co.kenac.takeu.backend.model.DriverEntity;
import zw.co.kenac.takeu.backend.model.enumeration.*;
import zw.co.kenac.takeu.backend.repository.DriverRepository;
import zw.co.kenac.takeu.backend.walletmodule.dto.WalletAccountDto;
import zw.co.kenac.takeu.backend.walletmodule.dto.WalletBalancesResponseDto;
import zw.co.kenac.takeu.backend.walletmodule.models.Currencies;
import zw.co.kenac.takeu.backend.walletmodule.models.WalletAccount;
import zw.co.kenac.takeu.backend.walletmodule.models.WalletBalance;
import zw.co.kenac.takeu.backend.walletmodule.repo.CurrenciesRepo;
import zw.co.kenac.takeu.backend.walletmodule.repo.WalletAccountRepo;
import zw.co.kenac.takeu.backend.walletmodule.repo.WalletBalanceRepo;
import zw.co.kenac.takeu.backend.walletmodule.service.CurrencyService;
import zw.co.kenac.takeu.backend.walletmodule.service.WalletAccountService;
import zw.co.kenac.takeu.backend.walletmodule.service.WalletBalanceService;
import zw.co.kenac.takeu.backend.walletmodule.utils.JsonUtil;

import java.math.BigDecimal;
import java.util.ArrayList;
import java.util.Currency;
import java.util.List;
import java.util.Optional;
import java.util.concurrent.ThreadLocalRandom;

import static zw.co.kenac.takeu.backend.constant.AppConstant.NOT_FOUND;

/**
 * Created by DylanDzvene
 * Email: dyland@kenac.co.zw
 * Created on: 4/24/2025
 */

@Service
@RequiredArgsConstructor
@Transactional
@Slf4j
public class WalletAccountServiceImpl implements WalletAccountService {
    private final WalletBalanceRepo walletBalanceRepo;
    private final WalletAccountRepo walletAccountRepo;
    private final CurrencyService currencyService;
    private final WalletBalanceService walletBalanceService;
    private final DriverRepository driverRepository;
    private final CurrenciesRepo currenciesRepo;

    @Override
    public WalletAccount createWalletAccount(WalletAccountDto walletAccountDto) {
        // Create wallet account

        String accountNumber = walletAccountDto.getAccountNumber();
        if (accountNumber == null) {
            accountNumber = generateAccountNumber(walletAccountDto.getOwnerType(), walletAccountDto.getType());
        }

        WalletAccount walletAccount = WalletAccount.builder()
                .accountNumber(accountNumber)
                .ownerType(walletAccountDto.getOwnerType())

                .status(WalletAccountStatus.ACTIVE)
                .type(walletAccountDto.getType())
                .build();
        if (walletAccountDto.getDriverId()!=null){
            walletAccount.setDriver(driverRepository.findById(walletAccountDto.getDriverId()).orElse(null) );
        }

        if (walletAccountDto.getOrganizationId() != null) {
            //todo this is where we get the organisation and link the relations
            walletAccount.setOrganizationId(walletAccountDto.getOrganizationId());
        }

        WalletAccount savedWalletAccount = walletAccountRepo.save(walletAccount);

        // Initialize with zero balance Pakutanga
        List<WalletBalance> walletBalanceList = initializeWalletBalance(savedWalletAccount);
        if (walletBalanceList.isEmpty()) {
            log.error("======> Error with initializing wallet Balance");
            throw new RuntimeException("Error with  Initializing wallet Balance ");
        }

        return savedWalletAccount;
    }

    private List<WalletBalance> initializeWalletBalance(WalletAccount walletAccount) {
        List<Currencies> currenciesList = currencyService.getCurrenciesByStatus(WalletAccountStatus.ACTIVE);
        if (currenciesList.isEmpty()) {
            log.error("=====> There are not active Currencies ");
            throw new CurrencyNotFound("There are no active currencies in the system please ensure currencies are added before creating wallets");
        }
        List<WalletBalance> walletBalances = new ArrayList<>();
        for (Currencies c : currenciesList) {
            WalletBalance initialBalanceEMoney = WalletBalance.builder()
                    .wallet(walletAccount)
                    .balanceType(WalletBalanceType.E_MONEY)
                    .currency(c)
                    .amount(BigDecimal.ZERO)
                    .runningBalance(BigDecimal.ZERO)
                    .transactionRef("INITIAL")
                    .build();
            WalletBalance initialBalanceCash = WalletBalance.builder()
                    .wallet(walletAccount)
                    .balanceType(WalletBalanceType.CASH)
                    .currency(c)
                    .amount(BigDecimal.ZERO)
                    .runningBalance(BigDecimal.ZERO)
                    .transactionRef("INITIAL")
                    .build();
            walletBalances.add(initialBalanceCash);
            walletBalances.add(initialBalanceEMoney);
        }
        return walletBalanceRepo.saveAll(walletBalances);
    }

    @Override
    public WalletAccount updateWalletAccount(WalletAccountDto walletAccountDto) {
        WalletAccount existingAccount = walletAccountRepo.findById(walletAccountDto.getId())
                .orElseThrow(() -> new ResourceNotFoundException("Wallet account not found with Id: " + walletAccountDto.getId()));

        // Update fields that can be changed
        if (walletAccountDto.getStatus() != null) {
            existingAccount.setStatus(walletAccountDto.getStatus());
        }
        return walletAccountRepo.save(existingAccount);

    }

    @Override
    public WalletAccount getWalletAccount(Long id) {
        return walletAccountRepo.findById(id)
                .orElseThrow(() -> new ResourceNotFoundException("Wallet account not found with Id: " + id));
    }

    @Override
    public WalletAccount getSystemWallet(WalletAccountType walletAccountType) {
        Optional<WalletAccount> walletAccount = walletAccountRepo.findByOwnerTypeAndType(WalletOwnerType.TAKEU_SYSTEM, walletAccountType);
        if (walletAccount.isEmpty()) {
            log.error("========> System wallet Not found please initial system wallets");
            throw new ResourceNotFoundException("System wallet Not found please initial system wallets");
        }
        return walletAccount.get();
    }

    @Override
    public WalletAccount getWalletAccountByNumber(String accountNumber) {
        return walletAccountRepo.findByAccountNumber(accountNumber)
                .orElseThrow(() -> new ResourceNotFoundException("Wallet account not found with number: " + accountNumber));
    }


    @Override
    public WalletAccount getWalletAccountByDriverId(Long ownerId) {
        return walletAccountRepo.findByDriverId(ownerId).orElseThrow(() -> new ResourceNotFoundException("Driver Wallet Not Found for DRIVER WITH  ID::" + ownerId));
    }

    @Override
    public WalletAccount findWalletAccountByDriverId(Long ownerId) {
        return walletAccountRepo.findByDriverId(ownerId).orElse(null);
    }

    @Override
    public WalletAccount getWalletAccountByOrganisationId(Long orgId) {
        return walletAccountRepo.findByOrganizationId(orgId).orElseThrow(() -> new ResourceNotFoundException("Organisational Wallet Not Found for organisation with ID::" + orgId));
    }


    @Override
    public String deleteWalletAccount(Long id) {
        WalletAccount walletAccount = walletAccountRepo.findById(id)
                .orElseThrow(() -> new ResourceNotFoundException("Wallet account not found with Id: " + id));
        walletAccount.setStatus(WalletAccountStatus.INACTIVE);
        walletAccountRepo.save(walletAccount);
        return "Wallet account deactivated successfully";
    }

    @Override
    public BigDecimal getCurrentBalance(Long walletId) {
        WalletAccount wallet = walletAccountRepo.findById(walletId)
                .orElseThrow(() -> new ResourceNotFoundException("Wallet account not found with Id: " + walletId));

        return walletBalanceRepo.findTopByWalletOrderByDateCreatedDesc(wallet)
                .map(WalletBalance::getRunningBalance)
                .orElse(BigDecimal.ZERO);
    }

    @Override
    public List<WalletBalancesResponseDto> getAllSystemBalances() {
        WalletAccount suspenseCharge = getSystemWallet(WalletAccountType.SYSTEM_CHARGE_SUSPENSE);
        WalletAccount suspenseMain= getSystemWallet(WalletAccountType.SYSTEM_MAIN_SUSPENSE);
        log.info("=======> The Charge wallet is {}", JsonUtil.toJson(suspenseCharge));
        log.info("=======> The Suspense wallet is {}", JsonUtil.toJson(suspenseMain));
        List<WalletBalancesResponseDto> walletBalancesResponseDtos=new ArrayList<>();
        List<WalletBalancesResponseDto> responseDtos=getAllCurrentBalanceForWallet(suspenseCharge.getId());
        List<WalletBalancesResponseDto> responseDtos2=getAllCurrentBalanceForWallet(suspenseMain.getId());
        log.info("=======> The Response size is {}",responseDtos.size());
        log.info("=======> The Response2 size is {}",responseDtos2.size());
        walletBalancesResponseDtos.addAll(responseDtos2);
//responseDtos.addAll(responseDtos2);
        walletBalancesResponseDtos.addAll(responseDtos);
        log.info("=======> The ResponseAfter size is {}",responseDtos.size());
        return walletBalancesResponseDtos;
    }

    @Override
    public List<WalletBalancesResponseDto> getAllCurrentBalanceForWallet(Long walletId) {
        WalletAccount walletAccount = walletAccountRepo.findById(walletId).orElseThrow(() -> new ResourceNotFoundException("Wallet Not Found with Id :" + walletId));
        List<WalletBalance> walletBalanceList = walletBalanceService.getCurrentAllBalanceForWallet(walletAccount);

        return walletBalanceList.stream().map(bal -> {
            return WalletBalancesResponseDto.builder()
                    .currencyCode(bal.getCurrency().getName())
                    .currencyId(bal.getCurrency().getId())
                    .balanceType(bal.getBalanceType())
                    .walletAccountType(bal.getWallet().getType())
                    .ownerType(bal.getWallet().getOwnerType())
                    .id(bal.getId())
                    .runningBalance(bal.getRunningBalance())
                    .dateCreated(bal.getDateCreated())
                    .walletId(bal.getWallet().getId())
                    .transactionRef(bal.getTransactionRef())
                    .build();
        }).toList();
    }

    @Override
    public List<WalletBalancesResponseDto> getAllCurrentBalanceForWalletByCurrency(Long walletId, String currencyName) {
        Currencies currency = currenciesRepo.findByName(currencyName).orElseThrow(() ->new CurrencyNotFound("Currency Not Found with Name :" + currencyName));
        WalletAccount walletAccount = walletAccountRepo.findById(walletId).orElseThrow(() -> new ResourceNotFoundException("No Wallet Account with this Id found ID ::" + walletId));
        List<WalletBalance> walletBalanceList = walletBalanceService.getAllCurrentBalanceForWalletByCurrency(walletId, currency.getId());
        if (walletBalanceList.isEmpty()) {
            // Panaapa we are createing a fallback , just in case pakaita error on initialaziong of balance and all
            List<WalletBalance> walletBalances = initializeWalletBalance(walletAccount);

            return walletBalances.stream().map(bal -> {
                return WalletBalancesResponseDto.builder()
                        .currencyCode(bal.getCurrency().getName())
                        .currencyId(bal.getCurrency().getId())
                        .runningBalance(bal.getRunningBalance())
                        .id(bal.getId())
                        .walletAccountType(bal.getWallet().getType())
                        .ownerType(bal.getWallet().getOwnerType())
                        .dateCreated(bal.getDateCreated())
                        .balanceType(bal.getBalanceType())
                        .walletId(bal.getWallet().getId())
                        .transactionRef(bal.getTransactionRef())
                        .build();
            }).toList();
        }
        return walletBalanceList.stream().map(bal -> {
            return WalletBalancesResponseDto.builder()
                    .currencyCode(bal.getCurrency().getName())
                    .currencyId(bal.getCurrency().getId())
                    .runningBalance(bal.getRunningBalance())
                    .balanceType(bal.getBalanceType())
                    .walletAccountType(bal.getWallet().getType())
                    .ownerType(bal.getWallet().getOwnerType())
                    .id(bal.getId())
                    .dateCreated(bal.getDateCreated())
                    .walletId(bal.getWallet().getId())
                    .transactionRef(bal.getTransactionRef())
                    .build();
        }).toList();
    }

    @Override
    public WalletBalancesResponseDto getAllCurrentBalanceForWalletByCurrencyAndBalanceType(Long walletId, Long currencyId, WalletBalanceType balanceType) {
        WalletAccount walletAccount = walletAccountRepo.findById(walletId).orElseThrow(() -> new ResourceNotFoundException("No Wallet Account with this Id found ID ::" + walletId));
        WalletBalance walletBalance = walletBalanceService.getCurrentBalanceForWalletByCurrencyAndBalanceType(walletId, currencyId, balanceType);
        if (walletBalance == null) {// if there is not balance at all then create the balances and returnt the appropriate one
            WalletBalance walletBalance1 = initializeWalletBalance(walletAccount).stream().filter(x -> x.getBalanceType().equals(balanceType)).toList().get(0);
            return WalletBalancesResponseDto.builder()
                    .currencyCode(walletBalance1.getCurrency().getName())
                    .currencyId(walletBalance1.getCurrency().getId())
                    .runningBalance(walletBalance1.getRunningBalance())
                    .balanceType(walletBalance1.getBalanceType())
                    .ownerType(walletBalance1.getWallet().getOwnerType())
                    .walletAccountType(walletBalance1.getWallet().getType())
                    .id(walletBalance1.getId())
                    .dateCreated(walletBalance1.getDateCreated())
                    .walletId(walletBalance1.getWallet().getId())
                    .transactionRef(walletBalance1.getTransactionRef())
                    .build();

        }
        return WalletBalancesResponseDto.builder()
                .currencyCode(walletBalance.getCurrency().getName())
                .id(walletBalance.getId())
                .ownerType(walletBalance.getWallet().getOwnerType())
                .walletAccountType(walletBalance.getWallet().getType())
                .currencyId(walletBalance.getCurrency().getId())
                .runningBalance(walletBalance.getRunningBalance())
                .balanceType(walletBalance.getBalanceType())
                .dateCreated(walletBalance.getDateCreated())
                .walletId(walletBalance.getWallet().getId())
                .transactionRef(walletBalance.getTransactionRef())
                .build();
    }

    @Override
    public WalletAccount initializeDriverWallets(Long driverId) {
        // Check if the driver is individual or part of an organization
        //todo we first get the driverEntity
        DriverEntity driver = driverRepository.findById(driverId)
                .orElseThrow(() -> new ResourceNotFoundException(NOT_FOUND));

        // Individual driver their Driver Suspense
        WalletAccountDto driverWalletDto = WalletAccountDto.builder()
                .ownerType(WalletOwnerType.DRIVER)
                .driverId(driver.getEntityId())// todo this is where we do driver.Id
                .type(WalletAccountType.DRIVER_MAIN_SUSPENSE)

                .build();

        log.info("===========> Created Suspense wallet for individual driver with ID: {}", driverId);
        return createWalletAccount(driverWalletDto);
    }

    @Override
    public WalletBalancesResponseDto getDriverOperationFloatBalance(Long driverId, Long currencyId) {
        // todo remove this this is not necessary
        Boolean isOrgDriver=false;
        WalletAccount walletAccount;
        if(isOrgDriver){
            walletAccount=getWalletAccountByOrganisationId(1L);
        }else {
            walletAccount=getWalletAccountByDriverId(driverId);
        }

        return getAllCurrentBalanceForWalletByCurrencyAndBalanceType(walletAccount.getId(),currencyId,WalletBalanceType.E_MONEY);
    }

    @Override
    public WalletAccount initializeOrganizationWallets(Long organizationId) {
        // Organization needs an E-Money wallet
        WalletAccountDto orgWalletDto = WalletAccountDto.builder()
                .ownerType(WalletOwnerType.ORGANIZATION)
                .driverId(null)// todo this is where we make sure that the owner is the organisation
                .type(WalletAccountType.ORG_MAIN_SUSPENSE)
                .organizationId(organizationId)
                .currency(WalletCurrency.USD)
                .build();
        log.info("===========> Created Suspense wallet for organization with ID: {}", organizationId);
        return createWalletAccount(orgWalletDto);
    }

    @Override
    public List<WalletAccount> initializeSystemWallets() {
        log.info("===========> Creating System Main Wallets ");
        Optional<WalletAccount> walletAccount = walletAccountRepo.findByOwnerTypeAndType(WalletOwnerType.TAKEU_SYSTEM, WalletAccountType.SYSTEM_MAIN_SUSPENSE);
        if (walletAccount.isPresent()) {
            log.info("========> System wallet are already created");
            return null;
        }
        // create System main  syspense account
        WalletAccountDto suspenseWalletDto = WalletAccountDto.builder()
                .ownerType(WalletOwnerType.TAKEU_SYSTEM)
                .driverId(null)
                .type(WalletAccountType.SYSTEM_MAIN_SUSPENSE)
                .organizationId(null)
                .build();
        WalletAccountDto chargeWalletDto = WalletAccountDto.builder()
                .ownerType(WalletOwnerType.TAKEU_SYSTEM)
                .driverId(null)// todo this is where we make sure that the owner is the organisation
                .type(WalletAccountType.SYSTEM_CHARGE_SUSPENSE)
                .organizationId(null)
                .build();

        WalletAccount suspense = createWalletAccount(suspenseWalletDto);
        WalletAccount charge = createWalletAccount(chargeWalletDto);
        return List.of(suspense, charge);
    }

    public static WalletAccountDto convertToDTO(WalletAccount walletAccount) {
        return WalletAccountDto.builder()
                .status(walletAccount.getStatus())
                .type(walletAccount.getType())
                .dateCreated(walletAccount.getDateCreated())
                .accountNumber(walletAccount.getAccountNumber())
                .lastUpdated(walletAccount.getLastUpdated())
                .id(walletAccount.getId())
                .organizationId(walletAccount.getOrganizationId())
                .driverId(walletAccount.getDriver().getEntityId())
                .status(walletAccount.getStatus())
                .ownerType(walletAccount.getOwnerType())
                .build();
    }

    private String generateAccountNumber(WalletOwnerType ownerType, WalletAccountType type) {
        String prefix;

        switch (ownerType) {
            case DRIVER:
                prefix = "DRV-";
                break;
            case ORGANIZATION:
                prefix = "ORG-";
                break;
            case TAKEU_SYSTEM:
                prefix = "SYS-";
                break;
            default:
                prefix = "WAL";
        }

        String typeCode;
        switch (type) {

            case DRIVER_MAIN_SUSPENSE:
                typeCode = "DS-";
                break;
            case SYSTEM_MAIN_SUSPENSE:
                typeCode = "MS-";
                break;
            case SYSTEM_CHARGE_SUSPENSE:
                typeCode = "CS-";
                break;
            default:
                typeCode = "XX";
        }

        // Generate unique ID
        String timestamp = String.valueOf(System.currentTimeMillis()).substring(6);
        String random = String.valueOf(ThreadLocalRandom.current().nextInt(100, 999));

        return prefix + typeCode + timestamp + random;
    }
}
