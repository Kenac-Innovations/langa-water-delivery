package zw.co.kenac.takeu.backend.walletmodule.service.impl;

import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import zw.co.kenac.takeu.backend.model.enumeration.PaymentMethod;
import zw.co.kenac.takeu.backend.model.enumeration.TransactionEntryType;
import zw.co.kenac.takeu.backend.walletmodule.models.Currencies;
import zw.co.kenac.takeu.backend.walletmodule.models.SubTransaction;
import zw.co.kenac.takeu.backend.walletmodule.models.Transaction;
import zw.co.kenac.takeu.backend.walletmodule.models.WalletAccount;
import zw.co.kenac.takeu.backend.walletmodule.repo.SubTransactionRepo;
import zw.co.kenac.takeu.backend.walletmodule.service.SubTransactionService;

import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.util.List;
import java.util.Optional;

/**
 * Created by DylanDzvene
 * Email: dyland@kenac.co.zw
 * Created on: 4/27/2025
 */

@Service
@RequiredArgsConstructor
@Transactional
public class SubTransactionServiceImpl implements SubTransactionService {

    private final SubTransactionRepo subTransactionRepo;

    @Override

    public SubTransaction createSubTransaction(SubTransaction subTransaction) {
        return subTransactionRepo.save(subTransaction);
    }

    @Override
    public Optional<SubTransaction> getSubTransactionById(Long id) {
        return subTransactionRepo.findById(id);
    }

    @Override

    public SubTransaction updateSubTransaction(SubTransaction subTransaction) {
        return subTransactionRepo.save(subTransaction);
    }

    @Override
    public List<SubTransaction> findByMasterTransactionId(String transactionId) {
        return subTransactionRepo.findByTransactionId(transactionId);
    }

    @Override
    public List<SubTransaction> findByWalletId(Long walletId) {
        return subTransactionRepo.findByWalletAccount(walletId);
    }

    @Override
    public List<SubTransaction> findByReference(String reference) {
        return subTransactionRepo.findByReference(reference);
    }

    @Override
    public List<SubTransaction> findByPaymentMethod(PaymentMethod paymentMethod) {
        return subTransactionRepo.findByPaymentMethod(paymentMethod);
    }

    @Override
    public List<SubTransaction> findByType(TransactionEntryType type) {
        return subTransactionRepo.findByType(type);
    }

    @Override
    public List<SubTransaction> findByCurrencyId(Long currencyId) {
        return subTransactionRepo.findByCurrenciesId(currencyId);
    }

    @Override
    public List<SubTransaction> findByDateCreatedBetween(LocalDateTime startDate, LocalDateTime endDate) {
        return subTransactionRepo.findByDateCreatedBetween(startDate, endDate);
    }

    @Override

    public SubTransaction createSubTransaction(
            Transaction transaction,
            WalletAccount walletAccount,
            String reference,
            PaymentMethod paymentMethod,
            Currencies currency,
            TransactionEntryType type,
            BigDecimal amount
    ) {
        SubTransaction subTransaction = SubTransaction.builder()
                .transaction(transaction)
                .walletAccount(walletAccount)
                .reference(reference)
                .paymentMethod(paymentMethod)
                .currencies(currency)
                .type(type)
                .amount(amount)
                .build();

        return subTransactionRepo.save(subTransaction);
    }

    @Override
    public BigDecimal getTotalAmountByWalletAndType(Long walletId, TransactionEntryType type) {
        List<SubTransaction> subTransactions = subTransactionRepo.findByWalletAccountAndType(walletId, type);
        return subTransactions.stream()
                .map(SubTransaction::getAmount)
                .reduce(BigDecimal.ZERO, BigDecimal::add);
    }
}