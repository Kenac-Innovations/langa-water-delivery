package zw.co.kenac.takeu.backend.dto.waterdelivery.response;

import lombok.Builder;
import lombok.Data;
import zw.co.kenac.takeu.backend.model.enumeration.OrderStatus;
import zw.co.kenac.takeu.backend.model.enumeration.PaymentStatus;

import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.util.List;

@Data
@Builder
public class WaterOrderResponse {
    private Long orderId;
    private Long clientId;
    private String clientName;
    private String deliveryAddress;
    private String specialInstructions;
    private OrderStatus orderStatus;
    private PaymentStatus paymentStatus;
    private BigDecimal totalAmount;
    private LocalDateTime orderDate;
    private List<WaterDeliveryResponse> deliveries;
} 