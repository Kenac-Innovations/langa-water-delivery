package zw.co.kenac.takeu.backend.dto.client;

import zw.co.kenac.takeu.backend.dto.DeliveryDriverResponse;
import zw.co.kenac.takeu.backend.dto.DeliveryVehicleResponse;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.LocalTime;

public record ClientDeliveryResponse(
        Long deliveryId,
        BigDecimal priceAmount,
        String currency,
        Boolean autoAssign,
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
        DeliveryDriverResponse driver,
        DeliveryVehicleResponse vehicle,
        Boolean isScheduled,
        LocalTime pickUpTime,
        LocalDateTime createdAt,
        LocalDateTime updatedAt
) { }