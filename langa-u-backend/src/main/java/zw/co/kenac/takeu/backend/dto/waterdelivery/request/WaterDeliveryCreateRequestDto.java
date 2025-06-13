package zw.co.kenac.takeu.backend.dto.waterdelivery.request;

import jakarta.validation.constraints.NotNull;
import lombok.Builder;
import lombok.Value;
import zw.co.kenac.takeu.backend.model.waterdelivery.WaterDelivery;

import java.io.Serializable;
import java.math.BigDecimal;

/**
 * DTO for {@link WaterDelivery}
 */
@Value
@Builder
public class WaterDeliveryCreateRequestDto implements Serializable {

    BigDecimal priceAmount;
    Boolean autoAssignDriver;
    DropOffLocationRequestDto dropOffLocation;
    @NotNull(message = "is scheduled can be either true or false ")
    Boolean isScheduled;
    String deliveryInstructions;
    ScheduledDetailsRequestDto scheduledDetails;
}