package zw.co.kenac.takeu.backend.controller.driver.impl;

import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.RestController;
import zw.co.kenac.takeu.backend.controller.driver.DriverVehicleController;
import zw.co.kenac.takeu.backend.dto.GenericResponse;
import zw.co.kenac.takeu.backend.dto.driver.DriverVehicleRequest;
import zw.co.kenac.takeu.backend.dto.driver.DriverVehicleResponse;
import zw.co.kenac.takeu.backend.service.driver.DriverVehicleService;

import java.util.List;

import static zw.co.kenac.takeu.backend.dto.GenericResponse.success;

@RestController
@RequiredArgsConstructor
public class DriverVehicleControllerImpl implements DriverVehicleController {

    private final DriverVehicleService vehicleService;

    @Override
    public ResponseEntity<GenericResponse<List<DriverVehicleResponse>>> findAllVehicles(Long driverId) {
        return ResponseEntity.ok(success(vehicleService.findAllVehicles(driverId)));
    }

    @Override
    public ResponseEntity<GenericResponse<DriverVehicleResponse>> findVehicleById(Long driverId, Long vehicleId) {
        return ResponseEntity.ok(success(vehicleService.findVehicleById(driverId, vehicleId)));
    }

    @Override
    public ResponseEntity<GenericResponse<DriverVehicleResponse>> createVehicle(Long driverId, DriverVehicleRequest request) {
        return ResponseEntity.ok(success(vehicleService.createVehicle(driverId, request)));
    }

    @Override
    public ResponseEntity<GenericResponse<DriverVehicleResponse>> updateVehicle(Long driverId, Long vehicleId, DriverVehicleRequest request) {
        return ResponseEntity.ok(success(vehicleService.updateVehicle(driverId, vehicleId, request)));
    }

    @Override
    public ResponseEntity<GenericResponse<String>> deleteVehicle(Long driverId, Long vehicleId) {
        return ResponseEntity.ok(success(vehicleService.deleteVehicle(driverId, vehicleId)));
    }

    @Override
    public ResponseEntity<GenericResponse<String>> switchVehicle(Long driverId, Long vehicleId) {
        return ResponseEntity.ok(success(vehicleService.switchVehicle(driverId, vehicleId)));
    }
}
