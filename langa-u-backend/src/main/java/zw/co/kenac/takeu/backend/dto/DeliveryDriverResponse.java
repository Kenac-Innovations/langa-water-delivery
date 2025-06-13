package zw.co.kenac.takeu.backend.dto;

public record DeliveryDriverResponse(
        Long driverId,
        String firstname,
        String lastname,
        String gender,
        String mobileNumber,
        String nationalId,
        String profilePhotoUrl,
        String nationalIdUrl,
        String driversLicenseUrl
) { }
