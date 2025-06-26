package zw.co.kenac.takeu.backend.dto.waterdelivery.response;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;
import zw.co.kenac.takeu.backend.dto.DeliveryClientResponse;
import zw.co.kenac.takeu.backend.dto.DeliveryVehicleResponse;
import zw.co.kenac.takeu.backend.model.embedded.DropOffLocation;
import zw.co.kenac.takeu.backend.model.embedded.ScheduledDetails;

import java.math.BigDecimal;
import java.time.LocalDateTime;

/**
 * Water Delivery Admin Response DTO
 * Created by dyland
 * Email: dyland@kenac.co.zw
 * Created on: 26/6/2025
 */
@Data
@Builder
@AllArgsConstructor
@NoArgsConstructor
public class WaterDeliveryAdminResponse {
    
    private Long deliveryId;
    private Long orderId;
    private BigDecimal priceAmount;
    private Integer waterLitreQuantity;
    private Boolean autoAssignDriver;
    
    // Drop-off location details
    private Double dropOffLatitude;
    private Double dropOffLongitude;
    private String dropOffLocation;
    private String dropOffContactName;
    private String dropOffContactPhone;
    private String dropOffAddressType;
    
    // Delivery details
    private Boolean isScheduled;
    private String deliveryInstructions;
    private String deliveryStatus;
    private String completionOtp;
    private BigDecimal commissionRequired;
    private String reasonForCancelling;
    
    // Scheduled details (if applicable)
    private ScheduledDetails scheduledDetails;
    
    // Related entities
    private DeliveryClientResponse client;
    private DeliveryVehicleResponse vehicle;
    private DriverSummaryResponse driver;
    
    // Timestamps
    private LocalDateTime createdDate;
    private LocalDateTime lastModifiedDate;
    
    /**
     * Nested DTO for driver summary information
     */
    @Data
    @Builder
    @AllArgsConstructor
    @NoArgsConstructor
    public static class DriverSummaryResponse {
        private Long driverId;
        private String firstname;
        private String lastname;
        private String mobileNumber;
        private String profilePhotoUrl;
    }
} 