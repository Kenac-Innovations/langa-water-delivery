import 'package:equatable/equatable.dart';
import 'package:langas_driver/dto/notification_dto.dart';

abstract class NotificationEvent extends Equatable {
  const NotificationEvent();

  @override
  List<Object?> get props => [];
}

class FetchUserNotifications extends NotificationEvent {
  final String userId;
  final int pageNumber;
  final int pageSize;
  final bool isRefresh;

  const FetchUserNotifications({
    required this.userId,
    this.pageNumber = 1,
    this.pageSize = 20,
    this.isRefresh = false,
  });

  @override
  List<Object?> get props => [userId, pageNumber, pageSize, isRefresh];
}

class FetchMoreUserNotifications extends NotificationEvent {
  final String userId;

  const FetchMoreUserNotifications({required this.userId});

  @override
  List<Object?> get props => [userId];
}

class UpdateNotificationStatusRequested extends NotificationEvent {
  final UpdateNotificationStatusRequest request;

  const UpdateNotificationStatusRequested({required this.request});

  @override
  List<Object?> get props => [request];
}

class MarkAllNotificationsAsReadRequested extends NotificationEvent {
  final String userId;

  const MarkAllNotificationsAsReadRequested({required this.userId});

  @override
  List<Object?> get props => [userId];
}

class DeleteNotificationRequested extends NotificationEvent {
  final String notificationId;

  const DeleteNotificationRequested({required this.notificationId});

  @override
  List<Object?> get props => [notificationId];
}

class FetchUnreadNotificationCount extends NotificationEvent {
  final String userId;

  const FetchUnreadNotificationCount({required this.userId});

  @override
  List<Object?> get props => [userId];
}
