package zw.co.kenac.takeu.backend.repository;

import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;
import zw.co.kenac.takeu.backend.model.ClientEntity;
import zw.co.kenac.takeu.backend.model.enumeration.ClientStatus;

/**
 * @author : Jaison.Chipuka
 * @email : jaisonc@kenac.co.zw
 * @project : take-u-backend on 9/4/2025
 */
@Repository
public interface ClientRepository extends JpaRepository<ClientEntity, Long> {
    /**
     * Find clients by status with pagination
     */
    Page<ClientEntity> findByStatus(ClientStatus status, Pageable pageable);
    
    /**
     * Find clients by email address
     */
    ClientEntity findByEmailAddress(String email);
    
    /**
     * Find clients by mobile number
     */
    ClientEntity findByMobileNumber(String mobileNumber);
}
