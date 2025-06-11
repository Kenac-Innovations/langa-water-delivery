package zw.co.kenac.takeu.backend.dto.notification;

/**
 * DTO for updating notification read status
 */
public record NotificationUpdateRequest(
    Long notificationId,
    boolean read
) {}
