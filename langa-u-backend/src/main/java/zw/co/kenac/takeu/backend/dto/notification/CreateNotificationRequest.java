package zw.co.kenac.takeu.backend.dto.notification;

/**
 * DTO for creating a new notification
 */
public record CreateNotificationRequest(
    String title,
    String message,
    Long userId,
    String notificationType,
    Long referenceId
) {}
