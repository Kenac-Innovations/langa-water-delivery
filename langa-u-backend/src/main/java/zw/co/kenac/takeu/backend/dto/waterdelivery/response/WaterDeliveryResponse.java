package zw.co.kenac.takeu.backend.dto.waterdelivery.response;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;
import zw.co.kenac.takeu.backend.model.embedded.DropOffLocation;
import zw.co.kenac.takeu.backend.model.embedded.ScheduledDetails;

import java.math.BigDecimal;

@Data
@Builder
@AllArgsConstructor
@NoArgsConstructor
public class WaterDeliveryResponse {
    private Long deliveryId;
    private BigDecimal priceAmount;
    private Boolean autoAssignDriver;
    private DropOffLocation dropOffLocation;
    private Boolean isScheduled;
    private String deliveryInstructions;
    private ScheduledDetails scheduledDetails;
    private String status;
} 