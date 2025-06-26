import 'package:equatable/equatable.dart';
import 'package:langas_driver/models/notification_model.dart';
import 'package:langas_driver/utils/failure_models.dart';

abstract class NotificationState extends Equatable {
  const NotificationState();

  @override
  List<Object?> get props => [];
}

class NotificationInitial extends NotificationState {}

class NotificationLoading extends NotificationState {}

class NotificationListLoading extends NotificationState {}

class NotificationListLoadSuccess extends NotificationState {
  final List<NotificationModel> notifications;
  final bool hasReachedMax;
  final int currentPage;
  final int pageSize;

  const NotificationListLoadSuccess({
    required this.notifications,
    required this.hasReachedMax,
    required this.currentPage,
    required this.pageSize,
  });

  NotificationListLoadSuccess copyWith({
    List<NotificationModel>? notifications,
    bool? hasReachedMax,
    int? currentPage,
    int? pageSize,
  }) {
    return NotificationListLoadSuccess(
      notifications: notifications ?? this.notifications,
      hasReachedMax: hasReachedMax ?? this.hasReachedMax,
      currentPage: currentPage ?? this.currentPage,
      pageSize: pageSize ?? this.pageSize,
    );
  }

  @override
  List<Object?> get props =>
      [notifications, hasReachedMax, currentPage, pageSize];
}

class NotificationListLoadFailure extends NotificationState {
  final Failure failure;
  const NotificationListLoadFailure({required this.failure});
  @override
  List<Object?> get props => [failure];
}

class NotificationListLoadingNextPage extends NotificationListLoadSuccess {
  const NotificationListLoadingNextPage({
    required super.notifications,
    required super.hasReachedMax,
    required super.currentPage,
    required super.pageSize,
  });
}

class NotificationListNextPageError extends NotificationListLoadSuccess {
  final Failure failure;
  const NotificationListNextPageError({
    required this.failure,
    required super.notifications,
    required super.hasReachedMax,
    required super.currentPage,
    required super.pageSize,
  });
  @override
  List<Object?> get props => [...super.props, failure];
}

class NotificationUpdateSuccess extends NotificationState {
  final NotificationModel updatedNotification;
  const NotificationUpdateSuccess({required this.updatedNotification});
  @override
  List<Object?> get props => [updatedNotification];
}

class NotificationUpdateFailure extends NotificationState {
  final Failure failure;
  const NotificationUpdateFailure({required this.failure});
  @override
  List<Object?> get props => [failure];
}

class NotificationMarkAllReadSuccess extends NotificationState {
  final String message;
  const NotificationMarkAllReadSuccess({required this.message});
  @override
  List<Object?> get props => [message];
}

class NotificationMarkAllReadFailure extends NotificationState {
  final Failure failure;
  const NotificationMarkAllReadFailure({required this.failure});
  @override
  List<Object?> get props => [failure];
}

class NotificationDeleteSuccess extends NotificationState {
  final String message;
  final String deletedNotificationId;
  const NotificationDeleteSuccess(
      {required this.message, required this.deletedNotificationId});
  @override
  List<Object?> get props => [message, deletedNotificationId];
}

class NotificationDeleteFailure extends NotificationState {
  final Failure failure;
  const NotificationDeleteFailure({required this.failure});
  @override
  List<Object?> get props => [failure];
}

class NotificationUnreadCountLoadSuccess extends NotificationState {
  final int count;
  const NotificationUnreadCountLoadSuccess({required this.count});
  @override
  List<Object?> get props => [count];
}

class NotificationUnreadCountLoadFailure extends NotificationState {
  final Failure failure;
  const NotificationUnreadCountLoadFailure({required this.failure});
  @override
  List<Object?> get props => [failure];
}
