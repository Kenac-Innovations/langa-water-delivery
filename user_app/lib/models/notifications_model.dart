import 'package:equatable/equatable.dart';
import 'package:langas_user/util/apps_enums.dart';

class NotificationModel extends Equatable {
  final int id;
  final String title;
  final String message;
  final bool read;
  final int userId;
  final DateTime createdAt;
  final DateTime updatedAt;
  final NotificationType notificationType;
  final int? referenceId;

  const NotificationModel({
    required this.id,
    required this.title,
    required this.message,
    required this.read,
    required this.userId,
    required this.createdAt,
    required this.updatedAt,
    required this.notificationType,
    this.referenceId,
  });

  @override
  List<Object?> get props => [
        id,
        title,
        message,
        read,
        userId,
        createdAt,
        updatedAt,
        notificationType,
        referenceId,
      ];

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: json['id'] as int? ?? 0,
      title: json['title'] as String? ?? '',
      message: json['message'] as String? ?? '',
      read: json['read'] as bool? ?? false,
      userId: json['userId'] as int? ?? 0,
      createdAt: DateTime.tryParse(json['createdAt'] as String? ?? '') ??
          DateTime.now(),
      updatedAt: DateTime.tryParse(json['updatedAt'] as String? ?? '') ??
          DateTime.now(),
      notificationType:
          NotificationType.fromJson(json['notificationType'] as String?),
      referenceId: json['referenceId'] as int?,
    );
  }
}
