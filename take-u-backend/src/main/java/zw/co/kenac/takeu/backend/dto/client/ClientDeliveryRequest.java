package zw.co.kenac.takeu.backend.dto.client;

import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.time.LocalTime;

public record ClientDeliveryRequest(
        BigDecimal priceAmount,
        Boolean autoAssign,
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
        LocalDateTime deliveryDate,
        LocalTime pickupTime,
        Boolean isScheduled
) { }
