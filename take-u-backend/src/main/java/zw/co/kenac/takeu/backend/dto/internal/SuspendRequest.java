package zw.co.kenac.takeu.backend.dto.internal;

public record SuspendRequest(
        String status,
        String reason,
        String suspendedBy
) {
}
