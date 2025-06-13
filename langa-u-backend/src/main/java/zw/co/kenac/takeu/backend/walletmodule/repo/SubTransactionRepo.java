package zw.co.kenac.takeu.backend.walletmodule.repo;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;
import zw.co.kenac.takeu.backend.model.enumeration.PaymentMethod;
import zw.co.kenac.takeu.backend.model.enumeration.TransactionEntryType;
import zw.co.kenac.takeu.backend.walletmodule.models.SubTransaction;
import zw.co.kenac.takeu.backend.walletmodule.models.WalletAccount;

import java.time.LocalDateTime;
import java.util.List;

/**
 * Created by DylanDzvene
 * Email: dyland@kenac.co.zw
 * Created on: 4/27/2025
 */

@Repository
public interface SubTransactionRepo extends JpaRepository<SubTransaction,Long> {
    List<SubTransaction> findByTransactionId(String transaction_id);
    @Query("SELECT T FROM SubTransaction T WHERE T.walletAccount.id=:walletId")
    List<SubTransaction> findByWalletAccount(@Param("walletId") Long walletId);
    List<SubTransaction> findByReference(String reference);
    List<SubTransaction> findByPaymentMethod(PaymentMethod paymentMethod);
    List<SubTransaction> findByType(TransactionEntryType type);
    @Query("SELECT T FROM SubTransaction T WHERE T.currencies.id=:currencyId")
    List<SubTransaction> findByCurrenciesId(@Param("currencyId") Long currencyId);
    List<SubTransaction> findByDateCreatedBetween(LocalDateTime startDate, LocalDateTime endDate);
    @Query("SELECT T FROM SubTransaction T WHERE T.walletAccount.id=:walletId AND T.type=:type")
    List<SubTransaction> findByWalletAccountAndType(@Param("walletId") Long walletId,@Param("type") TransactionEntryType type);
}
