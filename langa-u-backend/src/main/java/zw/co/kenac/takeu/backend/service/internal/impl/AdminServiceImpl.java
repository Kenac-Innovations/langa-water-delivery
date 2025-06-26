package zw.co.kenac.takeu.backend.service.internal.impl;


import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageRequest;
import org.springframework.data.domain.Pageable;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import zw.co.kenac.takeu.backend.dto.*;
import zw.co.kenac.takeu.backend.dto.client.ClientDeliveryResponse;

import zw.co.kenac.takeu.backend.dto.driver.DriverDeliveryResponse;
import zw.co.kenac.takeu.backend.dto.waterdelivery.response.ClientInformationDto;
import zw.co.kenac.takeu.backend.model.DeliveryEntity;
import zw.co.kenac.takeu.backend.model.enumeration.DeliveryStatus;
import zw.co.kenac.takeu.backend.repository.DeliveryRepository;
import zw.co.kenac.takeu.backend.service.internal.AdminService;

import java.util.List;

/**
 * Created by dyland
 * Email: dyland@kenac.co.zw
 * Created on: 17/6/2025
 */
@Service
@RequiredArgsConstructor
@Slf4j
@Transactional
public class AdminServiceImpl implements AdminService {
    private final DeliveryRepository deliveryRepository;
    @Override
    public PaginatedResponse<DriverDeliveryResponse> getAllDeliveriesByStatus(DeliveryStatus status,int pageNumber, int pageSize) {
        Pageable pageable = PageRequest.of(pageNumber - 1, pageSize);
        Page<DeliveryEntity> deliveryList = deliveryRepository.findAllByStatus(pageable,status.name());
        return paginateResponse(deliveryList);
    }

//    @Override
//    public List<DeliveryClientResponse> getAllDeliveryClients() {
//        return List.of();
//    }
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
    private DriverDeliveryResponse mapToDriverDeliveryResponse(DeliveryEntity delivery) {
//        return new ClientDeliveryResponse(
//                delivery.getEntityId(),
//                delivery.getPriceAmount(),
//                delivery.getPayment().getCurrency(),
//                delivery.getAutoAssignDriver(),
//                delivery.getSensitivity(),
//                delivery.getPayment().getPaymentStatus(),
//                delivery.getPickupLocation().getPickupLatitude(),
//                delivery.getPickupLocation().getPickupLongitude(),
//                delivery.getPickupLocation().getPickupLocation(),
//                delivery.getPickupLocation().getPickupContactName(),
//                delivery.getPickupLocation().getPickupContactPhone(),
//                delivery.getDropOffLocation().getDropOffLatitude(),
//                delivery.getDropOffLocation().getDropOffLongitude(),
//                delivery.getDropOffLocation().getDropOffLocation(),
//                delivery.getDropOffLocation().getDropOffContactName(),
//                delivery.getDropOffLocation().getDropOffContactPhone(),
//                delivery.getDeliveryInstructions(),
//                delivery.getParcelDescription(),
//                delivery.getVehicleType(),
//                delivery.getPayment().getPaymentMethod(),
//                delivery.getPackageWeight(),
//                delivery.getDeliveryStatus(),
//                delivery.getCommissionRequired(),
//                delivery.getDriver() != null ? new DeliveryDriverResponse(
//                        delivery.getDriver().getEntityId(),
//                        delivery.getDriver().getFirstname(),
//                        delivery.getDriver().getLastname(),
//                        delivery.getDriver().getGender(),
//                        delivery.getDriver().getMobileNumber(),
//                        delivery.getDriver().getNationalIdNo(),
//                        delivery.getDriver().getProfilePhotoUrl(),
//                        delivery.getDriver().getNationalIdImage(),
//                        delivery.getDriver().getDriversLicenseUrl()
//                ) : null,
//                delivery.getVehicle() != null ? new DeliveryVehicleResponse(
//                        delivery.getVehicle().getEntityId(),
//                        delivery.getVehicle().getVehicleModel(),
//                        delivery.getVehicle().getVehicleColor(),
//                        delivery.getVehicle().getVehicleMake(),
//                        delivery.getVehicle().getLicensePlateNo(),
//                        //delivery.getVehicle().getVehicleType().getName()
//                        delivery.getVehicle().getVehicleType()
//                ) : null, delivery.getIsScheduled(),
//                delivery.getPickUpTime(),
//                delivery.getCreatedAt(),
//                delivery.getUpdatedAt(),
////                delivery.getDeliveryType(),
////                delivery.getNumberOfSeats(),
//                ClientInformationDto.builder()
//                        .clientId(delivery.getCustomer().getEntityId())
//                        .firstName(delivery.getCustomer().getFullName())
//                        //.lastName(delivery.getCustomer().getLastname())
//                        .phoneNumber(delivery.getCustomer().getMobileNumber())
//                        .build()
//        );
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
}
