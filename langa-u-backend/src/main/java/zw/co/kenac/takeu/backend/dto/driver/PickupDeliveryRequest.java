package zw.co.kenac.takeu.backend.dto.driver;

import jakarta.validation.constraints.NotNull;
import org.springframework.web.multipart.MultipartFile;

/**
 * @author : Jaison.Chipuka
 * @email : jaisonc@kenac.co.zw
 * @project : take-u-backend on 22/4/2025
 */
public record PickupDeliveryRequest(
        @NotNull Long driverId,
        MultipartFile pickupImage,
        @NotNull Double latitude,
        @NotNull Double longitude
) { }
