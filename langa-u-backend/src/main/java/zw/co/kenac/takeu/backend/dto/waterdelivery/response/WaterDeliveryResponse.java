package zw.co.kenac.takeu.backend.dto.waterdelivery.response;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;
import zw.co.kenac.takeu.backend.model.enumeration.DeliveryStatus;

import java.math.BigDecimal;
import java.time.LocalDateTime;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class WaterDeliveryResponse {
    private Long deliveryId;
    private Integer quantity;
    private LocalDateTime deliveryDate;
    private String deliveryNotes;
    private DeliveryStatus status;
    private BigDecimal unitPrice;
    private BigDecimal totalPrice;
} 