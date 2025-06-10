package zw.co.kenac.takeu.backend.dto.auth;

/**
 * DTO for password reset request
 */
public record PasswordResetRequest(String loginId, String token, String newPassword) {
}
