package zw.co.kenac.takeu.backend.controller.api.impl;

import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.RestController;
import zw.co.kenac.takeu.backend.controller.api.NotificationController;
import zw.co.kenac.takeu.backend.dto.GenericResponse;
import zw.co.kenac.takeu.backend.dto.PaginatedResponse;
import zw.co.kenac.takeu.backend.dto.notification.CreateNotificationRequest;
import zw.co.kenac.takeu.backend.dto.notification.NotificationDto;
import zw.co.kenac.takeu.backend.dto.notification.NotificationUpdateRequest;
import zw.co.kenac.takeu.backend.service.internal.NotificationService;

import java.util.List;

import static zw.co.kenac.takeu.backend.dto.GenericResponse.success;


@RestController
@RequiredArgsConstructor
@Slf4j
public class NotificationControllerImpl implements NotificationController {

    private final NotificationService notificationService;

    @Override
    public ResponseEntity<GenericResponse<PaginatedResponse<NotificationDto>>> getUserNotifications(
            Long userId, int pageNumber, int pageSize, String filterBy) {
        log.info("Fetching notifications for user ID: {} with filter: {}", userId, filterBy);
        return ResponseEntity.ok(
                success(notificationService.getUserNotifications(userId, pageNumber, pageSize, filterBy))
        );
    }

    @Override
    public ResponseEntity<GenericResponse<NotificationDto>> getNotificationById(Long notificationId) {
        log.info("Fetching notification with ID: {}", notificationId);
        return ResponseEntity.ok(success(notificationService.getNotificationById(notificationId)));
    }

    @Override
    public ResponseEntity<GenericResponse<List<NotificationDto>>> getRecentNotifications(Long userId) {
        log.info("Fetching recent notifications for user ID: {}", userId);
        return ResponseEntity.ok(success(notificationService.getRecentNotifications(userId)));
    }
    
    @Override
    public ResponseEntity<GenericResponse<Long>> getUnreadCount(Long userId) {
        log.info("Fetching unread notification count for user ID: {}", userId);
        return ResponseEntity.ok(success(notificationService.getUnreadCount(userId)));
    }

    @Override
    public ResponseEntity<GenericResponse<NotificationDto>> updateNotificationReadStatus(
            NotificationUpdateRequest request) {
        log.info("Updating read status for notification ID: {} to {}", 
                request.notificationId(), request.read());
        return ResponseEntity.ok(success(notificationService.updateNotificationReadStatus(request)));
    }

    @Override
    public ResponseEntity<GenericResponse<String>> markAllAsRead(Long userId) {
        log.info("Marking all notifications as read for user ID: {}", userId);
        notificationService.markAllAsRead(userId);
        return ResponseEntity.ok(success("All notifications marked as read"));
    }
    
    @Override
    public ResponseEntity<GenericResponse<NotificationDto>> createNotification(
            CreateNotificationRequest request) {
        log.info("Creating notification for user ID: {}", request.userId());
        return ResponseEntity.status(HttpStatus.CREATED)
                .body(success(notificationService.createNotification(request)));
    }

    @Override
    public ResponseEntity<GenericResponse<String>> deleteNotification(Long notificationId) {
        log.info("Deleting notification with ID: {}", notificationId);
        notificationService.deleteNotification(notificationId);
        return ResponseEntity.ok(success("Notification deleted successfully"));
    }
}
