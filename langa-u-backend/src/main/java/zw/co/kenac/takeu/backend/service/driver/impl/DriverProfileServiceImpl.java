package zw.co.kenac.takeu.backend.service.driver.impl;

import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import zw.co.kenac.takeu.backend.dto.driver.ActiveVehicle;
import zw.co.kenac.takeu.backend.dto.driver.DriverProfile;
import zw.co.kenac.takeu.backend.exception.custom.ResourceNotFoundException;
import zw.co.kenac.takeu.backend.model.DriverEntity;
import zw.co.kenac.takeu.backend.model.VehicleEntity;
import zw.co.kenac.takeu.backend.model.enumeration.DeliveryStatus;
import zw.co.kenac.takeu.backend.repository.DeliveryRepository;
import zw.co.kenac.takeu.backend.repository.DriverRepository;
import zw.co.kenac.takeu.backend.service.MinioImageService;
import zw.co.kenac.takeu.backend.service.driver.DriverProfileService;
import zw.co.kenac.takeu.backend.service.internal.DriverRatingService;
import zw.co.kenac.takeu.backend.service.internal.DriverService;
import zw.co.kenac.takeu.backend.walletmodule.models.WalletAccount;
import zw.co.kenac.takeu.backend.walletmodule.service.WalletAccountService;

import java.util.function.Supplier;

import static zw.co.kenac.takeu.backend.constant.AppConstant.NOT_FOUND;

@Service
@RequiredArgsConstructor
public class DriverProfileServiceImpl implements DriverProfileService {

    private final DriverRepository driverRepository;
    private final WalletAccountService walletAccountService;
    private final MinioImageService minioImageService;
    private final DriverRatingService driverRatingService;
    private final DeliveryRepository deliveryRepository;

    @Override
    public DriverProfile findDriverProfile(Long driverId) {
        DriverEntity driver = driverRepository.findById(driverId)
                .orElseThrow(() -> new ResourceNotFoundException(NOT_FOUND));
        return mapToProfile(driver);
    }

    @Override
    public DriverProfile updateDriverProfile(Long driverId) {
        DriverEntity driver = driverRepository.findById(driverId)
                .orElseThrow(() -> new ResourceNotFoundException(NOT_FOUND));

        // todo add update logic

        driverRepository.save(driver);

        return mapToProfile(driver);
    }

    @Override
    public DriverProfile updateOnlineStatus(Long driverId, Boolean online) {
        DriverEntity driver = driverRepository.findById(driverId)
                .orElseThrow(() -> new ResourceNotFoundException(NOT_FOUND));

        driver.setOnlineStatus(online);
        driverRepository.save(driver);

        return mapToProfile(driver);
    }


    @Override
    public String updateDriverAvailability(Long driverId, Boolean availability) {
        DriverEntity driver = driverRepository.findById(driverId).orElseThrow(() -> new ResourceNotFoundException("Driver not found with id: " + driverId));
        driver.setIsBusy(availability);
        driverRepository.save(driver);
        return availability ? "Driver is busy on a delivery" : "Driver not busy";
    }


    @Override
    public DriverProfile updateDeliverySearchRadius(Long driverId, Double deliverySearchRadius) {
        DriverEntity driver = driverRepository.findById(driverId)
                .orElseThrow(() -> new ResourceNotFoundException(NOT_FOUND));

        driver.setSearchRadiusInKm(deliverySearchRadius);
        driverRepository.save(driver);

        return mapToProfile(driver);
    }

    @Override
    public String deleteAccount(Long driverId) {
        return "";//
    }

    private DriverProfile mapToProfile(DriverEntity driver) {
        VehicleEntity vehicle = driver.findActiveVehicle();
        WalletAccount walletAccount = walletAccountService.findWalletAccountByDriverId(driver.getEntityId());

        return new DriverProfile(
                driver.getEntityId(),
                driver.getFirstname(),
                driver.getLastname(),
                driver.getMiddleName(),
                driver.getGender(),
                driver.getMobileNumber(),
                driver.getEmail(),
                driver.getAddress(),
                driver.getNationalIdNo(),
                driver.getDriverLicenseNo(),
                driver.getApprovalStatus(),
                driver.getApprovedBy(),
                driver.getDateApproved(),
                minioImageService.generateProfilePhotoUrl(driver.getProfilePhotoUrl()),
//                minioImageService.generateNationalIdImageUrl(driver.getNationalIdImage()),
//                minioImageService.generateDriversLicenseUrl(driver.getDriversLicenseUrl()),
                "","",
                driver.getUserEntity() != null ? driver.getUserEntity().getEntityId() : null,
                walletAccount != null ? walletAccount.getId() : null,
                vehicle != null ? new ActiveVehicle(
                        vehicle.getEntityId(),
                        vehicle.getVehicleModel(),
                        vehicle.getVehicleColor(),
                        vehicle.getVehicleMake(),
                        vehicle.getLicensePlateNo(),
                        vehicle.getVehicleType(),
                        safeGenerateUrl(() -> vehicle.getVehicleDocument().getFrontImageUrl()),
                        safeGenerateUrl(() -> vehicle.getVehicleDocument().getSideImageUrl()),
                        safeGenerateUrl(() -> vehicle.getVehicleDocument().getRegistrationBookUrl())

                ) : null,
                driver.getOnlineStatus(),
                driver.getSearchRadiusInKm(),
                driverRatingService.calculateAverageRating(driver.getEntityId()),
                deliveryRepository.findTotalNumberOfCompleteDeliveryByDriver(DeliveryStatus.COMPLETED.name(), driver.getEntityId()).orElse(0)
                , driver.getIsBusy()==null? false:driver.getIsBusy()


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
