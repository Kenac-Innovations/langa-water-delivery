package zw.co.kenac.takeu.backend.service.driver.impl;


import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.context.ApplicationEventPublisher;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import zw.co.kenac.takeu.backend.dto.waterdelivery.request.DriverWaterDeliveryCompleteRequest;
import zw.co.kenac.takeu.backend.dto.waterdelivery.response.WaterDeliveryResponse;
import zw.co.kenac.takeu.backend.event.deliveryEvents.DeliveryCompletedEvent;
import zw.co.kenac.takeu.backend.event.deliveryEvents.WaterDeliveryCompletedEvent;
import zw.co.kenac.takeu.backend.event.deliveryEvents.WaterDeliveryOnRouteEvent;
import zw.co.kenac.takeu.backend.event.deliveryEvents.WaterDriverAcceptedEvent;
import zw.co.kenac.takeu.backend.exception.custom.IllegalAction;
import zw.co.kenac.takeu.backend.exception.custom.IncorrectOtp;
import zw.co.kenac.takeu.backend.exception.custom.ResourceNotFoundException;
import zw.co.kenac.takeu.backend.model.DeliveryEntity;
import zw.co.kenac.takeu.backend.model.DriverEntity;
import zw.co.kenac.takeu.backend.model.DropOffEntity;
import zw.co.kenac.takeu.backend.model.enumeration.DeliveryStatus;
import zw.co.kenac.takeu.backend.model.enumeration.TransactionStatus;
import zw.co.kenac.takeu.backend.model.waterdelivery.WaterDelivery;
import zw.co.kenac.takeu.backend.repository.DriverRepository;
import zw.co.kenac.takeu.backend.repository.WaterDeliveryRepository;
import zw.co.kenac.takeu.backend.service.driver.DriverWaterDeliveryService;
import zw.co.kenac.takeu.backend.walletmodule.dto.ProcessPaymentResponseDTO;

import java.time.LocalDateTime;

import static zw.co.kenac.takeu.backend.constant.AppConstant.NOT_FOUND;

/**
 * Created by dyland
 * Email: dyland@kenac.co.zw
 * Created on: 12/6/2025
 */
@Slf4j
@Service
@RequiredArgsConstructor
@Transactional
public class DriverWaterDeliveryServiceImpl implements DriverWaterDeliveryService {
    private final DriverRepository driverRepository;
    private final WaterDeliveryRepository waterDeliveryRepository;
    private final ApplicationEventPublisher eventPublisher;

    @Override
    public WaterDeliveryResponse acceptDelivery(Long driverId, Long waterDeliveryId) {
        WaterDelivery delivery = waterDeliveryRepository.findById(waterDeliveryId)
                .orElseThrow(() -> new ResourceNotFoundException("WaterDelivery with id " + waterDeliveryId + " not found"));
        if (!(delivery.getDeliveryStatus().equals(DeliveryStatus.OPEN.name()))) {
            log.info("");
            throw new IllegalAction("Delivery with id " + waterDeliveryId + " is already assigned to someone");
        }
        DriverEntity driver = driverRepository.findById(driverId)
                .orElseThrow(() -> new ResourceNotFoundException("Driver with id " + driverId + " not found"));
        delivery.setDeliveryStatus(DeliveryStatus.ASSIGNED.name());
        delivery.setDriver(driver);
        // todo update firebase and notify dispatcher
        WaterDelivery waterDelivery = waterDeliveryRepository.save(delivery);
        eventPublisher.publishEvent(new WaterDriverAcceptedEvent(this, waterDelivery));

        return mapDeliveryToResponse(waterDelivery);
    }

    @Override
    public WaterDeliveryResponse completeDelivery(DriverWaterDeliveryCompleteRequest request) {
        WaterDelivery delivery = waterDeliveryRepository.findById(request.getDeliveryId())
                .orElseThrow(() -> new ResourceNotFoundException("WaterDelivery with id " + request.getDeliveryId() + " not found"));
        if (!delivery.getDeliveryStatus().equals(DeliveryStatus.ASSIGNED.name())) {
            log.error("Delivery cannot be  completed when delivery status is not Assign to a driver.");
            throw new IllegalAction("Delivery cannot be  completed when delivery status is not ASSIGNED to a driver.");
        }


        delivery.setDeliveryStatus(DeliveryStatus.COMPLETED.name());
        WaterDelivery waterDelivery = waterDeliveryRepository.save(delivery);
        if (!request.getOtpCode().equals(delivery.getCompletionOtp())) {
            log.warn("OTP doesn't match completion OTP. Please try again.");
            throw new IncorrectOtp("OTP doesn't match completion OTP. Please try again.");
        }

        DriverEntity driver = delivery.getDriver();
        driver.setIsBusy(false);
        driverRepository.save(driver);

        eventPublisher.publishEvent(new WaterDeliveryCompletedEvent(this, waterDelivery));
        return mapDeliveryToResponse(waterDelivery);
    }

    @Override
    public WaterDeliveryResponse cancelDelivery(Long driverId, Long waterDeliveryId) {
        return null;
    }

    @Override
    public WaterDeliveryResponse startDelivery(Long waterDeliveryId) {
        WaterDelivery waterDelivery = waterDeliveryRepository.findById(waterDeliveryId).orElseThrow(() -> new ResourceNotFoundException("WaterDelivery with id " + waterDeliveryId + " not found"));
        if (!waterDelivery.getDeliveryStatus().equals(DeliveryStatus.ASSIGNED.name())) {
            log.error("Delivery cannot be  started when delivery status is not Assign to a driver.");
            throw new IllegalAction("Delivery cannot be  started when delivery status is not ASSIGNED to a driver.");
        }
        if (waterDelivery.getDriver() == null) {
            log.error("Delivery cannot be  started when driver is not assigned to delivery.");
            throw new IllegalAction("Delivery cannot be  started when driver is not assigned to delivery.");
        }

        waterDelivery.setDeliveryStatus(DeliveryStatus.ON_ROUTE.name());

        WaterDelivery updateDelivery = waterDeliveryRepository.save(waterDelivery);
        // event for on route
        eventPublisher.publishEvent(new WaterDeliveryOnRouteEvent(this, updateDelivery));
        return mapDeliveryToResponse(updateDelivery);
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
