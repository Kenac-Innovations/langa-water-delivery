package zw.co.kenac.takeu.backend.service.driver.impl;

import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;
import org.springframework.web.multipart.MultipartFile;
import zw.co.kenac.takeu.backend.dto.driver.DriverVehicleRequest;
import zw.co.kenac.takeu.backend.dto.driver.DriverVehicleResponse;
import zw.co.kenac.takeu.backend.exception.custom.DuplicateFoundException;
import zw.co.kenac.takeu.backend.exception.custom.FileRequiredException;
import zw.co.kenac.takeu.backend.exception.custom.IllegalAction;
import zw.co.kenac.takeu.backend.exception.custom.ResourceNotFoundException;
import zw.co.kenac.takeu.backend.model.DriverEntity;
import zw.co.kenac.takeu.backend.model.VehicleEntity;
import zw.co.kenac.takeu.backend.model.VehicleStatusEntity;
import zw.co.kenac.takeu.backend.model.VehicleTypeEntity;
import zw.co.kenac.takeu.backend.model.embedded.VehicleDocument;
import zw.co.kenac.takeu.backend.model.enumeration.GenericStatus;
import zw.co.kenac.takeu.backend.repository.DriverRepository;
import zw.co.kenac.takeu.backend.repository.VehicleRepository;
import zw.co.kenac.takeu.backend.repository.VehicleStatusRepository;
import zw.co.kenac.takeu.backend.repository.VehicleTypeRepository;
import zw.co.kenac.takeu.backend.service.MinioImageService;
import zw.co.kenac.takeu.backend.service.driver.DriverVehicleService;
import zw.co.kenac.takeu.backend.service.internal.DocumentService;

import java.util.List;
import java.util.Optional;
import java.util.function.Supplier;

import static zw.co.kenac.takeu.backend.constant.AppConstant.NOT_FOUND;

@Service
@RequiredArgsConstructor
@Slf4j
public class DriverVehicleServiceImpl implements DriverVehicleService {
    @Value("${minio.buckets.vehicle-documents}")
    private String vehicleDocumentsBucket;
    private final VehicleRepository vehicleRepository;
    private final DriverRepository driverRepository;
    private final VehicleTypeRepository typeRepository;
    private final VehicleStatusRepository statusRepository;
    private final DocumentService documentService;
    private final MinioImageService minioImageService;

    private record DocumentUpload(String bucketType, MultipartFile file, String fieldName,
                                  java.util.function.Consumer<String> entitySetter) {
    }

    @Override
    public List<DriverVehicleResponse> findAllVehicles(Long driverId) {
        return vehicleRepository.findAllByDriverId(driverId)
                .stream()
                .map(this::mapToResponse)
                .toList();
    }

    @Override
    public DriverVehicleResponse findVehicleById(Long driverId, Long vehicleId) {
        VehicleEntity vehicle = vehicleRepository.findByDriverIdAndVehicleId(driverId, vehicleId)
                .orElseThrow(() -> new ResourceNotFoundException(NOT_FOUND));
        return mapToResponse(vehicle);
    }

    @Override
    public DriverVehicleResponse createVehicle(Long driverId, DriverVehicleRequest request) {
       Optional<VehicleEntity>  vehicle1 = vehicleRepository.findByLicensePlateNo(request.licensePlateNo());
        if(vehicle1.isPresent()){
            throw  new DuplicateFoundException("Vehicle with plate number already exist ::"+request.licensePlateNo());
        }
        DriverEntity driver = driverRepository.findById(driverId)
                .orElseThrow(() -> new ResourceNotFoundException(NOT_FOUND));
        VehicleEntity vehicle = new VehicleEntity();
        vehicle.setDriver(driver);
        vehicle.setVehicleModel(request.vehicleModel());
        vehicle.setVehicleColor(request.vehicleColor());
        vehicle.setVehicleMake(request.vehicleMake());
        vehicle.setLicensePlateNo(request.licensePlateNo());
        vehicle.setActive(request.active());
        vehicle.setVehicleType(request.vehicleType());
        vehicle.setVehicleStatus(request.vehicleStatus());
        VehicleDocument vehicleDocument = VehicleDocument.builder().build();

        // Upload vehicle images to MinIO
        List<DocumentUpload> requiredDocuments = List.of(
                new DocumentUpload(
                        vehicleDocumentsBucket,
                        request.registrationBookFile(),
                        "Vehicle registration book",
                        vehicleDocument::setRegistrationBookUrl
                ),
                new DocumentUpload(
                        vehicleDocumentsBucket,
                        request.frontImageFile(),
                        "Vehicle front image",
                        vehicleDocument::setFrontImageUrl
                ),
                new DocumentUpload(
                        vehicleDocumentsBucket,
                        request.backImageFile(),
                        "Vehicle back image",
                        vehicleDocument::setBackImageUrl
                )
                ,
                new DocumentUpload(
                        vehicleDocumentsBucket,
                        request.sideImageFile(),
                        "Vehicle side image",
                        vehicleDocument::setBackImageUrl
                )
        );

        // Upload all required documents
        for (DocumentUpload doc : requiredDocuments) {
            if (doc.file() == null) {
                throw new FileRequiredException(doc.fieldName() + " is required.");
            }

            try {
                String fileUrl = documentService.uploadDocument(doc.bucketType(), doc.file());
                doc.entitySetter().accept(fileUrl);
            } catch (Exception e) {
                throw new RuntimeException("Failed to upload " + doc.fieldName() + ": " + e.getMessage(), e);
            }
        }

        // Set the vehicle document with all uploaded URLs
        vehicle.setVehicleDocument(vehicleDocument);
        VehicleEntity savedVehicle = vehicleRepository.save(vehicle);
        return mapToResponse(savedVehicle);
    }

    @Override
    public DriverVehicleResponse updateVehicle(Long driverId, Long vehicleId, DriverVehicleRequest request) {
        VehicleEntity vehicle = vehicleRepository.findByDriverIdAndVehicleId(driverId, vehicleId)
                .orElseThrow(() -> new ResourceNotFoundException(NOT_FOUND));

        // Update basic vehicle properties
        vehicle.setVehicleModel(request.vehicleModel());
        vehicle.setVehicleColor(request.vehicleColor());
        vehicle.setVehicleMake(request.vehicleMake());
        vehicle.setLicensePlateNo(request.licensePlateNo());
        vehicle.setVehicleType(request.vehicleType());
        vehicle.setVehicleStatus(request.vehicleStatus());

        // Get existing vehicle document or create new one
        VehicleDocument vehicleDocument = vehicle.getVehicleDocument() != null
                ? vehicle.getVehicleDocument()
                : VehicleDocument.builder().build();

        // List of optional document uploads (only upload if file is present)
        List<DocumentUpload> optionalDocuments = List.of(
                new DocumentUpload(
                        vehicleDocumentsBucket,
                        request.registrationBookFile(),
                        "Vehicle registration book",
                        vehicleDocument::setRegistrationBookUrl
                ),
                new DocumentUpload(
                        vehicleDocumentsBucket,
                        request.frontImageFile(),
                        "Vehicle front image",
                        vehicleDocument::setFrontImageUrl
                ),
                new DocumentUpload(
                        vehicleDocumentsBucket,
                        request.backImageFile(),
                        "Vehicle back image",
                        vehicleDocument::setBackImageUrl
                ),
                new DocumentUpload(
                        vehicleDocumentsBucket,
                        request.sideImageFile(),
                        "Vehicle side image",
                        vehicleDocument::setSideImageUrl
                )
        );

        for (DocumentUpload doc : optionalDocuments) {
            if (doc.file() != null && !doc.file().isEmpty()) {
                try {
                    String fileUrl = documentService.uploadDocument(doc.bucketType(), doc.file());
                    doc.entitySetter().accept(fileUrl);
                } catch (Exception e) {
                    throw new RuntimeException("Failed to upload " + doc.fieldName() + ": " + e.getMessage(), e);
                }
            }
        }

        vehicle.setVehicleDocument(vehicleDocument);
        VehicleEntity savedVehicle = vehicleRepository.save(vehicle);
        return mapToResponse(savedVehicle);
    }

    @Override
    public String deleteVehicle(Long driverId, Long vehicleId) {
        VehicleEntity vehicle = vehicleRepository.findByDriverIdAndVehicleId(driverId, vehicleId)
                .orElseThrow(() -> new ResourceNotFoundException(NOT_FOUND));
        vehicleRepository.delete(vehicle);
        return String.format("Vehicle with ID %d deleted successfully", vehicleId);
    }

    @Override
    public String switchVehicle(Long driverId, Long vehicleId) {
        log.info("==========> Switch vehicle with ID {}", vehicleId);
        DriverEntity driver = driverRepository.findById(driverId)
                .orElseThrow(() -> new ResourceNotFoundException(NOT_FOUND));

        VehicleEntity vehicleToActivate = vehicleRepository.findById(vehicleId)
                .orElseThrow(() -> new ResourceNotFoundException(NOT_FOUND));
        if (!vehicleToActivate.getVehicleStatus().equals(GenericStatus.APPROVED.name())) {
            throw new IllegalAction("Vehicle is not approved therefore it cannot be activated");
        }

        if (!vehicleToActivate.getDriver().getEntityId().equals(driverId)) {
            throw new IllegalAction("Vehicle does not belong to driver");
        }

        List<VehicleEntity> driverVehicles = vehicleRepository.findByDriverId(driverId);
        for (VehicleEntity vehicle : driverVehicles) {
            vehicle.setActive(vehicle.getEntityId().equals(vehicleId));
        }

        vehicleRepository.saveAll(driverVehicles);
        return "Vehicle " + vehicleId + " is now active for driver " + driverId;
    }

    private DriverVehicleResponse mapToResponse(VehicleEntity vehicle) {
        return new DriverVehicleResponse(
                vehicle.getEntityId(),
                vehicle.getVehicleModel(),
                vehicle.getVehicleColor(),
                vehicle.getVehicleMake(),
                vehicle.getLicensePlateNo(),
                vehicle.getActive(),
                vehicle.getVehicleType(),
                vehicle.getVehicleStatus(),
                String.format(" %s %s", vehicle.getDriver().getFirstname(), vehicle.getDriver().getLastname()),
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

    private VehicleTypeEntity mapToType(String type) {
        return typeRepository.findByName(type).orElseThrow(() -> new ResourceNotFoundException(NOT_FOUND));
    }

    private VehicleStatusEntity mapToStatus(String status) {
        return statusRepository.findByStatusName(status).orElseThrow(() -> new ResourceNotFoundException(NOT_FOUND));
    }
}
