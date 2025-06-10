package zw.co.kenac.takeu.backend.dto.driver;

import java.math.BigDecimal;
import java.time.LocalDateTime;

public record DriverProfile(
        Long driverID,
        String firstname,
        String lastname,
        String middleName,
        String gender,
        String mobileNumber,
        String email,
        String address,
        String nationalIdNo,
        String driverLicenseNo,
        String approvalStatus,
        String approvedBy,
        LocalDateTime dateApproved,
        String profilePhotoUrl,
        String nationalIdImage,
        String driversLicenseUrl,
        Long userId,
        Long walletId,
        ActiveVehicle activeVehicle,
        Boolean onlineStatus,
        Double searchRadiusInKm,
        BigDecimal rating,
        Integer numberOfDeliveries,
        Boolean isBusy
) {
}
