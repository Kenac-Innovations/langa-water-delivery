package zw.co.kenac.takeu.backend.controller.internal.impl;

import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.RestController;
import zw.co.kenac.takeu.backend.controller.internal.DriverController;
import zw.co.kenac.takeu.backend.dto.GenericResponse;
import zw.co.kenac.takeu.backend.dto.driver.DriverProfile;
import zw.co.kenac.takeu.backend.dto.driver.ReviewDriverProfileDto;
import zw.co.kenac.takeu.backend.model.DriverEntity;
import zw.co.kenac.takeu.backend.dto.GenericResponse;
import zw.co.kenac.takeu.backend.dto.PaginatedResponse;
import zw.co.kenac.takeu.backend.dto.auth.internal.DriverApprovalRequest;
import zw.co.kenac.takeu.backend.dto.driver.DriverProfile;
import zw.co.kenac.takeu.backend.service.internal.DriverService;

import static zw.co.kenac.takeu.backend.dto.GenericResponse.success;

import java.util.List;

import static zw.co.kenac.takeu.backend.dto.GenericResponse.success;

/**
 * @author : Jaison.Chipuka
 * @email : jaisonc@kenac.co.zw
 * @project : take-u-backend on 6/5/2025
 */
@RestController
@RequiredArgsConstructor
public class DriverControllerImpl implements DriverController {

    private final DriverService driverService;

    @Override
    public ResponseEntity<GenericResponse<PaginatedResponse<DriverProfile>>> filterDriversByStatus(String status, int pageNumber, int pageSize) {
        return ResponseEntity.ok(success(driverService.findAllDrivers(pageNumber, pageSize, status)));
    }

    @Override
    public ResponseEntity<GenericResponse< PaginatedResponse<DriverProfile>>> findAllDrivers(int pageNumber, int pageSize, String status) {
        return ResponseEntity.ok(success( driverService.findAllDrivers(pageNumber, pageSize, status)));
    }

    @Override
    public ResponseEntity<GenericResponse<DriverProfile>> findDriverById(Long driverId) {
        return ResponseEntity.ok(success(driverService.findDriverById(driverId)));
    }




    public ResponseEntity<?> approveDriverProfile(Long driverId) {
        return null;
    }

    @Override
    public ResponseEntity<GenericResponse<String>> approveDriverProfile(Long driverId, DriverApprovalRequest request) {
        return ResponseEntity.ok(success(driverService.approveDriver(driverId, request)));
    }

    @Override
    public ResponseEntity<GenericResponse<DriverProfile>> updateDriverProfile(Long driverId, Object driverProfile) {
        return null;
    }

    @Override
    public ResponseEntity<GenericResponse<String>> deleteDriverProfile(Long driverId) {
        return ResponseEntity.ok(success(driverService.deleteDriver(driverId)));
    }

    @Override
    public ResponseEntity<GenericResponse<DriverEntity>> reviewDriverProfile(ReviewDriverProfileDto reviewDriverProfileDto) {
        return ResponseEntity.ok(success(driverService.reviewDriverProfile(reviewDriverProfileDto)));
    }
}
