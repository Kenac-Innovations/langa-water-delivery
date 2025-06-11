package zw.co.kenac.takeu.backend.dto.auth.client;

public record ClientRegisterRequest(
        String phoneNumber,
        String email,
        String firstname,
        String lastname,
        String password
) { }
