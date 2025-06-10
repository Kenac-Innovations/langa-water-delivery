package zw.co.kenac.takeu.backend.dto.driver;

public record DriverVehicleResponse(
    Long vehicleId,
    String vehicleModel,
    String vehicleColor,
    String vehicleMake,
    String licensePlateNo,
    Boolean active,
    String vehicleType,
    String vehicleStatus,
    String driverName,
    String registrationBookUrl,
    String frontImageUrl,
    String backImageUrl,
    String sideImageUrl
) { }
