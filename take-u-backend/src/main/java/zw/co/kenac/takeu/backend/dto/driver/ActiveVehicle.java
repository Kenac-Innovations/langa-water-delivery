package zw.co.kenac.takeu.backend.dto.driver;

public record ActiveVehicle(
        Long vehicleId,
        String vehicleModel,
        String vehicleColor,
        String vehicleMake,
        String licensePlateNo,
        String vehicleType,
        String frontImageUrl,
        String sideImageUrl,
        String registrationBookUrl
) { }
