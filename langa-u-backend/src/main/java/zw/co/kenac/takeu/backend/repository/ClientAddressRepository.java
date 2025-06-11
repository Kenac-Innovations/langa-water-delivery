package zw.co.kenac.takeu.backend.repository;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;
import zw.co.kenac.takeu.backend.model.ClientAddressesEntity;

/**
 * Created by dyland
 * Email: dyland@kenac.co.zw
 * Created on: 10/6/2025
 */
@Repository
public interface ClientAddressRepository extends JpaRepository<ClientAddressesEntity, Long> {
}
