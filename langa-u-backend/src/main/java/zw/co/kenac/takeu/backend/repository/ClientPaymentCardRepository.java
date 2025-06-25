package zw.co.kenac.takeu.backend.repository;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;
import zw.co.kenac.takeu.backend.model.waterdelivery.ClientPaymentCardEntity;

import java.util.List;

/**
 * @author Joy Pedze
 * Date: 25 Jun 2025
 * Project: langa-u-backend
 * Package: zw.co.kenac.takeu.backend.repository
 */

@Repository
public interface ClientPaymentCardRepository extends JpaRepository<ClientPaymentCardEntity, Long> {
    List<ClientPaymentCardEntity> findByClient_EntityId(Long clientId);
}


