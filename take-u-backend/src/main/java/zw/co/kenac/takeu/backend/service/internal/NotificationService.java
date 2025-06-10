package zw.co.kenac.takeu.backend.service.internal;

import zw.co.kenac.takeu.backend.dto.PaginatedResponse;
import zw.co.kenac.takeu.backend.dto.notification.CreateNotificationRequest;
import zw.co.kenac.takeu.backend.dto.notification.NotificationDto;
import zw.co.kenac.takeu.backend.dto.notification.NotificationUpdateRequest;
import zw.co.kenac.takeu.backend.model.NotificationEntity;

import java.util.List;


public interface NotificationService {
    

    PaginatedResponse<NotificationDto> getUserNotifications(Long userId, int pageNumber, int pageSize, String filterBy);
    

    NotificationDto getNotificationById(Long notificationId);
    

    NotificationDto updateNotificationReadStatus(NotificationUpdateRequest request);
    

    List<NotificationDto> getRecentNotifications(Long userId);
    

    NotificationDto createNotification(CreateNotificationRequest request);
    

    void markAllAsRead(Long userId);
    

    void deleteNotification(Long notificationId);
    

    Long getUnreadCount(Long userId);
}
