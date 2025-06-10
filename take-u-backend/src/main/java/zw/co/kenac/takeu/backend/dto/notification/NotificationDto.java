package zw.co.kenac.takeu.backend.dto.notification;

import java.time.LocalDateTime;

/**
 * DTO for transferring notification data
 */
public record NotificationDto(
    Long id,
    String title,
    String message,
    boolean read,
    Long userId,
    LocalDateTime createdAt,
    LocalDateTime updatedAt,
    String notificationType,
    Long referenceId
) {}
