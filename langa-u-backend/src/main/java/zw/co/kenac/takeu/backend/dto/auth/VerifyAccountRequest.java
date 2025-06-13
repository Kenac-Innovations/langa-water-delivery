package zw.co.kenac.takeu.backend.dto.auth;

public record VerifyAccountRequest(String loginID, String otp) { }
