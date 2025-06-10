package zw.co.kenac.takeu.backend.dto.driver;

import lombok.Builder;

@Builder
public record ReviewDriverProfileDto(Long driverId, String status, String reason) {
}
