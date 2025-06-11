package zw.co.kenac.takeu.backend.service.internal.impl;

import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageRequest;
import org.springframework.data.domain.Pageable;
import org.springframework.data.domain.Sort;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import zw.co.kenac.takeu.backend.dto.CustomPagination;
import zw.co.kenac.takeu.backend.dto.PaginatedResponse;
import zw.co.kenac.takeu.backend.dto.notification.CreateNotificationRequest;
import zw.co.kenac.takeu.backend.dto.notification.NotificationDto;
import zw.co.kenac.takeu.backend.dto.notification.NotificationUpdateRequest;
import zw.co.kenac.takeu.backend.exception.custom.ResourceNotFoundException;
import zw.co.kenac.takeu.backend.model.NotificationEntity;
import zw.co.kenac.takeu.backend.model.UserEntity;
import zw.co.kenac.takeu.backend.repository.NotificationRepository;
import zw.co.kenac.takeu.backend.repository.UserRepository;
import zw.co.kenac.takeu.backend.service.internal.NotificationService;

import java.time.LocalDateTime;
import java.util.List;

import static zw.co.kenac.takeu.backend.constant.AppConstant.NOT_FOUND;


@Slf4j
@Service
@RequiredArgsConstructor
public class NotificationServiceImpl implements NotificationService {

    private final NotificationRepository notificationRepository;
    private final UserRepository userRepository;

    @Override
    public PaginatedResponse<NotificationDto> getUserNotifications(Long userId, int pageNumber, int pageSize, String filterBy) {
        Pageable pageable = PageRequest.of(pageNumber - 1, pageSize, Sort.by("createdAt").descending());
        Page<NotificationEntity> notificationsPage;
        
        if (filterBy.equalsIgnoreCase("READ")) {
            notificationsPage = notificationRepository.findByUserEntityIdAndRead(userId, true, pageable);
        } else if (filterBy.equalsIgnoreCase("UNREAD")) {
            notificationsPage = notificationRepository.findByUserEntityIdAndRead(userId, false, pageable);
        } else {
            notificationsPage = notificationRepository.findByUserEntityId(userId, pageable);
        }
        
        return paginateResponse(notificationsPage);
    }

    @Override
    public NotificationDto getNotificationById(Long notificationId) {
        NotificationEntity notification = notificationRepository.findById(notificationId)
                .orElseThrow(() -> new ResourceNotFoundException(NOT_FOUND));
        return mapToDto(notification);
    }

    @Override
    @Transactional
    public NotificationDto updateNotificationReadStatus(NotificationUpdateRequest request) {
        NotificationEntity notification = notificationRepository.findById(request.notificationId())
                .orElseThrow(() -> new ResourceNotFoundException(NOT_FOUND));
        
        notification.setRead(request.read());
        notification.setUpdatedAt(LocalDateTime.now());
        notification = notificationRepository.save(notification);
        
        return mapToDto(notification);
    }

    @Override
    public List<NotificationDto> getRecentNotifications(Long userId) {
        List<NotificationEntity> notifications = notificationRepository.findTop5ByUserEntityIdOrderByCreatedAtDesc(userId);
        return notifications.stream()
                .map(this::mapToDto)
                .toList();
    }

    @Override
    @Transactional
    public NotificationDto createNotification(CreateNotificationRequest request) {
        UserEntity user = userRepository.findById(request.userId())
                .orElseThrow(() -> new ResourceNotFoundException("User not found"));
        
        NotificationEntity notification = NotificationEntity.builder()
                .title(request.title())
                .message(request.message())
                .read(false)
                .user(user)
                .createdAt(LocalDateTime.now())
                .updatedAt(LocalDateTime.now())
                .notificationType(request.notificationType())
                .referenceId(request.referenceId())
                .build();
        
        notification = notificationRepository.save(notification);
        return mapToDto(notification);
    }

    @Override
    @Transactional
    public void markAllAsRead(Long userId) {
        notificationRepository.markAllAsReadForUser(userId);
    }

    @Override
    @Transactional
    public void deleteNotification(Long notificationId) {
        NotificationEntity notification = notificationRepository.findById(notificationId)
                .orElseThrow(() -> new ResourceNotFoundException(NOT_FOUND));
        notificationRepository.delete(notification);
    }
    
    @Override
    public Long getUnreadCount(Long userId) {
        return notificationRepository.countByUserEntityIdAndRead(userId, false);
    }

    private NotificationDto mapToDto(NotificationEntity notification) {
        return new NotificationDto(
                notification.getEntityId(),
                notification.getTitle(),
                notification.getMessage(),
                notification.isRead(),
                notification.getUser().getEntityId(),
                notification.getCreatedAt(),
                notification.getUpdatedAt(),
                notification.getNotificationType(),
                notification.getReferenceId()
        );
    }

    private PaginatedResponse<NotificationDto> paginateResponse(Page<NotificationEntity> page) {
        List<NotificationEntity> notifications = page.getContent();
        
        List<NotificationDto> mappedNotifications = notifications.stream()
                .map(this::mapToDto)
                .toList();
        
        CustomPagination pagination = new CustomPagination(
                page.getTotalElements(),
                page.getTotalPages(),
                page.getNumber() + 1,
                page.getSize()
        );
        
        return new PaginatedResponse<>(mappedNotifications, pagination);
    }
}
