import 'package:equatable/equatable.dart';
import 'package:langas_user/dto/notifications_dto.dart';

abstract class NotificationEvent extends Equatable {
  const NotificationEvent();

  @override
  List<Object?> get props => [];
}

class FetchNotifications extends NotificationEvent {
  final int userId;
  final int pageNumber;
  final int pageSize;

  const FetchNotifications({
    required this.userId,
    this.pageNumber = 1,
    this.pageSize = 20,
  });

  @override
  List<Object?> get props => [userId, pageNumber, pageSize];
}

class UpdateNotificationStatusEvent extends NotificationEvent {
  final UpdateNotificationStatusRequestDto requestDto;

  const UpdateNotificationStatusEvent({required this.requestDto});

  @override
  List<Object?> get props => [requestDto];
}

class MarkAllNotificationsAsReadEvent extends NotificationEvent {
  final int userId;

  const MarkAllNotificationsAsReadEvent({required this.userId});

  @override
  List<Object?> get props => [userId];
}

class DeleteNotificationByIdEvent extends NotificationEvent {
  final int notificationId;

  const DeleteNotificationByIdEvent({required this.notificationId});

  @override
  List<Object?> get props => [notificationId];
}

class FetchUnreadNotificationCount extends NotificationEvent {
  final int userId;

  const FetchUnreadNotificationCount({required this.userId});

  @override
  List<Object?> get props => [userId];
}
