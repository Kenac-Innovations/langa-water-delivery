package zw.co.kenac.takeu.backend.dto.internal;

import java.time.LocalDateTime;

/**
 * @author : Jaison.Chipuka
 * @email : jaisonc@kenac.co.zw
 * @project : take-u-backend on 6/5/2025
 */
public record DriverResponse(
        Long id,
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
        Long userId
) { }
