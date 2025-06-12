package zw.co.kenac.takeu.backend.dto.waterdelivery.request;


import jakarta.validation.constraints.NotNull;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

/**
 * Created by dyland
 * Email: dyland@kenac.co.zw
 * Created on: 12/6/2025
 */
@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class DriverWaterDeliveryCompleteRequest {
    @NotNull(message = " driver Id is missing")
    private Long driverId;
    @NotNull(message = " delivery Id is missing")
    private Long deliveryId;
    @NotNull(message = " OTPCode  is missing")
    private String otpCode;
}
