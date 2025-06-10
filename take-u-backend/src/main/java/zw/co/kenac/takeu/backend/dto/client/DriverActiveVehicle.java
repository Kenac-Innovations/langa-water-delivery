package zw.co.kenac.takeu.backend.dto.client;

public record DriverActiveVehicle(
        Long vehicleId,
        String vehicleModel,
        String vehicleColor,
        String vehicleMake,
        String licensePlateNo,
        String vehicleType
) { }
