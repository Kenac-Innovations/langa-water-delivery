package zw.co.kenac.takeu.backend.dto.auth;

public record LoginResponse(
        String accessToken,
        String refreshToken,
        String userType,
        Long userID,
        String firstname,
        String lastname,
        String emailAddress,
        String mobileNumber
) { }
