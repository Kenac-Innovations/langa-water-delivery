package zw.co.kenac.takeu.backend.service.client.impl;

import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.context.ApplicationEventPublisher;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageRequest;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.Modifying;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import zw.co.kenac.takeu.backend.dto.*;
import zw.co.kenac.takeu.backend.dto.client.*;
import zw.co.kenac.takeu.backend.dto.driver.DriverDeliveryResponse;
import zw.co.kenac.takeu.backend.event.deliveryEvents.ClientDeliveryCancelEvent;
import zw.co.kenac.takeu.backend.event.deliveryEvents.DeliveryCreatedEvent;
import zw.co.kenac.takeu.backend.event.deliveryEvents.DeliveryDeleteEvent;
import zw.co.kenac.takeu.backend.event.deliveryEvents.DriverAcceptedEvent;
import zw.co.kenac.takeu.backend.exception.custom.ResourceNotFoundException;
import zw.co.kenac.takeu.backend.model.*;
import zw.co.kenac.takeu.backend.model.embedded.DropOffLocation;
import zw.co.kenac.takeu.backend.model.embedded.PickupLocation;
import zw.co.kenac.takeu.backend.model.enumeration.DeliveryStatus;
import zw.co.kenac.takeu.backend.model.enumeration.DriverProposalStatus;
import zw.co.kenac.takeu.backend.model.enumeration.PaymentMethod;
import zw.co.kenac.takeu.backend.repository.AvailableDriverRepository;
import zw.co.kenac.takeu.backend.repository.ClientRepository;
import zw.co.kenac.takeu.backend.repository.DeliveryRepository;
import zw.co.kenac.takeu.backend.repository.DriverRepository;
import zw.co.kenac.takeu.backend.service.client.ClientDeliveryService;
import zw.co.kenac.takeu.backend.service.internal.CommissionService;
import zw.co.kenac.takeu.backend.walletmodule.dto.CreateTxnDTO;
import zw.co.kenac.takeu.backend.walletmodule.dto.TransactionDto;
import zw.co.kenac.takeu.backend.walletmodule.models.Currencies;
import zw.co.kenac.takeu.backend.walletmodule.models.Transaction;
import zw.co.kenac.takeu.backend.walletmodule.repo.CurrenciesRepo;
import zw.co.kenac.takeu.backend.walletmodule.repo.TransactionRepo;
import zw.co.kenac.takeu.backend.walletmodule.service.TransactionService;
import zw.co.kenac.takeu.backend.walletmodule.utils.JsonUtil;

import java.math.BigDecimal;
import java.security.SecureRandom;
import java.util.List;

import static zw.co.kenac.takeu.backend.constant.AppConstant.NOT_FOUND;

@Slf4j
@Service
@Transactional
@RequiredArgsConstructor
public class ClientDeliveryServiceImpl implements ClientDeliveryService {
    private final DeliveryRepository deliveryRepository;
    private final ClientRepository clientRepository;
    private final DriverRepository driverRepository;
    private final AvailableDriverRepository availableDriverRepository;
    private final CurrenciesRepo currenciesRepo;
    private final TransactionService transactionService;
    private final TransactionRepo transactionRepo;
    private final CommissionService commissionService;
    private final ApplicationEventPublisher eventPublisher;

    @Override
    public PaginatedResponse<ClientDeliveryResponse> findAllDeliveries(Long clientId, int pageNumber, int pageSize, String status) {
        Pageable pageable = PageRequest.of(pageNumber - 1, pageSize);
        if (status == null || status.equalsIgnoreCase("ALL")) {
            Page<DeliveryEntity> deliveries = deliveryRepository.findAllByCustomerEntityId(pageable, clientId);
            return paginateResponse(deliveries);
        } else {
            Page<DeliveryEntity> deliveries = deliveryRepository.findAllByCustomerEntityIdAndStatus(pageable, clientId, status);
            return paginateResponse(deliveries);
        }

    }

    @Override
    public PaginatedResponse<ClientDeliveryResponse> getAllCustomerActiveDeliveries(Long clientId, int pageNumber, int pageSize) {
        Pageable pageable = PageRequest.of(pageNumber - 1, pageSize);

        Page<DeliveryEntity> deliveries = deliveryRepository.findAllActiveCustomerDeliveries(pageable, clientId);
        return paginateResponse(deliveries);

    }

    @Override
    public ClientDeliveryResponse findDeliveryById(Long deliveryId) {
        DeliveryEntity delivery = deliveryRepository.findById(deliveryId)
                .orElseThrow(() -> new ResourceNotFoundException(NOT_FOUND));
        return mapToResponse(delivery);
    }

    @Override
    public ClientDeliveryResponse createDelivery(Long clientId, ClientDeliveryRequest deliveryRequest) {//
        log.info("=======> Incoming delivery request {}", JsonUtil.toJson(deliveryRequest));
        ClientEntity client = clientRepository.findById(clientId)
                .orElseThrow(() -> new ResourceNotFoundException(" Client with Id" + clientId + " not found"));

        DeliveryEntity delivery = new DeliveryEntity();
        delivery.setCustomer(client);
        delivery.setPriceAmount(deliveryRequest.priceAmount());
        delivery.setCompletionOtp(generateOtp());// this otp will be used on completion

        delivery.setAutoAssignDriver(deliveryRequest.autoAssign());
        delivery.setSensitivity(deliveryRequest.sensitivity());

        PickupLocation pickupLocation = generatePickupLocation(deliveryRequest.pickupLatitude(),
                deliveryRequest.pickupLongitude(), deliveryRequest.pickupLocation(), deliveryRequest.pickupContactName(), deliveryRequest.pickupContactPhone());

        DropOffLocation dropOffLocation = generateDropOffLocation(deliveryRequest.dropOffLatitude(),
                deliveryRequest.dropOffLongitude(), deliveryRequest.dropOffLocation(), deliveryRequest.dropOffContactName(), deliveryRequest.dropOffContactPhone());

        DeliveryPayment payment = generatePayment(deliveryRequest.currency(), deliveryRequest.priceAmount(), deliveryRequest.paymentMethod(), deliveryRequest.paymentStatus());

        // Calculate the required commission amount based on the price
        BigDecimal commission = commissionService.calculateCommissionForAmount(deliveryRequest.priceAmount());
        delivery.setCommissionRequired(commission);

        delivery.setPickupLocation(pickupLocation);
        delivery.setPayment(payment);

        delivery.setDropOffLocation(dropOffLocation);
        delivery.setDeliveryInstructions(deliveryRequest.deliveryInstructions());
        delivery.setParcelDescription(deliveryRequest.parcelDescription());
        delivery.setVehicleType(deliveryRequest.vehicleType());
        delivery.setDeliveryDate(deliveryRequest.deliveryDate());
        delivery.setDeliveryStatus(DeliveryStatus.OPEN.name());
        delivery.setIsScheduled(deliveryRequest.isScheduled() == null ? false : deliveryRequest.isScheduled());
        delivery.setPickUpTime(deliveryRequest.pickupTime());
        DeliveryEntity deliveryResponse = deliveryRepository.save(delivery);
        // save to firebase
        eventPublisher.publishEvent(new DeliveryCreatedEvent(this, mapToDriverDeliveryResponse(deliveryResponse)));


        return mapToResponse(deliveryResponse);
    }

    @Override
    public String cancelDelivery(Long clientId, CancelDeliveryRequest request) {


        DeliveryEntity delivery = deliveryRepository.findById(request.deliveryId())
                .orElseThrow(() -> new ResourceNotFoundException(NOT_FOUND));
        if (!(delivery.getDeliveryStatus().equals(DeliveryStatus.OPEN.name()) || delivery.getDeliveryStatus().equals(DeliveryStatus.ASSIGNED.name()))) {
            throw new ResourceNotFoundException(" Delivery cannot be cancelled at this stage");
        }
        DeliveryStatus currentDeliveryStatus = DeliveryStatus.valueOf(delivery.getDeliveryStatus());
        delivery.setDeliveryStatus(DeliveryStatus.CANCELLED.name());
        delivery.setDriver(null);
        delivery.setReasonForCancelling(request.reason());
        deliveryRepository.save(delivery);

        eventPublisher.publishEvent(new ClientDeliveryCancelEvent(this, delivery.getEntityId(), delivery, currentDeliveryStatus));
        return "Delivery canceled successfully";
    }

    @Override
    public String deleteDelivery(Long clientId, Long deliveryId) {
        DeliveryEntity delivery = deliveryRepository.findById(deliveryId)
                .orElseThrow(() -> new ResourceNotFoundException(NOT_FOUND));
        deliveryRepository.delete(delivery);
        eventPublisher.publishEvent(new DeliveryDeleteEvent(this, delivery.getEntityId(), delivery.getVehicleType()));
        return "Delivery deleted successfully.";
    }

    @Override
    public String selectDeliveryDriver(Long clientId, SelectDriverRequest request) {
        log.info(" ======> This is the incoming request {}", request);
        List<AvailableDriverEntity> response = availableDriverRepository.checkIfDriverHasOpenProposalForDelivery(request.driverId(), request.deliveryId());
        log.info("=======> response: {}", response);

        DeliveryEntity delivery = deliveryRepository.findById(request.deliveryId()).orElseThrow(() -> new ResourceNotFoundException(NOT_FOUND));
        DriverEntity driver = driverRepository.findById(request.driverId()).orElseThrow(() -> new ResourceNotFoundException(NOT_FOUND));

        // First assign the delivery to driver and mark proposals
        AvailableDriverEntity availableDriver = assignDeliveryToDriverMarking(delivery.getEntityId(), driver.getEntityId());
        if(!delivery.getIsScheduled()){
            driver.setIsBusy(true);
        }

        // Then update delivery details
        delivery.setDriver(driver);
        delivery.setVehicle(driver.findActiveVehicle());
        delivery.setDeliveryStatus(DeliveryStatus.ASSIGNED.name());

        // Create the transaction
        Currencies currencies = currenciesRepo.findByName(delivery.getPayment().getCurrency()).orElse(Currencies.builder()
                .id(1L).name("USD").build());// todo hard coded make sure to change

        CreateTxnDTO transaction = CreateTxnDTO.builder()
                .clientId(delivery.getEntityId())
                .driverId(driver.getEntityId())
                .calculatedCommission(delivery.getCommissionRequired())
                .deliveryId(delivery.getEntityId())
                .principal(delivery.getPriceAmount())
                .paymentMethod(PaymentMethod.valueOf(delivery.getPayment().getPaymentMethod()))
                .currencyId(currencies.getId())
                .build();

        TransactionDto txn = transactionService.createTransaction(transaction);
        Transaction transaction1 = transactionRepo.findById(txn.getId()).orElseThrow(() -> new ResourceNotFoundException(NOT_FOUND));
        delivery.setTransaction(transaction1);
        log.info("========> Delivery Created transaction: {}", txn);

        deliveryRepository.save(delivery);

        // Publish events
        eventPublisher.publishEvent(new DeliveryDeleteEvent(this, delivery.getEntityId(), delivery.getVehicleType()));
        eventPublisher.publishEvent(new DriverAcceptedEvent(this, availableDriver));

        return "Delivery has been assigned to driver successfully.";
    }

    @Modifying
    @Transactional
    public AvailableDriverEntity assignDeliveryToDriverMarking(Long deliveryId, Long selectedDriverId) {
        // First decline all other open proposals

        // Then accept the selected driver's proposal
        //availableDriverRepository.acceptDriverProposalForDelivery(deliveryId, selectedDriverId);

        List<AvailableDriverEntity> response = availableDriverRepository.checkIfDriverHasOpenProposalForDelivery(selectedDriverId, deliveryId);
        log.info("=======> response =======>: {}", response);
        if (!response.isEmpty()) {
            AvailableDriverEntity availableDriver = response.get(0);
            availableDriver.setStatus(DriverProposalStatus.ACCEPTED.name());
            availableDriverRepository.declineOtherDriverProposalsForDelivery(deliveryId, selectedDriverId);

            return availableDriverRepository.save(availableDriver);
        } else {

            throw new RuntimeException("No driver proposal found for delivery with id " + deliveryId + " and driver id " + selectedDriverId);
        }


    }

    @Override
    public String processPayment(Long clientId, DeliveryPaymentRequest paymentRequest) {
        return "";
    }

    @Override
    public List<AvailableDriverResponse> findAvailableDrivers(Long deliveryId) {
        DeliveryEntity delivery = deliveryRepository.findById(deliveryId)
                .orElseThrow(() -> new ResourceNotFoundException(NOT_FOUND));

        List<AvailableDriverEntity> availableDrivers = availableDriverRepository
                .findByAvailable(delivery.getEntityId());

        return availableDrivers.stream().map(
                        driver -> new AvailableDriverResponse(
                                driver.getDriver().getEntityId(),
                                driver.getDriver().getEmail(),
                                driver.getDriver().getMobileNumber(),
                                driver.getDriver().getFirstname(),
                                driver.getDriver().getLastname(),
                                driver.getDriver().getGender(),
                                driver.getDriver().getProfilePhotoUrl(),
                                5.0,
                                driver.getLongitude(),
                                driver.getLatitude(),
                                driver.getDriver().getDeliveries().size(),
                                new DriverActiveVehicle(
                                        driver.getVehicle().getEntityId(),
                                        driver.getVehicle().getVehicleModel(),
                                        driver.getVehicle().getVehicleColor(),
                                        driver.getVehicle().getVehicleMake(),
                                        driver.getVehicle().getLicensePlateNo(),
                                        //driver.getVehicle().getVehicleType().getName()
                                        driver.getVehicle().getVehicleType()
                                )
                        )
                )
                .toList();
    }

    public static PaginatedResponse<ClientDeliveryResponse> paginateResponse(Page<DeliveryEntity> page) {
        List<DeliveryEntity> deliveries = page.getContent();

        List<ClientDeliveryResponse> driverDeliveryResponses = deliveries.stream()
                .map(ClientDeliveryServiceImpl::mapToResponse)
                .toList();

        CustomPagination pagination = new CustomPagination(
                page.getTotalElements(),
                page.getTotalPages(),
                page.getNumber() + 1,
                page.getSize()
        );

        return new PaginatedResponse<>(driverDeliveryResponses, pagination);
    }

    private String generateOtp() {
        String digits = "0123456789";
        SecureRandom random = new SecureRandom();
        StringBuilder otp = new StringBuilder(6);
        for (int i = 0; i < 6; i++) {
            otp.append(digits.charAt(random.nextInt(digits.length())));
        }
        return otp.toString();
    }

    private static ClientDeliveryResponse mapToResponse(DeliveryEntity delivery) {
        return new ClientDeliveryResponse(
                delivery.getEntityId(),
                delivery.getPriceAmount(),
                delivery.getPayment().getCurrency(),
                delivery.getAutoAssignDriver(),
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
                delivery.getDriver() != null ? new DeliveryDriverResponse(
                        delivery.getDriver().getEntityId(),
                        delivery.getDriver().getFirstname(),
                        delivery.getDriver().getLastname(),
                        delivery.getDriver().getGender(),
                        delivery.getDriver().getMobileNumber(),
                        delivery.getDriver().getNationalIdNo(),
                        delivery.getDriver().getProfilePhotoUrl(),
                        delivery.getDriver().getNationalIdImage(),
                        delivery.getDriver().getDriversLicenseUrl()
                ) : null,
                delivery.getVehicle() != null ? new DeliveryVehicleResponse(
                        delivery.getVehicle().getEntityId(),
                        delivery.getVehicle().getVehicleModel(),
                        delivery.getVehicle().getVehicleColor(),
                        delivery.getVehicle().getVehicleMake(),
                        delivery.getVehicle().getLicensePlateNo(),
                        //delivery.getVehicle().getVehicleType().getName()
                        delivery.getVehicle().getVehicleType()
                ) : null, delivery.getIsScheduled(),
                delivery.getPickUpTime(),
                delivery.getCreatedAt(),
                delivery.getUpdatedAt()
        );
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
                , delivery.getPickUpTime(),
                delivery.getCreatedAt(),
                delivery.getUpdatedAt()
        );
    }

    private PickupLocation generatePickupLocation(Double latitude, Double longitude, String location, String contactName, String contactPhone) {
        return new PickupLocation(
                latitude,
                longitude,
                location,
                contactName,
                contactPhone
        );
    }

    private DropOffLocation generateDropOffLocation(Double latitude, Double longitude, String location, String contactName, String contactPhone) {
        return new DropOffLocation(
                latitude,
                longitude,
                location,
                contactName,
                contactPhone
        );
    }

    private DeliveryPayment generatePayment(String currency, BigDecimal amount, String paymentMethod, String paymentStatus) {
        return new DeliveryPayment(
                currency,
                amount,
                paymentMethod,
                paymentStatus,
                null
        );
    }

}
