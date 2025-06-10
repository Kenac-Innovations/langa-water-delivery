package zw.co.kenac.takeu.backend.controller.internal.impl;

import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageRequest;
import org.springframework.data.domain.Pageable;
import org.springframework.data.domain.Sort;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import zw.co.kenac.takeu.backend.dto.GenericResponse;
import zw.co.kenac.takeu.backend.model.ClientEntity;
import zw.co.kenac.takeu.backend.model.DeliveryEntity;
import zw.co.kenac.takeu.backend.model.enumeration.ClientStatus;
import zw.co.kenac.takeu.backend.service.internal.ClientService;

/**
 * REST controller for managing clients
 */
@RestController
@RequestMapping("${custom.base.path}/clients")
@RequiredArgsConstructor
@Slf4j
@Tag(name = "Client Management", description = "Endpoints for Client Management")
public class ClientController {

    private final ClientService clientService;

    @Operation(summary = "Get client by ID")
    @GetMapping("/{id}")
    public ResponseEntity<GenericResponse<ClientEntity>> getClientById(@PathVariable Long id) {
        log.info("REST request to get Client with ID: {}", id);
        ClientEntity client = clientService.findById(id);
        return ResponseEntity.ok(GenericResponse.success(client));
    }

    @Operation(summary = "Get all clients with pagination")
    @GetMapping
    public ResponseEntity<GenericResponse<Page<ClientEntity>>> getAllClients(
            @RequestParam(defaultValue = "0") int page,
            @RequestParam(defaultValue = "10") int size) {
        
        log.info("REST request to get all Clients - page: {}, size: {}", page, size);
        Pageable pageable = PageRequest.of(page, size);
        Page<ClientEntity> clients = clientService.findAll(pageable);
        
        return ResponseEntity.ok(GenericResponse.success(clients));
    }

    @Operation(summary = "Get clients by status with pagination")
    @GetMapping("/status/{status}")
    public ResponseEntity<GenericResponse<Page<ClientEntity>>> getClientsByStatus(
            @PathVariable ClientStatus status,
            @RequestParam(defaultValue = "0") int page,
            @RequestParam(defaultValue = "10") int size,
            @RequestParam(defaultValue = "dateCreated") String sort) {
        
        log.info("REST request to get Clients by status: {} - page: {}, size: {}, sort: {}", 
                status, page, size, sort);
        
        Pageable pageable = PageRequest.of(page, size, Sort.by(sort).descending());
        Page<ClientEntity> clients = clientService.findByStatus(status, pageable);
        
        return ResponseEntity.ok(GenericResponse.success(clients));
    }

    @Operation(summary = "Get all deliveries for a client with pagination")
    @GetMapping("/{clientId}/deliveries")
    public ResponseEntity<GenericResponse<Page<DeliveryEntity>>> getClientDeliveries(
            @PathVariable Long clientId,
            @RequestParam(defaultValue = "0") int page,
            @RequestParam(defaultValue = "10") int size,
            @RequestParam(defaultValue = "dateCreated") String sort) {
        
        log.info("REST request to get Deliveries for Client with ID: {} - page: {}, size: {}, sort: {}", 
                clientId, page, size, sort);
        
        Pageable pageable = PageRequest.of(page, size, Sort.by(sort).descending());
        Page<DeliveryEntity> deliveries = clientService.getAllDeliveriesByClient(clientId, pageable);
        
        return ResponseEntity.ok(GenericResponse.success(deliveries));
    }

    @Operation(summary = "Get deliveries for a client by status with pagination")
    @GetMapping("/{clientId}/deliveries/status/{status}")
    public ResponseEntity<GenericResponse<Page<DeliveryEntity>>> getClientDeliveriesByStatus(
            @PathVariable Long clientId,
            @PathVariable String status,
            @RequestParam(defaultValue = "0") int page,
            @RequestParam(defaultValue = "10") int size,
            @RequestParam(defaultValue = "dateCreated") String sort) {
        
        log.info("REST request to get Deliveries for Client with ID: {} and status: {} - page: {}, size: {}, sort: {}", 
                clientId, status, page, size, sort);
        
        Pageable pageable = PageRequest.of(page, size, Sort.by(sort).descending());
        Page<DeliveryEntity> deliveries = clientService.getAllDeliveriesByClientAndStatus(clientId, status, pageable);
        
        return ResponseEntity.ok(GenericResponse.success(deliveries));
    }

    @Operation(summary = "Update client status")
    @PutMapping("/{clientId}/status/{status}")
    public ResponseEntity<GenericResponse<ClientEntity>> updateClientStatus(
            @PathVariable Long clientId,
            @PathVariable ClientStatus status) {
        
        log.info("REST request to update Client status with ID: {} to status: {}", clientId, status);
        ClientEntity updatedClient = clientService.updateClientStatus(clientId, status);
        
        return ResponseEntity.ok(GenericResponse.success(updatedClient));
    }
} 