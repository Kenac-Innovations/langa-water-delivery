package zw.co.kenac.takeu.backend.service.internal.impl;

import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageRequest;
import org.springframework.data.domain.Pageable;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import zw.co.kenac.takeu.backend.dto.*;
import zw.co.kenac.takeu.backend.dto.client.SelectDriverRequest;
import zw.co.kenac.takeu.backend.dto.waterdelivery.response.WaterDeliveryAdminResponse;
import zw.co.kenac.takeu.backend.model.enumeration.DeliveryStatus;
import zw.co.kenac.takeu.backend.model.waterdelivery.WaterDelivery;
import zw.co.kenac.takeu.backend.repository.WaterDeliveryRepository;
import zw.co.kenac.takeu.backend.service.client.ClientDeliveryService;
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
    private final ClientDeliveryService clientDeliveryService;
    private final WaterDeliveryRepository waterDeliveryRepository;

    @Override
    public PaginatedResponse<WaterDeliveryAdminResponse> getAllDeliveriesByStatus(DeliveryStatus status, int pageNumber, int pageSize) {
        Pageable pageable = PageRequest.of(pageNumber - 1, pageSize);
        Page<WaterDelivery> deliveryList = waterDeliveryRepository.findByAllByStatus(pageable, status.name());
        return paginateResponse(deliveryList);
    }

    @Override
    public WaterDeliveryAdminResponse assignDeliveryToDriver(Long clientId, SelectDriverRequest request) {
        String delivery = clientDeliveryService.selectDeliveryDriver(clientId, request);
        WaterDelivery waterDelivery = waterDeliveryRepository.findById(request.deliveryId())
                .orElseThrow(() -> new RuntimeException("Water delivery not found"));
        
        // Return the updated delivery response
        return mapToWaterDeliveryAdminResponse(waterDelivery);
    }

    @Override
    public WaterDeliveryAdminResponse unassignDeliveryFromDriver(Long deliveryId) {
        WaterDelivery waterDelivery = waterDeliveryRepository.findById(deliveryId)
                .orElseThrow(() -> new RuntimeException("Water delivery not found"));
        
        // Unassign driver and vehicle
        waterDelivery.setDriver(null);
        waterDelivery.setVehicle(null);
        waterDelivery.setDeliveryStatus(DeliveryStatus.OPEN.name());
        
        WaterDelivery savedDelivery = waterDeliveryRepository.save(waterDelivery);
        return mapToWaterDeliveryAdminResponse(savedDelivery);
    }

    public PaginatedResponse<WaterDeliveryAdminResponse> paginateResponse(Page<WaterDelivery> page) {
        List<WaterDelivery> deliveries = page.getContent();

        List<WaterDeliveryAdminResponse> waterDeliveryResponses = deliveries.stream()
                .map(this::mapToWaterDeliveryAdminResponse)
                .toList();

        CustomPagination pagination = new CustomPagination(
                page.getTotalElements(),
                page.getTotalPages(),
                page.getNumber() + 1,
                page.getSize()
        );

        return new PaginatedResponse<>(waterDeliveryResponses, pagination);
    }

    private WaterDeliveryAdminResponse mapToWaterDeliveryAdminResponse(WaterDelivery delivery) {
        return WaterDeliveryAdminResponse.builder()
                .deliveryId(delivery.getEntityId())
                .orderId(delivery.getOrder() != null ? delivery.getOrder().getEntityId() : null)
                .priceAmount(delivery.getPriceAmount())
                .waterLitreQuantity(delivery.getWaterLitreQuantity())
                .autoAssignDriver(delivery.getAutoAssignDriver())
                
                // Drop-off location details
                .dropOffLatitude(delivery.getDropOffLocation() != null ? delivery.getDropOffLocation().getDropOffLatitude() : null)
                .dropOffLongitude(delivery.getDropOffLocation() != null ? delivery.getDropOffLocation().getDropOffLongitude() : null)
                .dropOffLocation(delivery.getDropOffLocation() != null ? delivery.getDropOffLocation().getDropOffLocation() : null)
                .dropOffContactName(delivery.getDropOffLocation() != null ? delivery.getDropOffLocation().getDropOffContactName() : null)
                .dropOffContactPhone(delivery.getDropOffLocation() != null ? delivery.getDropOffLocation().getDropOffContactPhone() : null)
                .dropOffAddressType(delivery.getDropOffLocation() != null ? delivery.getDropOffLocation().getDropOffAddressType() : null)
                
                // Delivery details
                .isScheduled(delivery.getIsScheduled())
                .deliveryInstructions(delivery.getDeliveryInstructions())
                .deliveryStatus(delivery.getDeliveryStatus())
                .completionOtp(delivery.getCompletionOtp())
                .commissionRequired(delivery.getCommissionRequired())
                .reasonForCancelling(delivery.getReasonForCancelling())
                
                // Scheduled details
                .scheduledDetails(delivery.getScheduledDetails())
                
                // Related entities
                .client(delivery.getOrder() != null && delivery.getOrder().getClient() != null ? 
                    new DeliveryClientResponse(
                        delivery.getOrder().getClient().getEntityId(),
                        delivery.getOrder().getClient().getFullName(),
                        delivery.getOrder().getClient().getLastname(),
                        delivery.getOrder().getClient().getMobileNumber(),
                        delivery.getOrder().getClient().getEmailAddress()
                    ) : null)
                .vehicle(delivery.getVehicle() != null ? 
                    new DeliveryVehicleResponse(
                        delivery.getVehicle().getEntityId(),
                        delivery.getVehicle().getVehicleModel(),
                        delivery.getVehicle().getVehicleColor(),
                        delivery.getVehicle().getVehicleMake(),
                        delivery.getVehicle().getLicensePlateNo(),
                        delivery.getVehicle().getVehicleType()
                    ) : null)
                .driver(delivery.getDriver() != null ? 
                    WaterDeliveryAdminResponse.DriverSummaryResponse.builder()
                        .driverId(delivery.getDriver().getEntityId())
                        .firstname(delivery.getDriver().getFirstname())
                        .lastname(delivery.getDriver().getLastname())
                        .mobileNumber(delivery.getDriver().getMobileNumber())
                        .profilePhotoUrl(delivery.getDriver().getProfilePhotoUrl())
                        .build() : null)
                
                // Timestamps
                .createdDate(delivery.getCreatedDate())
                .lastModifiedDate(delivery.getLastModifiedDate())
                .build();
    }
}
