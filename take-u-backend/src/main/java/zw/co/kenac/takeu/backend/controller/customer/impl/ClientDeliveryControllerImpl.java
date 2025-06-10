package zw.co.kenac.takeu.backend.controller.customer.impl;

import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import zw.co.kenac.takeu.backend.controller.customer.ClientDeliveryController;
import zw.co.kenac.takeu.backend.dto.GenericResponse;
import zw.co.kenac.takeu.backend.dto.PaginatedResponse;
import zw.co.kenac.takeu.backend.dto.client.*;
import zw.co.kenac.takeu.backend.service.client.ClientDeliveryService;

import java.util.List;

import static zw.co.kenac.takeu.backend.dto.GenericResponse.success;

@RestController
@RequiredArgsConstructor
public class ClientDeliveryControllerImpl implements ClientDeliveryController {

    private final ClientDeliveryService deliveryService;

//    @Override
//    public ResponseEntity<PaginatedResponse<ClientDeliveryResponse>> findAllActiveDeliveries(Long clientId, int pageNumber, int pageSize, String status) {
//        return ResponseEntity.ok(deliveryService.findAllDeliveries(clientId, pageNumber, pageSize, status));
//    }

    @Override
    public ResponseEntity<PaginatedResponse<ClientDeliveryResponse>> findAllActiveDeliveries(Long clientId, int pageNumber, int pageSize) {
        return ResponseEntity.ok(deliveryService.getAllCustomerActiveDeliveries(clientId, pageNumber, pageSize));
    }

    @Override
    public ResponseEntity<PaginatedResponse<ClientDeliveryResponse>> findAllDeliveries(Long clientId, int pageNumber, int pageSize, String status) {
        return ResponseEntity.ok(deliveryService.findAllDeliveries(clientId, pageNumber, pageSize, status));
    }

    @Override
    public ResponseEntity<GenericResponse<ClientDeliveryResponse>> findDeliveryById(Long clientId, Long deliveryId) {
        return ResponseEntity.ok(success(deliveryService.findDeliveryById(deliveryId)));
    }

    @Override
    public ResponseEntity<GenericResponse<ClientDeliveryResponse>> createDelivery(Long clientId, ClientDeliveryRequest deliveryRequest) {
        return ResponseEntity.status(201).body(success(deliveryService.createDelivery(clientId, deliveryRequest)));
    }

    @Override
    public ResponseEntity<GenericResponse<String>> processPayment(Long clientId, DeliveryPaymentRequest paymentRequest) {
        return ResponseEntity.status(201).body(success(deliveryService.processPayment(clientId, paymentRequest)));
    }

    @Override
    public ResponseEntity<GenericResponse<String>> selectDeliveryDriver(Long clientId, SelectDriverRequest request) {
        return ResponseEntity.ok(success(deliveryService.selectDeliveryDriver(clientId, request)));
    }

    @Override
    public ResponseEntity<GenericResponse<String>> cancelDelivery(Long clientId, CancelDeliveryRequest request) {
        return ResponseEntity.ok(success(deliveryService.cancelDelivery(clientId, request)));
    }

    @Override
    public ResponseEntity<GenericResponse<String>> deleteDelivery(Long clientId, Long deliveryId) {
        return ResponseEntity.ok(success(deliveryService.deleteDelivery(clientId, deliveryId)));
    }

    @Override
    public ResponseEntity<PaginatedResponse<ClientDeliveryResponse>> findAllDeliveryHistory(Long clientId, int pageNumber, int pageSize, String status) {
        return ResponseEntity.ok(deliveryService.findAllDeliveries(clientId, pageNumber, pageSize, status));
    }

    @Override
    public ResponseEntity<List<AvailableDriverResponse>> findAvailableDrivers(Long deliveryId) {
        return ResponseEntity.ok(deliveryService.findAvailableDrivers(deliveryId));
    }

}
