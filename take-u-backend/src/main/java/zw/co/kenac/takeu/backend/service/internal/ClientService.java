package zw.co.kenac.takeu.backend.service.internal;

import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import zw.co.kenac.takeu.backend.model.ClientEntity;
import zw.co.kenac.takeu.backend.model.DeliveryEntity;
import zw.co.kenac.takeu.backend.model.enumeration.ClientStatus;

/**
 * Created by dyland
 * Email: dyland@kenac.co.zw
 * Created on: 15/5/2025
 */
public interface ClientService {

    ClientEntity findById(Long id);
    Page<ClientEntity> findAll(Pageable pageable);

    Page<ClientEntity> findByStatus(ClientStatus status, Pageable pageable);

    Page<DeliveryEntity> getAllDeliveriesByClient(Long clientId, Pageable pageable);
    Page<DeliveryEntity> getAllDeliveriesByClientAndStatus(Long clientId, String status, Pageable pageable);
    ClientEntity updateClientStatus(Long clientId, ClientStatus status);
} 