package zw.co.kenac.takeu.backend.dto.auth.client;

import lombok.Data;

@Data
public class PasswordResetOtpVerifyRequest {
    private String email;
    private String otp;
} 