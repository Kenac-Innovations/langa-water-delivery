package zw.co.kenac.takeu.backend.service.internal.impl;

import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import zw.co.kenac.takeu.backend.exception.custom.ResourceNotFoundException;
import zw.co.kenac.takeu.backend.model.ClientEntity;
import zw.co.kenac.takeu.backend.model.DeliveryEntity;
import zw.co.kenac.takeu.backend.model.enumeration.ClientStatus;
import zw.co.kenac.takeu.backend.repository.ClientRepository;
import zw.co.kenac.takeu.backend.repository.DeliveryRepository;
import zw.co.kenac.takeu.backend.service.internal.ClientService;

/**
 * Created by dyland
 * Email: dyland@kenac.co.zw
 * Created on: 15/5/2025
 */
@Service
@RequiredArgsConstructor
@Slf4j
@Transactional
public class ClientServiceImpl implements ClientService {

    private final ClientRepository clientRepository;
    private final DeliveryRepository deliveryRepository;
    
    private static final String CLIENT_NOT_FOUND = "Client not found with ID: ";

    @Override
    public ClientEntity findById(Long id) {
        log.info("========> Finding client with ID: {}", id);
        return clientRepository.findById(id)
                .orElseThrow(() -> new ResourceNotFoundException(CLIENT_NOT_FOUND + id));
    }

    @Override
    public Page<ClientEntity> findAll(Pageable pageable) {
        log.info("=======> Finding all clients with pagination");
        return clientRepository.findAll(pageable);
    }

    @Override
    public Page<ClientEntity> findByStatus(ClientStatus status, Pageable pageable) {
        log.info("=======> Finding clients with status: {} and pagination", status);
        return clientRepository.findByStatus(status, pageable);
    }

    @Override
    public Page<DeliveryEntity> getAllDeliveriesByClient(Long clientId, Pageable pageable) {
        log.info("Getting all deliveries for client with ID: {}", clientId);
        // Check if client exists
        if (!clientRepository.existsById(clientId)) {
            throw new ResourceNotFoundException(CLIENT_NOT_FOUND + clientId);
        }
        return deliveryRepository.findAllByCustomerEntityId(pageable, clientId);
    }

    @Override
    public Page<DeliveryEntity> getAllDeliveriesByClientAndStatus(Long clientId, String status, Pageable pageable) {
        log.info("Getting deliveries for client with ID: {} and status: {}", clientId, status);
        // Check if client exists
        if (!clientRepository.existsById(clientId)) {
            throw new ResourceNotFoundException(CLIENT_NOT_FOUND + clientId);
        }
        return deliveryRepository.findAllByCustomerEntityIdAndStatus(pageable, clientId, status);
    }

    @Override
    public ClientEntity updateClientStatus(Long clientId, ClientStatus status) {
        log.info("Updating status for client with ID: {} to {}", clientId, status);
        ClientEntity client = findById(clientId);
        client.setStatus(status);
        return clientRepository.save(client);
    }
} 