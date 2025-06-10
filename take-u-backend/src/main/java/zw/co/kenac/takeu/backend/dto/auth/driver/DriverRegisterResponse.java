package zw.co.kenac.takeu.backend.dto.auth.driver;

public record DriverRegisterResponse(
        Long userId,
        String email,
        String phoneNumber
) { }
