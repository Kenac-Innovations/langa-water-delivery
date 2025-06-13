package zw.co.kenac.takeu.backend.dto.internal;

/**
 * @author : Jaison.Chipuka
 * @email : jaisonc@kenac.co.zw
 * @project : take-u-backend on 6/5/2025
 */
public record VehicleResponse(
        Long vehicleId,
        String vehicleModel,
        String vehicleColor,
        String vehicleMake,
        String licensePlateNo,
        Boolean active,
        String vehicleType,
        String vehicleStatus,
        Long driverId,
        String driverName,
        String registrationBookUrl,
        String frontImageUrl,
        String backImageUrl,
        String sideImageUrl
) {
}
