package zw.co.kenac.takeu.backend.dto.auth.driver;

public record DriverLoginResponse(
        String accessToken,
        String refreshToken,
        String userType,
        Long userID,
        DriverProfileResponse driverProfile
) { }
