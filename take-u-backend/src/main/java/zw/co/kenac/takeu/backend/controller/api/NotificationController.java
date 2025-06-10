package zw.co.kenac.takeu.backend.controller.api;

import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import zw.co.kenac.takeu.backend.dto.GenericResponse;
import zw.co.kenac.takeu.backend.dto.PaginatedResponse;
import zw.co.kenac.takeu.backend.dto.notification.CreateNotificationRequest;
import zw.co.kenac.takeu.backend.dto.notification.NotificationDto;
import zw.co.kenac.takeu.backend.dto.notification.NotificationUpdateRequest;

import java.util.List;

@Tag(name = "Notification Services", description = "Notification management endpoints")
@RequestMapping("${custom.base.path}/notifications")
public interface NotificationController {

    @Operation(summary = "Get all notifications for a user with optional filtering")
    @GetMapping("/user/{userId}")
    ResponseEntity<GenericResponse<PaginatedResponse<NotificationDto>>> getUserNotifications(
            @PathVariable Long userId,
            @RequestParam(defaultValue = "1") int pageNumber,
            @RequestParam(defaultValue = "10") int pageSize,
            @RequestParam(defaultValue = "ALL") String filterBy
    );

    @Operation(summary = "Get a specific notification by ID")
    @GetMapping("/{id}")
    ResponseEntity<GenericResponse<NotificationDto>> getNotificationById(
            @PathVariable("id") Long notificationId
    );

    @Operation(summary = "Get recent notifications for a user (limited to 5)")
    @GetMapping("/recent/{userId}")
    ResponseEntity<GenericResponse<List<NotificationDto>>> getRecentNotifications(
            @PathVariable Long userId
    );
    
    @Operation(summary = "Get count of unread notifications for a user")
    @GetMapping("/unread-count/{userId}")
    ResponseEntity<GenericResponse<Long>> getUnreadCount(
            @PathVariable Long userId
    );

    @Operation(summary = "Update a notification's read status")
    @PutMapping("/update-status")
    ResponseEntity<GenericResponse<NotificationDto>> updateNotificationReadStatus(
            @RequestBody NotificationUpdateRequest request
    );

    @Operation(summary = "Mark all notifications as read for a user")
    @PutMapping("/mark-all-read/{userId}")
    ResponseEntity<GenericResponse<String>> markAllAsRead(
            @PathVariable Long userId
    );
    
    @Operation(summary = "Create a new notification")
    @PostMapping
    ResponseEntity<GenericResponse<NotificationDto>> createNotification(
            @RequestBody CreateNotificationRequest request
    );

    @Operation(summary = "Delete a notification")
    @DeleteMapping("/{id}")
    ResponseEntity<GenericResponse<String>> deleteNotification(
            @PathVariable("id") Long notificationId
    );
}
