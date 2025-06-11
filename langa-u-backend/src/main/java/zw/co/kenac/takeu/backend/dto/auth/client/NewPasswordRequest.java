package zw.co.kenac.takeu.backend.dto.auth.client;

import lombok.Data;

@Data
public class NewPasswordRequest {
    private String token;
    private String newPassword;
} 