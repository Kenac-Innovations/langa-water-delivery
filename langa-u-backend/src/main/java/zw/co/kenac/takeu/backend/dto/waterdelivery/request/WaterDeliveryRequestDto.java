package zw.co.kenac.takeu.backend.dto.waterdelivery.request;

import jakarta.validation.constraints.Min;
import jakarta.validation.constraints.NotNull;
import lombok.Data;


import java.time.LocalDateTime;

@Data
public class WaterDeliveryRequestDto {

    @NotNull(message = "Quantity is required")
    @Min(value = 1, message = "Quantity must be at least 1")
    private Integer quantity;
    private Long selectedAddress;



    @NotNull(message = "Delivery date is required")
    private LocalDateTime deliveryDate;

    private String deliveryNotes;
} 