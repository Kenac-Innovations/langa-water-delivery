package zw.co.kenac.takeu.backend.controller.driver.impl;

import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.RestController;
import zw.co.kenac.takeu.backend.controller.driver.DriverDeliveryController;
import zw.co.kenac.takeu.backend.dto.GenericResponse;
import zw.co.kenac.takeu.backend.dto.PaginatedResponse;
import zw.co.kenac.takeu.backend.dto.driver.*;
import zw.co.kenac.takeu.backend.service.driver.DriverDeliveryService;

import java.io.IOException;

import static zw.co.kenac.takeu.backend.dto.GenericResponse.success;

@RestController
@RequiredArgsConstructor
@Slf4j
public class DriverDeliveryControllerImpl implements DriverDeliveryController {

    private final DriverDeliveryService deliveryService;

    @Override
    public ResponseEntity<GenericResponse<PaginatedResponse<DriverDeliveryResponse>>> findAllDeliveries( int pageNumber, int pageSize, String status) {
        return ResponseEntity.ok(success(deliveryService.findAllDeliveries( pageNumber, pageSize, status)));
    }

    @Override
    public ResponseEntity<GenericResponse<PaginatedResponse<DriverDeliveryResponse>>> findAllDriverDeliveries(Long driverId, String status, int pageNumber, int pageSize) {
        return ResponseEntity.ok(success(deliveryService.findAllDriverDeliveries(driverId, status, pageNumber, pageSize)));
    }

    @Override
    public ResponseEntity<GenericResponse<PaginatedResponse<DriverDeliveryResponseWithProposal>>> findAllOpenDeliveriesByVehicleType(Long driverId,String status, String vehicleType, int pageNumber, int pageSize) {
        log.info("findAllOpenDeliveriesByVehicleType status {} -- vehicleType {}", status, vehicleType);
        return ResponseEntity.ok(success(deliveryService.findAllOpenDeliveriesByVehicleType(driverId,status,vehicleType,pageNumber,pageSize)));
    }

    @Override
    public ResponseEntity<GenericResponse<PaginatedResponse<DriverDeliveryResponse>>> findAllDriverAssignedDelivery(Long driverId, int pageNumber, int pageSize) {
        return ResponseEntity.ok(success(deliveryService.findAllDriverAssignedDelivery(driverId,pageNumber,pageSize)));
    }

    @Override
    public ResponseEntity<GenericResponse<DriverDeliveryResponse>> findDeliveryById(Long deliveryId) {
        return ResponseEntity.ok(success(deliveryService.findDeliveryById(deliveryId)));
    }

    @Override
    public ResponseEntity<GenericResponse<String>> proposeDelivery(Long deliveryId, DriverPromptRequest request) {
        return ResponseEntity.status(201).body(success(deliveryService.proposeDelivery(deliveryId, request)));
    }

    @Override
    public ResponseEntity<GenericResponse<String>> pickupDelivery(Long deliveryId, PickupDeliveryRequest request) throws IOException {
        return ResponseEntity.ok(success(deliveryService.pickupDelivery(deliveryId, request)));
    }

    @Override
    public ResponseEntity<GenericResponse<String>> acceptDelivery(Long deliveryId, DriverPromptRequest request) {
        return ResponseEntity.ok(success(deliveryService.acceptDelivery(deliveryId, request)));
    }

    @Override
    public ResponseEntity<GenericResponse<String>> cancelDelivery(Long deliveryId, DriverPromptRequest request) {
        return ResponseEntity.ok(success(deliveryService.cancelDelivery(deliveryId, request)));
    }

    @Override
    public ResponseEntity<GenericResponse<String>> completeDelivery(Long deliveryId, CompleteDeliveryRequest request) {
        return ResponseEntity.ok(success(deliveryService.completeDelivery(deliveryId, request)));
    }

    @Override
    public ResponseEntity<GenericResponse<String>> deleteProposal(Long deliveryId, DriverPromptRequest request) {
        return ResponseEntity.ok(success(deliveryService.deleteProposal(deliveryId, request)));
    }
}
