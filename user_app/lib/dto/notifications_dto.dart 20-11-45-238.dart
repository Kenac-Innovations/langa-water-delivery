import 'package:langas_user/dto/delivery_dto.dart';
import 'package:langas_user/models/notifications_model.dart';
import 'package:langas_user/util/api_pagenated_model.dart';
import 'package:langas_user/util/apps_enums.dart';

class UpdateNotificationStatusRequestDto {
  final int notificationId;
  final bool read;

  UpdateNotificationStatusRequestDto({
    required this.notificationId,
    required this.read,
  });

  Map<String, dynamic> toJson() {
    return {
      'notificationId': notificationId,
      'read': read,
    };
  }
}

class NotificationDto {
  final int id;
  final String? title;
  final String? message;
  final bool? read;
  final int? userId;
  final String? createdAt;
  final String? updatedAt;
  final String? notificationType;
  final int? referenceId;

  NotificationDto({
    required this.id,
    this.title,
    this.message,
    this.read,
    this.userId,
    this.createdAt,
    this.updatedAt,
    this.notificationType,
    this.referenceId,
  });

  factory NotificationDto.fromJson(Map<String, dynamic> json) {
    return NotificationDto(
      id: json['id'] as int? ?? 0,
      title: json['title'] as String?,
      message: json['message'] as String?,
      read: json['read'] as bool?,
      userId: json['userId'] as int?,
      createdAt: json['createdAt'] as String?,
      updatedAt: json['updatedAt'] as String?,
      notificationType: json['notificationType'] as String?,
      referenceId: json['referenceId'] as int?,
    );
  }

  NotificationModel toDomain() {
    return NotificationModel(
      id: id,
      title: title ?? '',
      message: message ?? '',
      read: read ?? false,
      userId: userId ?? 0,
      createdAt: DateTime.tryParse(createdAt ?? '') ?? DateTime.now(),
      updatedAt: DateTime.tryParse(updatedAt ?? '') ?? DateTime.now(),
      notificationType: NotificationType.fromJson(notificationType),
      referenceId: referenceId,
    );
  }
}

class PaginatedNotificationResponseDto {
  final List<NotificationDto>? content;
  final PaginationDto? pagination;

  PaginatedNotificationResponseDto({
    this.content,
    this.pagination,
  });

  factory PaginatedNotificationResponseDto.fromJson(Map<String, dynamic> json) {
    var contentList = json['content'] as List<dynamic>?;
    List<NotificationDto>? notifications;
    if (contentList != null) {
      notifications = contentList
          .map((item) => NotificationDto.fromJson(item as Map<String, dynamic>))
          .toList();
    }

    PaginationDto? paginationData;
    if (json['pagination'] != null) {
      paginationData =
          PaginationDto.fromJson(json['pagination'] as Map<String, dynamic>);
    }

    return PaginatedNotificationResponseDto(
      content: notifications,
      pagination: paginationData,
    );
  }

  PaginatedResponse<NotificationModel> toDomain() {
    return PaginatedResponse(
      content: content?.map((dto) => dto.toDomain()).toList() ?? [],
      pagination: pagination ??
          PaginationDto(total: 0, totalPages: 0, pageNumber: 0, pageSize: 0),
    );
  }
}
