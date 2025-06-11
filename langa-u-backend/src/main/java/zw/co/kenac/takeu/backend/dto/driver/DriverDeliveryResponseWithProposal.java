package zw.co.kenac.takeu.backend.dto.driver;


import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;
import zw.co.kenac.takeu.backend.dto.DeliveryClientResponse;
import zw.co.kenac.takeu.backend.dto.DeliveryVehicleResponse;

import java.math.BigDecimal;

/**
 * Created by dyland
 * Email: dyland@kenac.co.zw
 * Created on: 14/5/2025
 */
@Data
@Builder
@AllArgsConstructor
@NoArgsConstructor
public class DriverDeliveryResponseWithProposal {
    private Long deliveryId;
    private BigDecimal priceAmount;
    private String currency;
    private String sensitivity;
    private String paymentStatus;
    private Double pickupLatitude;
    private Double pickupLongitude;
    private String pickupLocation;
    private String pickupContactName;
    private String pickupContactPhone;
    private Double dropOffLatitude;
    private Double dropOffLongitude;
    private String dropOffLocation;
    private String dropOffContactName;
    private String dropOffContactPhone;
    private String deliveryInstructions;
    private String parcelDescription;
    private String vehicleType;
    private String paymentMethod;
    private BigDecimal packageWeight;
    private String deliveryStatus;
    private BigDecimal commissionRequired;
    private DeliveryClientResponse customer;
    private DeliveryVehicleResponse vehicle;
    private Boolean isProposed;
}
