package zw.co.kenac.takeu.backend.dto.client;

public record AvailableDriverResponse(
        Long driverID,
        String email,
        String phoneNumber,
        String firstname,
        String lastname,
        String gender,
        String profilePhotoUrl,
        double rating,
        double longitude,
        double latitude,
        long totalDeliveries,
        DriverActiveVehicle activeVehicle
) { }
