import 'package:equatable/equatable.dart';
import 'package:langas_user/models/notifications_model.dart';
import 'package:langas_user/util/api_failure_models.dart';
import 'package:langas_user/util/api_pagenated_model.dart';

abstract class NotificationState extends Equatable {
  const NotificationState();

  @override
  List<Object?> get props => [];
}

class NotificationInitial extends NotificationState {}

class NotificationLoading extends NotificationState {}

class NotificationsLoadSuccess extends NotificationState {
  final PaginatedResponse<NotificationModel> notifications;

  const NotificationsLoadSuccess({required this.notifications});

  @override
  List<Object?> get props => [notifications];
}

class NotificationUpdateSuccess extends NotificationState {
  final NotificationModel notification;
  const NotificationUpdateSuccess({required this.notification});

  @override
  List<Object?> get props => [notification];
}

class MarkAllReadSuccess extends NotificationState {
  final String message;
  const MarkAllReadSuccess({required this.message});
  @override
  List<Object?> get props => [message];
}

class NotificationDeleteSuccess extends NotificationState {
  final String message;
  final int deletedNotificationId;
  const NotificationDeleteSuccess(
      {required this.message, required this.deletedNotificationId});
  @override
  List<Object?> get props => [message, deletedNotificationId];
}

class UnreadCountSuccess extends NotificationState {
  final int count;
  const UnreadCountSuccess({required this.count});
  @override
  List<Object?> get props => [count];
}

class NotificationOperationFailure extends NotificationState {
  final Failure failure;
  const NotificationOperationFailure({required this.failure});
  @override
  List<Object?> get props => [failure];
}
