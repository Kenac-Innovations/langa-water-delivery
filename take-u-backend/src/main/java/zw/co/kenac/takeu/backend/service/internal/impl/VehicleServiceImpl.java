package zw.co.kenac.takeu.backend.service.internal.impl;

import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageRequest;
import org.springframework.data.domain.Pageable;
import org.springframework.stereotype.Service;
import zw.co.kenac.takeu.backend.dto.CustomPagination;
import zw.co.kenac.takeu.backend.dto.PaginatedResponse;
import zw.co.kenac.takeu.backend.dto.auth.internal.DriverApprovalRequest;
import zw.co.kenac.takeu.backend.dto.driver.DriverProfile;
import zw.co.kenac.takeu.backend.dto.internal.DriverResponse;
import zw.co.kenac.takeu.backend.dto.internal.SuspendRequest;
import zw.co.kenac.takeu.backend.dto.internal.VehicleResponse;
import zw.co.kenac.takeu.backend.exception.custom.ResourceNotFoundException;
import zw.co.kenac.takeu.backend.model.DriverEntity;
import zw.co.kenac.takeu.backend.model.VehicleEntity;
import zw.co.kenac.takeu.backend.repository.DriverRepository;
import zw.co.kenac.takeu.backend.repository.VehicleRepository;
import zw.co.kenac.takeu.backend.service.MinioImageService;
import zw.co.kenac.takeu.backend.service.internal.VehicleService;
import zw.co.kenac.takeu.backend.walletmodule.models.WalletAccount;

import java.time.LocalDateTime;
import java.util.List;
import java.util.function.Supplier;

/**
 * @author : Jaison.Chipuka
 * @email : jaisonc@kenac.co.zw
 * @project : take-u-backend on 6/5/2025
 */
@Service
@RequiredArgsConstructor
public class VehicleServiceImpl implements VehicleService {

    private final VehicleRepository vehicleRepository;
    private final DriverRepository driverRepository;
    private final MinioImageService minioImageService;

    @Override
    public PaginatedResponse<VehicleResponse> findAllVehicles(int pageNumber, int pageSize, String vehicleType) {
        Pageable pageable = PageRequest.of(pageNumber - 1, pageSize);

        if (vehicleType.equalsIgnoreCase("ALL")) {
            Page<VehicleEntity> vehicles = vehicleRepository.findAll(pageable);
            System.out.println("Fetching all vehicles method 1: " + vehicles.getTotalElements() + " found.");
            return paginateResponse(vehicles);
        }

        Page<VehicleEntity> vehicles = vehicleRepository.findAllByVehicleType(pageable, vehicleType);
        System.out.println("Fetching all vehicles method 2: " + vehicles.getTotalElements() + " found.");
        return paginateResponse(vehicles);
    }

    @Override
    public PaginatedResponse<VehicleResponse> findVehiclesByDriver(Long driverId, int pageNumber, int pageSize) {
        DriverEntity driver = driverRepository.findById(driverId).orElseThrow(() -> new ResourceNotFoundException("Driver not found with ID: " + driverId));
        Pageable pageable = PageRequest.of(pageNumber - 1, pageSize);
        Page<VehicleEntity> vehicles = vehicleRepository.findAllByDriver(pageable, driver);
        return paginateResponse(vehicles);
    }

    @Override
    public VehicleResponse findVehicleById(Long vehicleId) {
        VehicleEntity vehicle = vehicleRepository.findById(vehicleId).orElseThrow(() -> new ResourceNotFoundException("Vehicle not found with ID: " + vehicleId));
        return mapToResponse(vehicle);
    }

    @Override
    public String approveVehicle(Long vehicleId, DriverApprovalRequest request) {
        VehicleEntity vehicle = vehicleRepository.findById(vehicleId).orElseThrow(() -> new ResourceNotFoundException("Vehicle not found with ID: " + vehicleId));
        vehicle.setVehicleStatus(request.status().name());
        vehicle.setApprovedBy(request.approvedBy());
        vehicle.setApprovedOn(LocalDateTime.now());
        vehicle.setApprovalNotes(request.reason());
        vehicleRepository.save(vehicle);
        return String.format("Vehicle with ID %d has been %s by %s.", vehicleId, request.status(), request.approvedBy());
    }

    @Override
    public String suspendVehicle(Long vehicleId, SuspendRequest request) {
        VehicleEntity vehicle = vehicleRepository.findById(vehicleId).orElseThrow(() -> new ResourceNotFoundException("Vehicle not found with ID: " + vehicleId));
        vehicle.setVehicleStatus(request.status());
        vehicle.setApprovedOn(LocalDateTime.now());
        vehicle.setApprovalNotes(request.reason());
        vehicleRepository.save(vehicle);
        return String.format("Vehicle with ID %d has been %s by %s.", vehicleId, request.status(), request.suspendedBy());
    }

    public PaginatedResponse<VehicleResponse> paginateResponse(Page<VehicleEntity> page) {
        List<VehicleEntity> vehicles = page.getContent();

        List<VehicleResponse> mappedVehicles = vehicles.stream()
                .map(this::mapToResponse)
                .toList();

        CustomPagination pagination = new CustomPagination(
                page.getTotalElements(),
                page.getTotalPages(),
                page.getNumber() + 1,
                page.getSize()
        );

        return new PaginatedResponse<>(mappedVehicles, pagination);
    }

    private VehicleResponse mapToResponse(VehicleEntity vehicle) {
        return new VehicleResponse(
                vehicle.getEntityId(),
                vehicle.getVehicleModel(),
                vehicle.getVehicleColor(),
                vehicle.getVehicleMake(),
                vehicle.getLicensePlateNo(),
                vehicle.getActive(),
                vehicle.getVehicleType(),
                vehicle.getVehicleStatus(),
                vehicle.getDriver() != null ? vehicle.getDriver().getEntityId() : null,
                vehicle.getDriver() != null ? vehicle.getDriver().getFirstname() + vehicle.getDriver().getLastname() : null,
                safeGenerateUrl(() -> vehicle.getVehicleDocument().getRegistrationBookUrl()),
                safeGenerateUrl(() -> vehicle.getVehicleDocument().getFrontImageUrl()),
                safeGenerateUrl(() -> vehicle.getVehicleDocument().getBackImageUrl()),
                safeGenerateUrl(() -> vehicle.getVehicleDocument().getSideImageUrl())

        );
    }
    private String safeGenerateUrl(Supplier<String> urlSupplier) {
        try {
            String url = urlSupplier.get();
            return url != null ? minioImageService.generateVehicleDocumentsUrl(url) : null;
        } catch (NullPointerException e) {
            return null;
        }
    }
}
