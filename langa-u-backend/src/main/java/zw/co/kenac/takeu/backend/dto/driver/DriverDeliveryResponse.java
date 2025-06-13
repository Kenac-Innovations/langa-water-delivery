package zw.co.kenac.takeu.backend.dto.driver;

import zw.co.kenac.takeu.backend.dto.DeliveryClientResponse;
import zw.co.kenac.takeu.backend.dto.DeliveryDriverResponse;
import zw.co.kenac.takeu.backend.dto.DeliveryVehicleResponse;

import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.time.LocalTime;

public record DriverDeliveryResponse(
        Long deliverId,
        BigDecimal priceAmount,
        String currency,
        String sensitivity,
        String paymentStatus,
        Double pickupLatitude,
        Double pickupLongitude,
        String pickupLocation,
        String pickupContactName,
        String pickupContactPhone,
        Double dropOffLatitude,
        Double dropOffLongitude,
        String dropOffLocation,
        String dropOffContactName,
        String dropOffContactPhone,
        String deliveryInstructions,
        String parcelDescription,
        String vehicleType,
        String paymentMethod,
        BigDecimal packageWeight,
        String deliveryStatus,
        BigDecimal commissionRequired,
        DeliveryClientResponse customer,
        DeliveryVehicleResponse vehicle,
        Boolean isScheduled,
        LocalTime pickUpTime,
        LocalDateTime createdAt,
        LocalDateTime updatedAt
) { }
