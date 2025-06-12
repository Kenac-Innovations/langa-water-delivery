package zw.co.kenac.takeu.backend.dto.waterdelivery.request;

import jakarta.validation.Valid;
import jakarta.validation.constraints.NotEmpty;
import jakarta.validation.constraints.NotNull;
import lombok.Data;


import java.util.List;

@Data
public class CreateWaterOrderRequest {

    @NotNull(message = "Client ID is required")
    private Long clientId;

    @NotNull(message = "Delivery address is required")
    private String deliveryAddress;

    private String specialInstructions;

    @NotEmpty(message = "At least one delivery is required")
    @Valid
    private List<WaterDeliveryRequestDto> deliveries;
} 