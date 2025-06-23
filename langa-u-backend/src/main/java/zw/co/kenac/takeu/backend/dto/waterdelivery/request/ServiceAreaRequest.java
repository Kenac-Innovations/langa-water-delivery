package zw.co.kenac.takeu.backend.dto.waterdelivery.request;


import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Positive;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

/**
 * Created by dyland
 * Email: dyland@kenac.co.zw
 * Created on: 15/6/2025
 */
@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class ServiceAreaRequest {

    @NotBlank(message = "Name is required")
    private String name;

    @NotNull(message = "Latitude is required")
    private Double latitude;

    @NotNull(message = "Longitude is required")
    private Double longitude;

    @NotNull(message = "Radius is required")
    @Positive(message = "Radius must be positive")
    private Double radiusKm;

    private Boolean active = true;

    private String description;
}