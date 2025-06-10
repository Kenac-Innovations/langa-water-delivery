package zw.co.kenac.takeu.backend.service.internal.impl;

import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import lombok.extern.slf4j.Slf4j;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageRequest;
import org.springframework.data.domain.Pageable;
import org.springframework.stereotype.Service;
import zw.co.kenac.takeu.backend.dto.CustomPagination;
import zw.co.kenac.takeu.backend.dto.PaginatedResponse;
import zw.co.kenac.takeu.backend.dto.auth.internal.DriverApprovalRequest;
import zw.co.kenac.takeu.backend.dto.driver.ActiveVehicle;
import zw.co.kenac.takeu.backend.dto.driver.DriverProfile;
import zw.co.kenac.takeu.backend.dto.driver.ReviewDriverProfileDto;
import zw.co.kenac.takeu.backend.exception.custom.ResourceNotFoundException;
import zw.co.kenac.takeu.backend.mailer.JavaMailService;
import zw.co.kenac.takeu.backend.mailer.dto.EmailGenericDto;
import zw.co.kenac.takeu.backend.mailer.templates.MailTemplates;
import zw.co.kenac.takeu.backend.model.DriverEntity;
import zw.co.kenac.takeu.backend.model.UserEntity;
import zw.co.kenac.takeu.backend.model.VehicleEntity;
import zw.co.kenac.takeu.backend.model.enumeration.DeliveryStatus;
import zw.co.kenac.takeu.backend.repository.DeliveryRepository;
import zw.co.kenac.takeu.backend.repository.DriverRepository;
import zw.co.kenac.takeu.backend.repository.UserRepository;
import zw.co.kenac.takeu.backend.service.MinioImageService;
import zw.co.kenac.takeu.backend.service.driver.DriverDeliveryService;
import zw.co.kenac.takeu.backend.service.internal.DriverRatingService;
import zw.co.kenac.takeu.backend.service.internal.DriverService;
import zw.co.kenac.takeu.backend.walletmodule.service.WalletAccountService;

import java.time.LocalDateTime;
import java.util.List;
import java.util.function.Supplier;

import static zw.co.kenac.takeu.backend.constant.AppConstant.NOT_FOUND;

/**
 * @author : Jaison.Chipuka
 * @email : jaisonc@kenac.co.zw
 * @project : take-u-backend on 5/5/2025
 */
@Slf4j
@Service
@RequiredArgsConstructor
public class DriverServiceImpl implements DriverService {

    private final DriverRepository driverRepository;
    private final WalletAccountService walletAccountService;
    private final UserRepository userRepository;
    private final JavaMailService javaMailService;
    private final MinioImageService minioImageService;
    private final DeliveryRepository deliveryRepository;
    private final DriverRatingService driverRatingService;
    private final DriverDeliveryService driverDeliveryService;

    @Override
    public PaginatedResponse<DriverProfile> findAllDrivers(int pageNumber, int pageSize, String status) {
        Pageable pageable = PageRequest.of(pageNumber - 1, pageSize);

        if (status.equalsIgnoreCase("ALL")) {
            Page<DriverEntity> drivers = driverRepository.findAll(pageable);
            return paginateResponse(drivers);
        }

        Page<DriverEntity> drivers = driverRepository.findAllByApprovalStatus(pageable, status);
        return paginateResponse(drivers);
    }

    @Override
    public DriverProfile findDriverById(Long driverId) {
        DriverEntity driver = driverRepository.findById(driverId)
                .orElseThrow(() -> new ResourceNotFoundException(NOT_FOUND));
        //WalletAccount walletAccount = walletAccountService.findWalletAccountByDriverId(driver.getEntityId());
        return mapToProfile(driver);
    }

    @Override
    public String approveDriver(Long driverId, DriverApprovalRequest request) {
        DriverEntity driver = driverRepository.findById(driverId)
                .orElseThrow(() -> new ResourceNotFoundException(NOT_FOUND));

        driver.setApprovalStatus(request.status().name());
        driver.setApprovedBy(request.approvedBy());
        driver.setDateApproved(LocalDateTime.now());
        driver.setApprovalReason(request.reason());

        walletAccountService.initializeDriverWallets(driver.getEntityId());

        return "Record has been updated successfully.";
    }


    @Override
    public String deleteDriver(Long driverId) {
        DriverEntity driver = driverRepository.findById(driverId)
                .orElseThrow(() -> new ResourceNotFoundException(NOT_FOUND));
        UserEntity user = driver.getUserEntity();
        driverRepository.delete(driver);
        userRepository.delete(user);
        return "Driver account has been deleted successfully.";
    }



    
    private DriverProfile mapToProfile(DriverEntity driver) {

        VehicleEntity vehicle = driver.findActiveVehicle();

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
                minioImageService.generateNationalIdImageUrl(driver.getNationalIdImage()),
                minioImageService.generateDriversLicenseUrl(driver.getDriversLicenseUrl()),
                driver.getUserEntity() != null ? driver.getUserEntity().getEntityId() : null,
                driver.getWallet()!=null? driver.getWallet().getId():null,
                vehicle != null ? new ActiveVehicle(
                        vehicle.getEntityId(),
                        vehicle.getVehicleModel(),
                        vehicle.getVehicleColor(),
                        vehicle.getVehicleMake(),
                        vehicle.getLicensePlateNo(),

                        //vehicle.getVehicleType().getName()
                        vehicle.getVehicleType(),
                        safeGenerateUrl(() -> vehicle.getVehicleDocument().getFrontImageUrl()),
                        safeGenerateUrl(() -> vehicle.getVehicleDocument().getSideImageUrl()),
                        safeGenerateUrl(() -> vehicle.getVehicleDocument().getRegistrationBookUrl())

                ) : null,
                driver.getOnlineStatus(),
                driver.getSearchRadiusInKm(),
                driverRatingService.calculateAverageRating(driver.getEntityId()),
                deliveryRepository.findTotalNumberOfCompleteDeliveryByDriver(DeliveryStatus.COMPLETED.name(), driver.getEntityId()).orElse(0)
                ,driver.getIsBusy()==null?false:driver.getIsBusy()

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

    public PaginatedResponse<DriverProfile> paginateResponse(Page<DriverEntity> page) {
        List<DriverEntity> drivers = page.getContent();


        List<DriverProfile> mappedDrivers = drivers.stream()
                .map(this::mapToProfile)
                .toList();

        CustomPagination pagination = new CustomPagination(
                page.getTotalElements(),
                page.getTotalPages(),
                page.getNumber() + 1,
                page.getSize()
        );

        return new PaginatedResponse<>(mappedDrivers, pagination);
    }

    @Override
    public DriverEntity reviewDriverProfile(ReviewDriverProfileDto reviewDriverProfileDto) {
        DriverEntity driver = driverRepository.findById(reviewDriverProfileDto.driverId()).orElseThrow(() -> new ResourceNotFoundException(NOT_FOUND));
        driver.setApprovalStatus(reviewDriverProfileDto.status());
        driver.setApprovalReason(reviewDriverProfileDto.reason());
        driver.setIsBusy(false);
        driver.setIsOnline(false);


        if (driver.getWallet() == null && reviewDriverProfileDto.status().equals("APPROVED")) {

            driver.setWallet(walletAccountService.initializeDriverWallets(driver.getEntityId()));

        }
        DriverEntity driverEntity = driverRepository.save(driver);


        String driverName = driver.getFirstname() + " " + driver.getLastname();
        String driverEmail = driver.getEmail();

        if (driverEmail != null && !driverEmail.isEmpty()) {
            String emailTemplate = MailTemplates.generateDriverProfileReviewTemplate(
                    driverName,
                    reviewDriverProfileDto.status(),
                    reviewDriverProfileDto.reason()
            );
            EmailGenericDto emailDto = EmailGenericDto.builder()
                    .recipient(driverEmail)
                    .subject(reviewDriverProfileDto.status().equals("APPROVED") ?
                            "Your Driver Profile Has Been Approved" :
                            "Action Required: Driver Profile Update Needed")
                    .body(emailTemplate)
                    .build();

            javaMailService.sendGenericEmail(emailDto);
        }

        return driverEntity;
    }
}
