import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:langas_driver/bloc/notification/notification_bloc_event.dart';
import 'package:langas_driver/bloc/notification/notification_bloc_state.dart';
import 'package:langas_driver/models/notification_model.dart';
import 'package:langas_driver/repository/notification_repository.dart';
import 'package:langas_driver/utils/api_response_model.dart';
import 'package:langas_driver/utils/failure_models.dart';
import 'package:dartz/dartz.dart';

class NotificationBloc extends Bloc<NotificationEvent, NotificationState> {
  final NotificationRepository _notificationRepository;

  NotificationBloc({required NotificationRepository notificationRepository})
      : _notificationRepository = notificationRepository,
        super(NotificationInitial()) {
    on<FetchUserNotifications>(_onFetchUserNotifications);
    on<FetchMoreUserNotifications>(_onFetchMoreUserNotifications);
    on<UpdateNotificationStatusRequested>(_onUpdateNotificationStatusRequested);
    on<MarkAllNotificationsAsReadRequested>(
        _onMarkAllNotificationsAsReadRequested);
    on<DeleteNotificationRequested>(_onDeleteNotificationRequested);
    on<FetchUnreadNotificationCount>(_onFetchUnreadNotificationCount);
  }

  Future<void> _onFetchUserNotifications(
      FetchUserNotifications event, Emitter<NotificationState> emit) async {
    if (event.pageNumber == 1 || event.isRefresh) {
      emit(NotificationListLoading());
    }
    await _fetchAndEmitNotifications(
        event.userId, event.pageNumber, event.pageSize, emit,
        isRefresh: event.isRefresh);
  }

  Future<void> _onFetchMoreUserNotifications(
      FetchMoreUserNotifications event, Emitter<NotificationState> emit) async {
    if (state is NotificationListLoadSuccess &&
        !(state as NotificationListLoadSuccess).hasReachedMax) {
      final currentState = state as NotificationListLoadSuccess;
      emit(NotificationListLoadingNextPage(
        notifications: currentState.notifications,
        hasReachedMax: currentState.hasReachedMax,
        currentPage: currentState.currentPage,
        pageSize: currentState.pageSize,
      ));
      await _fetchAndEmitNotifications(event.userId,
          currentState.currentPage + 1, currentState.pageSize, emit,
          isLoadMore: true, currentNotifications: currentState.notifications);
    }
  }

  Future<void> _fetchAndEmitNotifications(
    String userId,
    int pageNumber,
    int pageSize,
    Emitter<NotificationState> emit, {
    bool isLoadMore = false,
    List<NotificationModel> currentNotifications = const [],
    bool isRefresh = false,
  }) async {
    final Either<Failure, ApiResponse<PaginatedNotifications>> result =
        await _notificationRepository.getUserNotifications(
      userId: userId,
      pageNumber: pageNumber,
      pageSize: pageSize,
    );

    result.fold(
      (failure) {
        if (isLoadMore && state is NotificationListLoadSuccess) {
          final s = state as NotificationListLoadSuccess;
          emit(NotificationListNextPageError(
            failure: failure,
            notifications: s.notifications,
            hasReachedMax: s.hasReachedMax,
            currentPage: s.currentPage,
            pageSize: s.pageSize,
          ));
        } else {
          emit(NotificationListLoadFailure(failure: failure));
        }
      },
      (apiResponse) {
        if (apiResponse.success && apiResponse.data != null) {
          final pageData = apiResponse.data!;
          final bool hasReachedMax = pageData.pagination.pageNumber >=
                  pageData.pagination.totalPages ||
              pageData.content.isEmpty;

          final List<NotificationModel> combinedList =
              (isLoadMore && !isRefresh)
                  ? (currentNotifications + pageData.content)
                  : pageData.content;

          emit(NotificationListLoadSuccess(
            notifications: combinedList,
            hasReachedMax: hasReachedMax,
            currentPage: pageData.pagination.pageNumber,
            pageSize: pageData.pagination.pageSize,
          ));
        } else {
          final failure = ServerFailure(message: apiResponse.message);
          if (isLoadMore && state is NotificationListLoadSuccess) {
            final s = state as NotificationListLoadSuccess;
            emit(NotificationListNextPageError(
              failure: failure,
              notifications: s.notifications,
              hasReachedMax: s.hasReachedMax,
              currentPage: s.currentPage,
              pageSize: s.pageSize,
            ));
          } else {
            emit(NotificationListLoadFailure(failure: failure));
          }
        }
      },
    );
  }

  Future<void> _onUpdateNotificationStatusRequested(
      UpdateNotificationStatusRequested event,
      Emitter<NotificationState> emit) async {
    emit(NotificationLoading());
    final result =
        await _notificationRepository.updateNotificationStatus(event.request);
    result.fold(
      (failure) => emit(NotificationUpdateFailure(failure: failure)),
      (apiResponse) {
        if (apiResponse.success && apiResponse.data != null) {
          emit(NotificationUpdateSuccess(
              updatedNotification: apiResponse.data!));
        } else {
          emit(NotificationUpdateFailure(
              failure: ServerFailure(message: apiResponse.message)));
        }
      },
    );
  }

  Future<void> _onMarkAllNotificationsAsReadRequested(
      MarkAllNotificationsAsReadRequested event,
      Emitter<NotificationState> emit) async {
    emit(NotificationLoading());
    final result =
        await _notificationRepository.markAllNotificationsAsRead(event.userId);
    result.fold(
      (failure) => emit(NotificationMarkAllReadFailure(failure: failure)),
      (apiResponse) {
        if (apiResponse.success) {
          emit(NotificationMarkAllReadSuccess(
              message: apiResponse.data ?? apiResponse.message));
        } else {
          emit(NotificationMarkAllReadFailure(
              failure: ServerFailure(message: apiResponse.message)));
        }
      },
    );
  }

  Future<void> _onDeleteNotificationRequested(DeleteNotificationRequested event,
      Emitter<NotificationState> emit) async {
    emit(NotificationLoading());
    final result =
        await _notificationRepository.deleteNotification(event.notificationId);
    result.fold(
      (failure) => emit(NotificationDeleteFailure(failure: failure)),
      (apiResponse) {
        if (apiResponse.success) {
          emit(NotificationDeleteSuccess(
            message: apiResponse.data ?? apiResponse.message,
            deletedNotificationId: event.notificationId,
          ));
        } else {
          emit(NotificationDeleteFailure(
              failure: ServerFailure(message: apiResponse.message)));
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
      (failure) => emit(NotificationUnreadCountLoadFailure(failure: failure)),
      (apiResponse) {
        if (apiResponse.success && apiResponse.data != null) {
          emit(NotificationUnreadCountLoadSuccess(count: apiResponse.data!));
        } else {
          emit(NotificationUnreadCountLoadFailure(
              failure: ServerFailure(message: apiResponse.message)));
        }
      },
    );
  }
}
