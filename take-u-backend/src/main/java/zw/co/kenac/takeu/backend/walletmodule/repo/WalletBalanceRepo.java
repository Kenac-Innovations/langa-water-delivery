package zw.co.kenac.takeu.backend.walletmodule.repo;

import jakarta.persistence.QueryHint;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;
import zw.co.kenac.takeu.backend.model.enumeration.WalletBalanceType;
import zw.co.kenac.takeu.backend.walletmodule.models.WalletAccount;
import zw.co.kenac.takeu.backend.walletmodule.models.WalletBalance;

import java.util.List;
import java.util.Optional;

/**
 * Created by DylanDzvene
 * Email: dylandzvenetashinga@gmail.com
 * Created on: 4/24/2025
 */
@Repository
public interface WalletBalanceRepo extends JpaRepository<WalletBalance, Long> {
    Optional<WalletBalance> findTopByWalletOrderByDateCreatedDesc(WalletAccount wallet);

    List<WalletBalance> findByWalletOrderByDateCreatedDesc(WalletAccount wallet);

    Optional<WalletBalance> findByTransactionRef(String transactionRef);

    @Query("SELECT wb FROM WalletBalance wb WHERE wb.currency.id = :currencyId AND wb.wallet.id = :walletId AND wb.balanceType = :balanceType ORDER BY wb.dateCreated DESC")
   // @QueryHint(name = org.hibernate.jpa.QueryHints.HINT_FETCH_SIZE, value = "1")
    Optional<WalletBalance> getBalanceByCurrencyAndWalletAndTypes(@Param("currencyId") Long currencyId, @Param("walletId") Long walletId, @Param("balanceType") WalletBalanceType balanceType);
    Optional<WalletBalance> findTopByCurrency_IdAndWallet_IdAndBalanceTypeOrderByDateCreatedDesc(
            Long currencyId,
            Long walletId,
            WalletBalanceType balanceType
    );
    @Query("""
    SELECT wb FROM WalletBalance wb
    WHERE wb.wallet.id = :walletId
    AND wb.balanceType = :balanceType
    AND wb.currency.status = 'ACTIVE'
    AND wb.dateCreated = (
        SELECT MAX(wb2.dateCreated) FROM WalletBalance wb2
        WHERE wb2.currency = wb.currency
        AND wb2.wallet.id = :walletId
        AND wb2.balanceType = :balanceType
    )
    """)
    List<WalletBalance> getLatestBalanceForAllActiveCurrenciesAndType(
            @Param("walletId") Long walletId,
            @Param("balanceType") WalletBalanceType balanceType);


}
