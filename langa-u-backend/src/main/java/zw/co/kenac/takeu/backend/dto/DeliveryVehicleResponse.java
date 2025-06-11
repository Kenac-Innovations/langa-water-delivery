package zw.co.kenac.takeu.backend.dto;

public record DeliveryVehicleResponse(
        Long vehicleId,
        String vehicleModel,
        String vehicleColor,
        String vehicleMake,
        String licensePlateNo,
        String vehicleType
) { }
