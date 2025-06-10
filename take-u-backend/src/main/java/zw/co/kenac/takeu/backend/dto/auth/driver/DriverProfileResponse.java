package zw.co.kenac.takeu.backend.dto.auth.driver;

import java.math.BigDecimal;

/**
 * @author : Jaison.Chipuka
 * @email : jaisonc@kenac.co.zw
 * @project : take-u-backend on 9/4/2025
 */
public record DriverProfileResponse(
        Long driverID,
        String email,
        String phoneNumber,
        String firstname,
        String lastname,
        String gender,
        String address,
        String profilePhotoUrl,
        String nationalIdNumber,
        BigDecimal walletBalance,
        Double rating,
        Long walletId,
        Boolean onlineStatus,
        Double searchRadiusInKm
) { }
