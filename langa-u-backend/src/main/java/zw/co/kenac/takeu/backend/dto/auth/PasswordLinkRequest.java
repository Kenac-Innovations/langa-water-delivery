package zw.co.kenac.takeu.backend.dto.auth;

import lombok.Builder;

@Builder
public record PasswordLinkRequest(String loginId) {
}
