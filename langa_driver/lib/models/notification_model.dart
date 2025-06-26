import 'package:flutter/foundation.dart' show immutable;
import 'package:langas_driver/models/delivery_models.dart' show Pagination;
import 'package:langas_driver/utils/app_enums.dart';

@immutable
class NotificationModel {
  final int id;
  final String title;
  final String message;
  final bool read;
  final int userId;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final NotificationType notificationType;
  final int? referenceId;

  const NotificationModel({
    required this.id,
    required this.title,
    required this.message,
    required this.read,
    required this.userId,
    this.createdAt,
    this.updatedAt,
    required this.notificationType,
    this.referenceId,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: json['id'] as int? ?? 0,
      title: json['title'] as String? ?? '',
      message: json['message'] as String? ?? '',
      read: json['read'] as bool? ?? false,
      userId: json['userId'] as int? ?? 0,
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'] as String)
          : null,
      updatedAt: json['updatedAt'] != null
          ? DateTime.tryParse(json['updatedAt'] as String)
          : null,
      notificationType:
          NotificationType.fromJson(json['notificationType'] as String?),
      referenceId: json['referenceId'] as int?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'message': message,
      'read': read,
      'userId': userId,
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      'notificationType': notificationType.toJson(),
      'referenceId': referenceId,
    };
  }
}

@immutable
class PaginatedNotifications {
  final List<NotificationModel> content;
  final Pagination pagination;

  const PaginatedNotifications({
    required this.content,
    required this.pagination,
  });

  factory PaginatedNotifications.fromJson(Map<String, dynamic> json) {
    var contentList = <NotificationModel>[];
    if (json['content'] is List) {
      contentList = (json['content'] as List)
          .map((item) =>
              NotificationModel.fromJson(item as Map<String, dynamic>))
          .toList();
    }
    return PaginatedNotifications(
      content: contentList,
      pagination: Pagination.fromJson(
          json['pagination'] as Map<String, dynamic>? ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'content': content.map((notification) => notification.toJson()).toList(),
      'pagination': pagination.toJson(),
    };
  }
}
