package zw.co.kenac.takeu.backend.service.waterdelivery.impl;


import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageRequest;
import org.springframework.data.domain.Pageable;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import zw.co.kenac.takeu.backend.dto.CustomPagination;
import zw.co.kenac.takeu.backend.dto.PaginatedResponse;
import zw.co.kenac.takeu.backend.dto.waterdelivery.response.WaterDeliveryResponse;
import zw.co.kenac.takeu.backend.dto.waterdelivery.response.WaterOrderResponse;
import zw.co.kenac.takeu.backend.exception.custom.ResourceNotFoundException;
import zw.co.kenac.takeu.backend.model.waterdelivery.WaterDelivery;
import zw.co.kenac.takeu.backend.repository.WaterDeliveryRepository;
import zw.co.kenac.takeu.backend.service.waterdelivery.WaterDeliveryService;

import java.util.List;
import java.util.Optional;

/**
 * Created by dyland
 * Email: dyland@kenac.co.zw
 * Created on: 12/6/2025
 */
@Service
@Transactional
@Slf4j
@RequiredArgsConstructor
public class WaterDeliveryServiceImpl implements WaterDeliveryService {
    private final WaterDeliveryRepository waterDeliveryRepository;
    @Override
    public PaginatedResponse<WaterDeliveryResponse> getDeliveriesByClient(Long clientId, String status, int pageNumber, int pageSize) {
        Pageable pageable = PageRequest.of(pageNumber - 1, pageSize);

        if (status.equals("ALL")) {
            Page<WaterDelivery> deliveries = waterDeliveryRepository.findByClient(pageable,clientId);
            return paginateResponse(deliveries);
        } else {
            Page<WaterDelivery> deliveries = waterDeliveryRepository.findByClientAndStatus(pageable, clientId,status);
            return paginateResponse(deliveries);
        }
    }

    @Override
    public PaginatedResponse<WaterDeliveryResponse> getDeliveriesByDriver(Long driverId, String status, int pageNumber, int pageSize) {
        Pageable pageable = PageRequest.of(pageNumber - 1, pageSize);

        if (status.equals("ALL")) {
            Page<WaterDelivery> deliveries = waterDeliveryRepository.findByDriverEntity(pageable,driverId);
            return paginateResponse(deliveries);
        } else {
            Page<WaterDelivery> deliveries = waterDeliveryRepository.findByDriverEntityAndStatus(pageable,driverId, status);
            return paginateResponse(deliveries);
        }
    }

    @Override
    public PaginatedResponse<WaterDeliveryResponse> getAllDeliveries(String status, int pageNumber, int pageSize) {
        Pageable pageable = PageRequest.of(pageNumber - 1, pageSize);

        if (status.equals("ALL")) {
            Page<WaterDelivery> deliveries = waterDeliveryRepository.findAll(pageable);
            return paginateResponse(deliveries);
        } else {
            Page<WaterDelivery> deliveries = waterDeliveryRepository.findByAllByStatus(pageable, status);
            return paginateResponse(deliveries);
        }
    }

    @Override
    public WaterDeliveryResponse getDeliveryById(Long deliveryId) {
        Optional<WaterDelivery> waterDelivery = waterDeliveryRepository.findById(deliveryId);
        if (waterDelivery.isEmpty()) {
            throw new ResourceNotFoundException("No such water delivery with id " + deliveryId);

        }
        return   mapDeliveryToResponse(waterDelivery.get());
    }

    public PaginatedResponse<WaterDeliveryResponse> paginateResponse(Page<WaterDelivery> page) {
        List<WaterDelivery> deliveries = page.getContent();

        List<WaterDeliveryResponse> driverDeliveryResponses = deliveries.stream()
                .map(this::mapDeliveryToResponse)
                .toList();

        CustomPagination pagination = new CustomPagination(
                page.getTotalElements(),
                page.getTotalPages(),
                page.getNumber() + 1,
                page.getSize()
        );

        return new PaginatedResponse<>(driverDeliveryResponses, pagination);
    }
    private WaterDeliveryResponse mapDeliveryToResponse(WaterDelivery delivery) {
        return WaterDeliveryResponse.builder()
                .deliveryId(delivery.getEntityId())
                .priceAmount(delivery.getPriceAmount())
                .autoAssignDriver(delivery.getAutoAssignDriver())
                .dropOffLocation(delivery.getDropOffLocation())
                .isScheduled(delivery.getIsScheduled())
                .deliveryInstructions(delivery.getDeliveryInstructions())
                .scheduledDetails(delivery.getScheduledDetails())
                .status(delivery.getDeliveryStatus())
                .build();
    }
}
