package zw.co.kenac.takeu.backend.dto.driver;

/**
 * @author : Jaison.Chipuka
 * @email : jaisonc@kenac.co.zw
 * @project : take-u-backend on 22/4/2025
 */
public record CompleteDeliveryRequest(
        String otp,
        Long driverId,
        Double latitude,
        Double longitude
) {
}
