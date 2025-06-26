import 'package:flutter/foundation.dart' show immutable, required;

@immutable
class UpdateNotificationStatusRequest {
  final int notificationId;
  final bool read;

  const UpdateNotificationStatusRequest({
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
