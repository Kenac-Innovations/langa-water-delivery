package zw.co.kenac.takeu.backend.controller.internal.impl;

import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.RestController;
import zw.co.kenac.takeu.backend.controller.internal.VehicleController;
import zw.co.kenac.takeu.backend.dto.GenericResponse;
import zw.co.kenac.takeu.backend.dto.PaginatedResponse;
import zw.co.kenac.takeu.backend.dto.auth.internal.DriverApprovalRequest;
import zw.co.kenac.takeu.backend.dto.internal.SuspendRequest;
import zw.co.kenac.takeu.backend.dto.internal.VehicleResponse;
import zw.co.kenac.takeu.backend.service.internal.VehicleService;

import static zw.co.kenac.takeu.backend.dto.GenericResponse.success;

/**
 * @author : Jaison.Chipuka
 * @email : jaisonc@kenac.co.zw
 * @project : take-u-backend on 6/5/2025
 */
@RestController
@RequiredArgsConstructor
public class VehicleControllerImpl implements VehicleController {

    private final VehicleService vehicleService;

    @Override
    public ResponseEntity<PaginatedResponse<VehicleResponse>> findAllVehicles(int pageNumber, int pageSize, String vehicleType) {
        return ResponseEntity.ok(vehicleService.findAllVehicles(pageNumber, pageSize, vehicleType));
    }

    @Override
    public ResponseEntity<PaginatedResponse<VehicleResponse>> findAllVehiclesByDriver(Long driverId, int pageNumber, int pageSize) {
        return ResponseEntity.ok(vehicleService.findVehiclesByDriver(driverId, pageNumber, pageSize));
    }

    @Override
    public ResponseEntity<GenericResponse<VehicleResponse>> findAllVehiclesById(Long vehicleId) {
        return ResponseEntity.ok(success(vehicleService.findVehicleById(vehicleId)));
    }

    @Override
    public ResponseEntity<GenericResponse<String>> approveVehicle(Long vehicleId, DriverApprovalRequest request) {
        return ResponseEntity.ok(success(vehicleService.approveVehicle(vehicleId, request)));
    }

    @Override
    public ResponseEntity<GenericResponse<String>> suspendVehicle(Long vehicleId, SuspendRequest request) {
        return ResponseEntity.ok(success(vehicleService.suspendVehicle(vehicleId, request)));
    }
}