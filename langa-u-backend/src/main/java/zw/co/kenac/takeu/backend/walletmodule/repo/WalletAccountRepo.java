package zw.co.kenac.takeu.backend.walletmodule.repo;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;
import zw.co.kenac.takeu.backend.model.enumeration.WalletAccountType;
import zw.co.kenac.takeu.backend.model.enumeration.WalletOwnerType;
import zw.co.kenac.takeu.backend.walletmodule.models.WalletAccount;

import java.util.Optional;

/**
 * Created by DylanDzvene
 * Email: dylandzvenetashinga@gmail.com
 * Created on: 4/24/2025
 */
@Repository
public interface WalletAccountRepo extends JpaRepository<WalletAccount,Long> {
    Optional<WalletAccount> findByAccountNumber(String accountNumber);
    @Query("SELECT W FROM WalletAccount W WHERE W.driver.entityId=:ownerId  ")
    Optional<WalletAccount> findByDriverId(@Param("ownerId") Long ownerId);
    @Query("SELECT W FROM WalletAccount W WHERE W.organizationId=:orgId  ")
    Optional<WalletAccount> findByOrganizationId(@Param("orgId") Long orgId);
    //Optional<WalletAccount> findByOwnerIdAndOwnerTypeAndType(Long ownerId, WalletOwnerType ownerType, WalletAccountType type);
    @Query("SELECT w FROM WalletAccount w WHERE w.driver.entityId = :ownerId AND w.ownerType = :ownerType AND w.type = :type")
    Optional<WalletAccount> findByOwnerIdAndOwnerTypeAndType(@Param("ownerId") Long ownerId,
                                                             @Param("ownerType") WalletOwnerType ownerType,
                                                             @Param("type") WalletAccountType type);
    Optional<WalletAccount> findByOwnerTypeAndType(WalletOwnerType ownerType, WalletAccountType type);
}
