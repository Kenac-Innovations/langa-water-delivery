package zw.co.kenac.takeu.backend.service.driver.impl;

import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.context.ApplicationEventPublisher;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageRequest;
import org.springframework.data.domain.Pageable;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.util.StringUtils;
import org.springframework.web.multipart.MultipartFile;
import zw.co.kenac.takeu.backend.dto.*;
import zw.co.kenac.takeu.backend.dto.driver.*;
import zw.co.kenac.takeu.backend.event.deliveryEvents.DeliveryCompletedEvent;
import zw.co.kenac.takeu.backend.event.deliveryEvents.DeliveryPickedUpEvent;
import zw.co.kenac.takeu.backend.event.deliveryEvents.DriverDeliveryCancelEvents;
import zw.co.kenac.takeu.backend.event.deliveryproposalevents.ProposalCreatedEvent;
import zw.co.kenac.takeu.backend.exception.custom.*;
import zw.co.kenac.takeu.backend.mailer.JavaMailService;
import zw.co.kenac.takeu.backend.model.*;
import zw.co.kenac.takeu.backend.model.enumeration.DeliveryStatus;
import zw.co.kenac.takeu.backend.model.enumeration.TransactionStatus;
import zw.co.kenac.takeu.backend.repository.*;
import zw.co.kenac.takeu.backend.service.MinioImageService;
import zw.co.kenac.takeu.backend.service.driver.DriverDeliveryService;
import zw.co.kenac.takeu.backend.service.internal.CommissionService;
import zw.co.kenac.takeu.backend.walletmodule.dto.ProcessPaymentResponseDTO;
import zw.co.kenac.takeu.backend.walletmodule.dto.WalletBalancesResponseDto;
import zw.co.kenac.takeu.backend.walletmodule.models.Currencies;
import zw.co.kenac.takeu.backend.walletmodule.repo.CurrenciesRepo;
import zw.co.kenac.takeu.backend.walletmodule.service.TransactionService;
import zw.co.kenac.takeu.backend.walletmodule.service.WalletAccountService;

import java.io.File;
import java.io.IOException;
import java.math.BigDecimal;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.nio.file.StandardCopyOption;
import java.text.SimpleDateFormat;
import java.time.LocalDateTime;
import java.util.Date;
import java.util.List;

import static zw.co.kenac.takeu.backend.constant.AppConstant.NOT_FOUND;

@Slf4j
@Service
@RequiredArgsConstructor
@Transactional
public class DriverDeliveryServiceImpl implements DriverDeliveryService {

    private final DeliveryRepository deliveryRepository;
    private final DriverRepository driverRepository;
    private final AvailableDriverRepository availableDriverRepository;
    private final DropOffRepository dropOffRepository;
    private final PickupRepository pickupRepository;
    private final WalletAccountService walletAccountService;
    private final JavaMailService javaMailService;
    private final CurrenciesRepo currenciesRepo;
    private final CommissionService commissionService;
    private final TransactionService transactionService;
    private final ApplicationEventPublisher eventPublisher;
    private final MinioImageService minioImageService;
    @Value("${app.config.driver-proposals-limit}")
    private  Integer driverProposalLimits;

    @Override
    public PaginatedResponse<DriverDeliveryResponse> findAllDeliveries(int pageNumber, int pageSize, String status) {
        Pageable pageable = PageRequest.of(pageNumber - 1, pageSize);

        if (status.equals("ALL")) {
            Page<DeliveryEntity> deliveries = deliveryRepository.findAll(pageable);
            return paginateResponse(deliveries);
        } else {
            Page<DeliveryEntity> deliveries = deliveryRepository.findAllByStatus(pageable, status);
            return paginateResponse(deliveries);
        }
    }

    @Override
    public PaginatedResponse<DriverDeliveryResponse> findAllDriverDeliveries(Long driverId, String status, int pageNumber, int pageSize) {
        Pageable pageable = PageRequest.of(pageNumber - 1, pageSize);
        if (status == null || status.equals("ALL")) {
            Page<DeliveryEntity> deliveries = deliveryRepository.findDeliveryEntityByDriverId(pageable, driverId);
            return paginateResponse(deliveries);
        } else {
            Page<DeliveryEntity> deliveries = deliveryRepository.findAllByDriverIdAndStatus(pageable, driverId, status);
            return paginateResponse(deliveries);
        }

    }

    //    @Override
//    public PaginatedResponse<DriverDeliveryResponse> findAllOpenDeliveriesByVehicleType(Long driverId,String status, String vehicleType, int pageNumber, int pageSize) {
//        Pageable pageable = PageRequest.of(pageNumber - 1, pageSize);
//        Page<DeliveryEntity> deliveries = deliveryRepository.findAllDeliveriesByStatusAndVehicleType(pageable, status, vehicleType);
//        List<Long> proposedBids = availableDriverRepository.findAllProposedUnAssignedDeliveryIdsForDriver(driverId);
//        return paginateResponse(deliveries);
//    }
    @Override
    public PaginatedResponse<DriverDeliveryResponseWithProposal> findAllOpenDeliveriesByVehicleType(Long driverId, String status, String vehicleType, int pageNumber, int pageSize) {
        Pageable pageable = PageRequest.of(pageNumber - 1, pageSize);
        Page<DeliveryEntity> deliveries = deliveryRepository.findAllDeliveriesByStatusAndVehicleType(pageable, status, vehicleType);
        List<Long> proposedBids = availableDriverRepository.findAllProposedUnAssignedDeliveryIdsForDriver(driverId);
        return paginateResponseWithProposal(deliveries, proposedBids);
    }

    public PaginatedResponse<DriverDeliveryResponseWithProposal> paginateResponseWithProposal(Page<DeliveryEntity> page, List<Long> proposedBids) {
        List<DeliveryEntity> deliveries = page.getContent();

        List<DriverDeliveryResponseWithProposal> driverDeliveryResponses = deliveries.stream()
                .map(delivery -> mapToDriverDeliveryResponseWithProposal(delivery, proposedBids))
                .toList();

        CustomPagination pagination = new CustomPagination(
                page.getTotalElements(),
                page.getTotalPages(),
                page.getNumber() + 1,
                page.getSize()
        );

        return new PaginatedResponse<>(driverDeliveryResponses, pagination);
    }

    private DriverDeliveryResponseWithProposal mapToDriverDeliveryResponseWithProposal(DeliveryEntity delivery, List<Long> proposedBids) {
        return new DriverDeliveryResponseWithProposal(
                delivery.getEntityId(),
                delivery.getPriceAmount(),
                delivery.getPayment().getCurrency(),
                delivery.getSensitivity(),
                delivery.getPayment().getPaymentStatus(),
                delivery.getPickupLocation().getPickupLatitude(),
                delivery.getPickupLocation().getPickupLongitude(),
                delivery.getPickupLocation().getPickupLocation(),
                delivery.getPickupLocation().getPickupContactName(),
                delivery.getPickupLocation().getPickupContactPhone(),
                delivery.getDropOffLocation().getDropOffLatitude(),
                delivery.getDropOffLocation().getDropOffLongitude(),
                delivery.getDropOffLocation().getDropOffLocation(),
                delivery.getDropOffLocation().getDropOffContactName(),
                delivery.getDropOffLocation().getDropOffContactPhone(),
                delivery.getDeliveryInstructions(),
                delivery.getParcelDescription(),
                delivery.getVehicleType(),
                delivery.getPayment().getPaymentMethod(),
                delivery.getPackageWeight(),
                delivery.getDeliveryStatus(),
                delivery.getCommissionRequired(),
                delivery.getCustomer() != null ? new DeliveryClientResponse(
                        delivery.getCustomer().getEntityId(),
                        delivery.getCustomer().getFullName(),
                        delivery.getCustomer().getLastname(),
                        delivery.getCustomer().getMobileNumber(),
                        delivery.getCustomer().getEmailAddress()
                ) : null,
                delivery.getVehicle() != null ? new DeliveryVehicleResponse(
                        delivery.getVehicle().getEntityId(),
                        delivery.getVehicle().getVehicleModel(),
                        delivery.getVehicle().getVehicleColor(),
                        delivery.getVehicle().getVehicleMake(),
                        delivery.getVehicle().getLicensePlateNo(),
                        delivery.getVehicle().getVehicleType()
                ) : null,
                proposedBids.contains(delivery.getEntityId()) // Set isProposed based on whether delivery ID is in proposedBids list
        );
    }


    @Override
    public PaginatedResponse<DriverDeliveryResponse> findAllDriverAssignedDelivery(Long driverId, int pageNumber, int pageSize) {
        DriverEntity driver = driverRepository.findById(driverId).orElseThrow(ResourceNotFoundException::new);
        Pageable pageable = PageRequest.of(pageNumber - 1, pageSize);
        Page<DeliveryEntity> deliveries = deliveryRepository.findAllDeliveriesAssignedToDriver(pageable, driverId, DeliveryStatus.ASSIGNED.name(), DeliveryStatus.PICKED_UP.name());
        return paginateResponse(deliveries);
    }

    @Override
    public DriverDeliveryResponse findDeliveryById(Long deliveryId) {
        DeliveryEntity delivery = deliveryRepository.findById(deliveryId)
                .orElseThrow(() -> new ResourceNotFoundException(NOT_FOUND));
        return mapToDriverDeliveryResponse(delivery);
    }

    private DriverDeliveryResponse mapToDriverDeliveryResponse(DeliveryEntity delivery) {
        return new DriverDeliveryResponse(
                delivery.getEntityId(),
                delivery.getPriceAmount(),
                delivery.getPayment().getCurrency(),
                delivery.getSensitivity(),
                delivery.getPayment().getPaymentStatus(),
                delivery.getPickupLocation().getPickupLatitude(),
                delivery.getPickupLocation().getPickupLongitude(),
                delivery.getPickupLocation().getPickupLocation(),
                delivery.getPickupLocation().getPickupContactName(),
                delivery.getPickupLocation().getPickupContactPhone(),
                delivery.getDropOffLocation().getDropOffLatitude(),
                delivery.getDropOffLocation().getDropOffLongitude(),
                delivery.getDropOffLocation().getDropOffLocation(),
                delivery.getDropOffLocation().getDropOffContactName(),
                delivery.getDropOffLocation().getDropOffContactPhone(),
                delivery.getDeliveryInstructions(),
                delivery.getParcelDescription(),
                delivery.getVehicleType(),
                delivery.getPayment().getPaymentMethod(),
                delivery.getPackageWeight(),
                delivery.getDeliveryStatus(),
                delivery.getCommissionRequired(),
                delivery.getCustomer() != null ? new DeliveryClientResponse(
                        delivery.getCustomer().getEntityId(),
                        delivery.getCustomer().getFullName(),
                        delivery.getCustomer().getLastname(),
                        delivery.getCustomer().getMobileNumber(),
                        delivery.getCustomer().getEmailAddress()
                ) : null,
                delivery.getVehicle() != null ? new DeliveryVehicleResponse(
                        delivery.getVehicle().getEntityId(),
                        delivery.getVehicle().getVehicleModel(),
                        delivery.getVehicle().getVehicleColor(),
                        delivery.getVehicle().getVehicleMake(),
                        delivery.getVehicle().getLicensePlateNo(),
                        delivery.getVehicle().getVehicleType()
                ) : null,
                delivery.getIsScheduled()
                , delivery.getPickUpTime()
                , delivery.getCreatedAt()
                , delivery.getUpdatedAt()
        );
    }

    @Override
    public String proposeDelivery(Long deliveryId, DriverPromptRequest request) {

        List<AvailableDriverEntity> availableDriverEntityList = availableDriverRepository.checkIfDriverHasOpenProposalForDelivery(request.driverId(), deliveryId);
        log.info("=====> check this driver has open proposal for driver id: {}", availableDriverEntityList.toString());
        if (!availableDriverEntityList.isEmpty()) {
            return "Delivery has already been proposed";
        }

        // get the current number of proposal
        Long currentDriverProposals = availableDriverRepository.getCountOfDriverOpenProposals(deliveryId);
        if(currentDriverProposals>=driverProposalLimits){
            throw new DriverProposalLimitExceededException("You reached your limit on OPEN proposal at a given time");
        }

        DeliveryEntity delivery = deliveryRepository.findById(deliveryId).orElseThrow(() -> new ResourceNotFoundException(NOT_FOUND));
        DriverEntity driver = driverRepository.findById(request.driverId()).orElseThrow(() -> new ResourceNotFoundException(NOT_FOUND));
        Currencies currencies = currenciesRepo.findByName(delivery.getPayment().getCurrency().toUpperCase()).orElseThrow(() -> new ResourceNotFoundException("Currency not found with name " + delivery.getPayment().getCurrency()));

        WalletBalancesResponseDto balance = walletAccountService.getDriverOperationFloatBalance(
                driver.getEntityId(), currencies.getId()
        );

        // Use the pre-calculated commission amount from the delivery entity
        BigDecimal commission = delivery.getCommissionRequired();

        // If commission hasn't been calculated yet, calculate it now
        if (commission == null) {
            commission = commissionService.calculateCommissionForAmount(delivery.getPriceAmount());
            delivery.setCommissionRequired(commission);
            deliveryRepository.save(delivery);
        }

        if (balance.runningBalance().compareTo(commission) < 0) {
            throw new InsufficientFundsException("Insufficient funds to bid this delivery.");
        }

        VehicleEntity vehicle = driver.findActiveVehicle();

        AvailableDriverEntity propose = new AvailableDriverEntity();
        propose.setLatitude(request.latitude());
        propose.setLongitude(request.longitude());
       // propose.setDelivery(delivery);
        propose.setStatus(DeliveryStatus.OPEN.name());
        propose.setDriver(driver);
        propose.setVehicle(vehicle);
        //propose.setDelivery(delivery);
        AvailableDriverEntity availableDriver = availableDriverRepository.save(propose);
        eventPublisher.publishEvent(new ProposalCreatedEvent(this, mapToDriverDeliveryProposalDto(availableDriver)));

        return "Proposal sent successfully";
    }

    @Override
    public String acceptDelivery(Long deliveryId, DriverPromptRequest request) {
        DeliveryEntity delivery = deliveryRepository.findById(deliveryId)
                .orElseThrow(() -> new ResourceNotFoundException(NOT_FOUND));

        DriverEntity driver = driverRepository.findById(request.driverId())
                .orElseThrow(() -> new ResourceNotFoundException(NOT_FOUND));

        delivery.setDriver(driver);
        return "Delivery request has been accepted.";
    }

    @Override
    public String cancelDelivery(Long deliveryId, DriverPromptRequest request) {
        DeliveryEntity delivery = deliveryRepository.findById(deliveryId)
                .orElseThrow(() -> new ResourceNotFoundException(NOT_FOUND));

        DriverEntity driver = driverRepository.findById(deliveryId)
                .orElseThrow(() -> new ResourceNotFoundException(NOT_FOUND));

        delivery.setDriver(null);
        delivery.setDeliveryStatus(DeliveryStatus.OPEN.name());
        deliveryRepository.save(delivery);

        AvailableDriverEntity available = availableDriverRepository
                .findByDriverAndDelivery(driver, delivery)
                .orElseThrow(() -> new ResourceNotFoundException(NOT_FOUND));

        available.setStatus(DeliveryStatus.CANCELLED.name());
        availableDriverRepository.save(available);
        eventPublisher.publishEvent(new DriverDeliveryCancelEvents(this, deliveryId));

        return "Driver has cancelled the ride request.";
    }

    @Override
    public String pickupDelivery(Long deliveryId, PickupDeliveryRequest request) throws IOException {
        DeliveryEntity delivery = deliveryRepository.findById(deliveryId)
                .orElseThrow(() -> new ResourceNotFoundException(NOT_FOUND));

        PickupEntity pickup = new PickupEntity();
        pickup.setLatitude(request.latitude());
        pickup.setLongitude(request.longitude());
        pickup.setTimestamp(LocalDateTime.now());
        String pickupImagePath = saveFileToDirectory(request.pickupImage(), "pickup_images");
        pickup.setPickupImage(pickupImagePath);
        pickupRepository.save(pickup);
        if (delivery.getIsScheduled()) {
            DriverEntity driver = delivery.getDriver();
            driver.setIsBusy(true);
            driverRepository.save(driver);
        }

        delivery.setDeliveryStatus(DeliveryStatus.PICKED_UP.name());

        deliveryRepository.save(delivery);
        //javaMailService.sendDeliveryCompletionOtp(delivery.getEntityId());
        eventPublisher.publishEvent(new DeliveryPickedUpEvent(this, delivery.getEntityId(), DeliveryStatus.valueOf(delivery.getDeliveryStatus())));
        return "Delivery has been picked up successfully.";
    }

    @Override
    public String completeDelivery(Long deliveryId, CompleteDeliveryRequest request) {
        DeliveryEntity delivery = deliveryRepository.findById(deliveryId)
                .orElseThrow(() -> new ResourceNotFoundException(NOT_FOUND));
        if (!delivery.getDeliveryStatus().equals(DeliveryStatus.PICKED_UP.name())) {
            log.error("Delivery cannot be  completed when delivery status is not PICKED_UP.");
            throw new IllegalAction("Delivery cannot be  completed when delivery status is not PICKED_UP.");
        }

        DropOffEntity dropOff = new DropOffEntity();
        dropOff.setLatitude(request.latitude());
        dropOff.setLongitude(request.longitude());
        dropOff.setStatus(DeliveryStatus.COMPLETED.name());
        dropOff.setTimestamp(LocalDateTime.now());
        dropOff.setDelivery(delivery);
        dropOffRepository.save(dropOff);

        delivery.setDeliveryStatus(DeliveryStatus.COMPLETED.name());
        deliveryRepository.save(delivery);
        if (!request.otp().equals(delivery.getCompletionOtp())) {
            log.warn("OTP doesn't match completion OTP. Please try again.");
            throw new IncorrectOtp("OTP doesn't match completion OTP. Please try again.");
        }

        DriverEntity driver = delivery.getDriver();
        driver.setIsBusy(false);
        driverRepository.save(driver);

        transactionService.processEMoneyPayment(ProcessPaymentResponseDTO.builder()
                .status(TransactionStatus.COMPLETED)
                .txnId(delivery.getTransaction().getId())
                .narration("DELIVERY COMPLETED SUCCESSFULLY").build());
        eventPublisher.publishEvent(new DeliveryCompletedEvent(this, delivery.getEntityId(), DeliveryStatus.COMPLETED));
        return "Delivery has been completed.";
    }

    @Override
    public String deleteProposal(Long deliveryId, DriverPromptRequest request) {
        DeliveryEntity delivery = deliveryRepository.findById(deliveryId)
                .orElseThrow(() -> new ResourceNotFoundException(NOT_FOUND));

        DriverEntity driver = driverRepository.findById(request.driverId())
                .orElseThrow(() -> new ResourceNotFoundException(NOT_FOUND));

        AvailableDriverEntity available = availableDriverRepository
                .findByDriverAndDelivery(driver, delivery)
                .orElseThrow(() -> new ResourceNotFoundException(NOT_FOUND));

        availableDriverRepository.delete(available);
        return "Delivery proposal has been deleted successfully.";
    }

    public PaginatedResponse<DriverDeliveryResponse> paginateResponse(Page<DeliveryEntity> page) {
        List<DeliveryEntity> deliveries = page.getContent();

        List<DriverDeliveryResponse> driverDeliveryResponses = deliveries.stream()
                .map(this::mapToDriverDeliveryResponse)
                .toList();

        CustomPagination pagination = new CustomPagination(
                page.getTotalElements(),
                page.getTotalPages(),
                page.getNumber() + 1,
                page.getSize()
        );

        return new PaginatedResponse<>(driverDeliveryResponses, pagination);
    }

    private String saveFileToDirectory(MultipartFile file, String directory) throws IOException {
        String UPLOAD_DIR = System.getProperty("user.home") + "/Code/Uploads/" + directory;
        File uploadDir = new File(UPLOAD_DIR);

        if (!uploadDir.exists()) {
            uploadDir.mkdirs();
        }

        String originalFilename = StringUtils.cleanPath(file.getOriginalFilename());

        if (originalFilename.isEmpty()) {
            return "";
        }

        String timestamp = new SimpleDateFormat("yyyyMMdd_HHmmssSSSSSSSSS").format(new Date());

        originalFilename = originalFilename.replaceAll("\\s+", "");

        String nameWithoutExt = originalFilename.contains(".") ?
                originalFilename.substring(0, originalFilename.lastIndexOf(".")) :
                originalFilename;
        String extension = originalFilename.contains(".") ?
                originalFilename.substring(originalFilename.lastIndexOf(".")) : "";

        String newFilename = nameWithoutExt + "_" + timestamp + extension;

        Path filePath = Paths.get(UPLOAD_DIR, newFilename).toAbsolutePath().normalize();

        Files.copy(file.getInputStream(), filePath, StandardCopyOption.REPLACE_EXISTING);

        String fileLocalPath = "/Code/Uploads/" + directory + "/" + newFilename;
        return filePath.toString();
    }

    private DriverDeliveryProposalDto mapToDriverDeliveryProposalDto(AvailableDriverEntity availableDriver) {
        DriverEntity driver = availableDriver.getDriver();
        VehicleEntity vehicle = availableDriver.getVehicle();

        return DriverDeliveryProposalDto.builder()
                .driverID(driver.getEntityId())
                .deliveryID(availableDriver.getDelivery().getEntityId())
                .proposalID(availableDriver.getEntityId())
                .firstname(driver.getFirstname())
                .lastname(driver.getLastname())
                .profilePhotoUrl(driver.getProfilePhotoUrl())
                .rating(5.0) // Default rating, you might want to calculate this from actual ratings
                .status(availableDriver.getStatus())
                .longitude(availableDriver.getLongitude())
                .latitude(availableDriver.getLatitude())
                .totalDeliveries(driver.getDeliveries().size())
                .activeVehicle(DriverActiveVehicle.builder()
                        .vehicleId(vehicle.getEntityId())
                        .vehicleModel(vehicle.getVehicleModel())
                        .vehicleColor(vehicle.getVehicleColor())
                        .vehicleMake(vehicle.getVehicleMake())
                        .licensePlateNo(vehicle.getLicensePlateNo())
                        .vehicleType(vehicle.getVehicleType())
                        .build())
                .build();
    }

}
