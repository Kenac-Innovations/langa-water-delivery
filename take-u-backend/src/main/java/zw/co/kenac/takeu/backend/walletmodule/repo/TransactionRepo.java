package zw.co.kenac.takeu.backend.walletmodule.repo;

import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;
import zw.co.kenac.takeu.backend.model.enumeration.TransactionStatus;
import zw.co.kenac.takeu.backend.walletmodule.models.Transaction;
import zw.co.kenac.takeu.backend.walletmodule.models.WalletAccount;

import java.util.List;
import java.util.Optional;

/**
 * Created by DylanDzvene
 * Email: dylandzvenetashinga@gmail.com
 * Created on: 4/25/2025
 */
@Repository
public interface TransactionRepo extends JpaRepository<Transaction, String> {
    List<Transaction> findBySourceWalletOrDestinationWalletOrderByDateCreatedDesc(
            WalletAccount sourceWallet, WalletAccount destinationWallet);
    List<Transaction> findByDriverIdOrderByDateCreatedDesc(Long driverId);
    List<Transaction> findByOrganizationIdOrderByDateCreatedDesc(Long organizationId);
    
    Page<Transaction> findBySourceWalletOrDestinationWalletOrderByDateCreatedDesc(
            WalletAccount sourceWallet, WalletAccount destinationWallet, Pageable pageable);
    
    Page<Transaction> findBySourceWalletOrDestinationWalletAndStatusOrderByDateCreatedDesc(
            WalletAccount sourceWallet, WalletAccount destinationWallet, 
            TransactionStatus status, Pageable pageable);
    
    Page<Transaction> findByDriverIdOrderByDateCreatedDesc(Long driverId, Pageable pageable);
    
    Page<Transaction> findByDriverIdAndStatusOrderByDateCreatedDesc(
            Long driverId, TransactionStatus status, Pageable pageable);

    Optional<Transaction> findByReference(String reference);
}
