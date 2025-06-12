package zw.co.kenac.takeu.backend.dto.waterdelivery.request;

import lombok.Builder;
import lombok.Value;
import zw.co.kenac.takeu.backend.model.waterdelivery.WaterOrder;
import zw.co.kenac.takeu.backend.model.enumeration.OrderStatus;
import zw.co.kenac.takeu.backend.model.enumeration.PaymentStatus;

import java.io.Serializable;
import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.util.List;

/**
 * DTO for {@link WaterOrder}
 */
@Value
@Builder
public class WaterOrderCreateRequestDto implements Serializable {
    Long entityId;
    LocalDateTime createdDate;
    LocalDateTime lastModifiedDate;
    OrderStatus orderStatus;
    List<WaterDeliveryRequestDto> deliveries;
    PaymentStatus paymentStatus;
    BigDecimal totalAmount;
    LocalDateTime orderDate;
}