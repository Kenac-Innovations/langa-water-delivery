import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:langas_user/bloc/notification/notification_bloc_event.dart';
import 'package:langas_user/bloc/notification/notification_bloc_state.dart';
import 'package:langas_user/models/notifications_model.dart';
import 'package:langas_user/repository/notification_repository.dart';
import 'package:langas_user/util/api_pagenated_model.dart';
import 'package:langas_user/util/apps_enums.dart';

class NotificationBloc extends Bloc<NotificationEvent, NotificationState> {
  final NotificationRepository _notificationRepository;

  NotificationBloc({required NotificationRepository notificationRepository})
      : _notificationRepository = notificationRepository,
        super(NotificationInitial()) {
    on<FetchNotifications>(_onFetchNotifications);
    on<UpdateNotificationStatusEvent>(_onUpdateNotificationStatus);
    on<MarkAllNotificationsAsReadEvent>(_onMarkAllNotificationsAsRead);
    on<DeleteNotificationByIdEvent>(_onDeleteNotificationById);
    on<FetchUnreadNotificationCount>(_onFetchUnreadNotificationCount);
  }

  Future<void> _onFetchNotifications(
      FetchNotifications event, Emitter<NotificationState> emit) async {
    emit(NotificationLoading());
    final result = await _notificationRepository.getNotificationsByUserId(
      userId: event.userId,
      pageNumber: event.pageNumber,
      pageSize: event.pageSize,
    );
    result.fold(
      (failure) => emit(NotificationOperationFailure(failure: failure)),
      (notifications) =>
          emit(NotificationsLoadSuccess(notifications: notifications)),
    );
  }

  Future<void> _onUpdateNotificationStatus(UpdateNotificationStatusEvent event,
      Emitter<NotificationState> emit) async {
    final currentState = state;
    emit(NotificationLoading());
    final result = await _notificationRepository
        .updateNotificationStatus(event.requestDto);
    result.fold(
      (failure) => emit(NotificationOperationFailure(failure: failure)),
      (updatedNotification) {
        emit(NotificationUpdateSuccess(notification: updatedNotification));
        if (currentState is NotificationsLoadSuccess) {
          final updatedList = currentState.notifications.content.map((n) {
            return n.id == updatedNotification.id ? updatedNotification : n;
          }).toList();
          emit(NotificationsLoadSuccess(
              notifications: PaginatedResponse(
                  content: updatedList,
                  pagination: currentState.notifications.pagination)));
        }
      },
    );
  }

  Future<void> _onMarkAllNotificationsAsRead(
      MarkAllNotificationsAsReadEvent event,
      Emitter<NotificationState> emit) async {
    final currentState = state;
    emit(NotificationLoading());
    final result =
        await _notificationRepository.markAllNotificationsAsRead(event.userId);
    result.fold(
      (failure) => emit(NotificationOperationFailure(failure: failure)),
      (message) {
        emit(MarkAllReadSuccess(message: message));
        if (currentState is NotificationsLoadSuccess) {
          final updatedList = currentState.notifications.content.map((n) {
            return n.copyWith(
                read: true); // Assuming NotificationModel has copyWith
          }).toList();
          emit(NotificationsLoadSuccess(
              notifications: PaginatedResponse(
                  content: updatedList,
                  pagination: currentState.notifications.pagination)));
        }
      },
    );
  }

  Future<void> _onDeleteNotificationById(DeleteNotificationByIdEvent event,
      Emitter<NotificationState> emit) async {
    final currentState = state;
    emit(NotificationLoading());
    final result = await _notificationRepository
        .deleteNotificationById(event.notificationId);
    result.fold(
      (failure) => emit(NotificationOperationFailure(failure: failure)),
      (message) {
        emit(NotificationDeleteSuccess(
            message: message, deletedNotificationId: event.notificationId));
        if (currentState is NotificationsLoadSuccess) {
          final updatedList = currentState.notifications.content
              .where((n) => n.id != event.notificationId)
              .toList();
          emit(NotificationsLoadSuccess(
              notifications: PaginatedResponse(
                  content: updatedList,
                  pagination: currentState.notifications.pagination)));
        }
      },
    );
  }

  Future<void> _onFetchUnreadNotificationCount(
      FetchUnreadNotificationCount event,
      Emitter<NotificationState> emit) async {
    emit(NotificationLoading());
    final result =
        await _notificationRepository.getUnreadNotificationCount(event.userId);
    result.fold(
      (failure) => emit(NotificationOperationFailure(failure: failure)),
      (count) => emit(UnreadCountSuccess(count: count)),
    );
  }
}

extension NotificationModelCopyWith on NotificationModel {
  NotificationModel copyWith({
    int? id,
    String? title,
    String? message,
    bool? read,
    int? userId,
    DateTime? createdAt,
    DateTime? updatedAt,
    NotificationType? notificationType,
    int? referenceId,
  }) {
    return NotificationModel(
      id: id ?? this.id,
      title: title ?? this.title,
      message: message ?? this.message,
      read: read ?? this.read,
      userId: userId ?? this.userId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      notificationType: notificationType ?? this.notificationType,
      referenceId: referenceId ?? this.referenceId,
    );
  }
}
