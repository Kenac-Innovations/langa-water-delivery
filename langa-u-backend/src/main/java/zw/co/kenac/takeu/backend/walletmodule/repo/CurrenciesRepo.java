package zw.co.kenac.takeu.backend.walletmodule.repo;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;
import zw.co.kenac.takeu.backend.model.enumeration.WalletAccountStatus;
import zw.co.kenac.takeu.backend.walletmodule.models.Currencies;

import java.util.List;
import java.util.Optional;

/**
 * Created by DylanDzvene
 * Email: dyland@kenac.co.zw
 * Created on: 4/25/2025
 */
@Repository
public interface CurrenciesRepo extends JpaRepository<Currencies,Long> {
    Optional<Currencies> findByName(String name);
    List<Currencies> findByStatus(WalletAccountStatus status);
}
