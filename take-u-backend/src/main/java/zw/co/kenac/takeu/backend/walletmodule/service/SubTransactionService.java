package zw.co.kenac.takeu.backend.walletmodule.service;

import zw.co.kenac.takeu.backend.model.enumeration.PaymentMethod;
import zw.co.kenac.takeu.backend.model.enumeration.TransactionEntryType;
import zw.co.kenac.takeu.backend.walletmodule.models.Currencies;
import zw.co.kenac.takeu.backend.walletmodule.models.SubTransaction;
import zw.co.kenac.takeu.backend.walletmodule.models.Transaction;
import zw.co.kenac.takeu.backend.walletmodule.models.WalletAccount;

import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.util.List;
import java.util.Optional;

/**
 * Created by DylanDzvene
 * Email: dyland@kenac.co.zw
 * Created on: 4/27/2025
 */
public interface SubTransactionService {
    /**
     * Creates a new sub-transaction
     * @param subTransaction the sub-transaction to create
     * @return the created sub-transaction
     */
    SubTransaction createSubTransaction(SubTransaction subTransaction);

    /**
     * Retrieves a sub-transaction by its ID
     * @param id the ID of the sub-transaction
     * @return an Optional containing the sub-transaction if found
     */
    Optional<SubTransaction> getSubTransactionById(Long id);

    /**
     * Updates an existing sub-transaction
     * @param subTransaction the sub-transaction to update
     * @return the updated sub-transaction
     */
    SubTransaction updateSubTransaction(SubTransaction subTransaction);

    /**
     * Retrieves all sub-transactions for a specific transaction
     * @param transactionId the ID of the parent transaction
     * @return list of sub-transactions
     */
    List<SubTransaction> findByMasterTransactionId(String transactionId);

    /**
     * Retrieves all sub-transactions for a specific wallet account
     * @param walletId the ID of the wallet account
     * @return list of sub-transactions
     */
    List<SubTransaction> findByWalletId(Long walletId);

    /**
     * Finds sub-transactions by reference number
     * @param reference the reference to search for
     * @return list of matching sub-transactions
     */
    List<SubTransaction> findByReference(String reference);

    /**
     * Finds sub-transactions by payment method
     * @param paymentMethod the payment method to search for
     * @return list of matching sub-transactions
     */
    List<SubTransaction> findByPaymentMethod(PaymentMethod paymentMethod);

    /**
     * Finds sub-transactions by transaction entry type
     * @param type the transaction entry type to search for
     * @return list of matching sub-transactions
     */
    List<SubTransaction> findByType(TransactionEntryType type);

    /**
     * Finds sub-transactions by currency
     * @param currencyId the ID of the currency
     * @return list of matching sub-transactions
     */
    List<SubTransaction> findByCurrencyId(Long currencyId);

    /**
     * Finds sub-transactions created between the specified dates
     * @param startDate the start date
     * @param endDate the end date
     * @return list of matching sub-transactions
     */
    List<SubTransaction> findByDateCreatedBetween(LocalDateTime startDate, LocalDateTime endDate);

    /**
     * Creates a sub-transaction with individual parameters
     * @param transaction the parent transaction
     * @param walletAccount the wallet account
     * @param reference the reference number
     * @param paymentMethod the payment method
     * @param currency the currency
     * @param type the transaction entry type
     * @param amount the transaction amount
     * @return the created sub-transaction
     */
    SubTransaction createSubTransaction(
            Transaction transaction,
            WalletAccount walletAccount,
            String reference,
            PaymentMethod paymentMethod,
            Currencies currency,
            TransactionEntryType type,
            BigDecimal amount
    );

    /**
     * Gets total amount for specific transaction entry type and wallet
     * @param walletId the wallet account ID
     * @param type the transaction entry type
     * @return the total amount
     */
    BigDecimal getTotalAmountByWalletAndType(Long walletId, TransactionEntryType type);
}
