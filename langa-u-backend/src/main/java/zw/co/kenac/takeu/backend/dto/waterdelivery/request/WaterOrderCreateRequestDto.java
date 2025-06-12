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
    Long clientId;
    LocalDateTime createdDate;
    LocalDateTime lastModifiedDate;
    String promoCode;
    OrderStatus orderStatus;
    List<WaterDeliveryCreateRequestDto> deliveries;
    PaymentStatus paymentStatus;
    BigDecimal totalAmount;
    LocalDateTime orderDate;
}