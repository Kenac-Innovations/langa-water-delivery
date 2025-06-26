import 'dart:async';
import 'package:dartz/dartz.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:langas_driver/bloc/delivery/delivery_history_bloc/delivery_history_bloc_event.dart';
import 'package:langas_driver/bloc/delivery/delivery_history_bloc/delivery_history_bloc_state.dart';
import 'package:langas_driver/models/delivery_models.dart';
import 'package:langas_driver/repository/delivery_repository.dart';
import 'package:langas_driver/utils/api_response_model.dart';
import 'package:langas_driver/utils/delivery_enums.dart';
import 'package:langas_driver/utils/failure_models.dart';

class DeliveryHistoryBloc
    extends Bloc<DeliveryHistoryEvent, DeliveryHistoryState> {
  final DeliveryRepository _deliveryRepository;

  DeliveryHistoryBloc({required DeliveryRepository deliveryRepository})
      : _deliveryRepository = deliveryRepository,
        super(DeliveryHistoryInitial()) {
    on<LoadDeliveryHistory>(_onLoadDeliveryHistory);
    on<LoadMoreDeliveryHistory>(_onLoadMoreDeliveryHistory);
  }

  Future<void> _onLoadDeliveryHistory(
      LoadDeliveryHistory event, Emitter<DeliveryHistoryState> emit) async {
    if (event.pageNumber == 1 || event.isRefresh) {
      emit(DeliveryHistoryLoading());
    }
    await _fetchAndEmitHistory(
        event.driverId, event.pageNumber, event.pageSize, event.statuses, emit,
        isRefresh: event.isRefresh);
  }

  Future<void> _onLoadMoreDeliveryHistory(
      LoadMoreDeliveryHistory event, Emitter<DeliveryHistoryState> emit) async {
    if (state is DeliveryHistoryLoadSuccess &&
        !(state as DeliveryHistoryLoadSuccess).hasReachedMax) {
      final currentState = state as DeliveryHistoryLoadSuccess;
      emit(DeliveryHistoryLoadingNextPage(
        deliveries: currentState.deliveries,
        hasReachedMax: currentState.hasReachedMax,
        currentPage: currentState.currentPage,
        pageSize: currentState.pageSize,
        currentStatuses: currentState.currentStatuses,
      ));
      await _fetchAndEmitHistory(event.driverId, currentState.currentPage + 1,
          currentState.pageSize, event.statuses, emit,
          isLoadMore: true, currentDeliveries: currentState.deliveries);
    }
  }

  Future<void> _fetchAndEmitHistory(
      String driverId,
      int pageNumber,
      int pageSize,
      List<DeliveryStatus> filterStatuses,
      Emitter<DeliveryHistoryState> emit,
      {bool isLoadMore = false,
      List<Delivery> currentDeliveries = const [],
      bool isRefresh = false}) async {
    DeliveryStatus? statusToQuery;
    if (filterStatuses.isNotEmpty) {
      statusToQuery = filterStatuses.first;
    }

    final Either<Failure, ApiResponse<PaginatedDeliveryResponse>> result =
        await _deliveryRepository.getDriverDeliveriesHistory(
      driverId: driverId,
      pageNumber: pageNumber,
      pageSize: pageSize,
      status: statusToQuery,
    );

    result.fold(
      (failure) {
        if (isLoadMore && state is DeliveryHistoryLoadSuccess) {
          final s = state as DeliveryHistoryLoadSuccess;
          emit(DeliveryHistoryNextPageError(
            failure: failure,
            deliveries: s.deliveries,
            hasReachedMax: s.hasReachedMax,
            currentPage: s.currentPage,
            pageSize: s.pageSize,
            currentStatuses: s.currentStatuses,
          ));
        } else {
          emit(DeliveryHistoryLoadFailure(failure: failure));
        }
      },
      (apiResponse) {
        if (apiResponse.success && apiResponse.data != null) {
          final pageData = apiResponse.data!;
          final List<Delivery> fetchedContent = pageData.content;

          final List<Delivery> contentToUse;
          if (statusToQuery == null && filterStatuses.isNotEmpty) {
            contentToUse = fetchedContent
                .where((delivery) =>
                    filterStatuses.contains(delivery.deliveryStatus))
                .toList();
          } else {
            contentToUse = fetchedContent;
          }

          final bool hasReachedMax = pageData.pagination.pageNumber >=
                  pageData.pagination.totalPages ||
              contentToUse.isEmpty && pageData.content.isNotEmpty;

          final List<Delivery> combinedList = (isLoadMore && !isRefresh)
              ? (currentDeliveries + contentToUse)
              : contentToUse;

          emit(DeliveryHistoryLoadSuccess(
            deliveries: combinedList,
            hasReachedMax: hasReachedMax,
            currentPage: pageData.pagination.pageNumber,
            pageSize: pageData.pagination.pageSize,
            currentStatuses: filterStatuses,
          ));
        } else {
          final failure = ServerFailure(message: apiResponse.message);
          if (isLoadMore && state is DeliveryHistoryLoadSuccess) {
            final s = state as DeliveryHistoryLoadSuccess;
            emit(DeliveryHistoryNextPageError(
              failure: failure,
              deliveries: s.deliveries,
              hasReachedMax: s.hasReachedMax,
              currentPage: s.currentPage,
              pageSize: s.pageSize,
              currentStatuses: s.currentStatuses,
            ));
          } else {
            emit(DeliveryHistoryLoadFailure(failure: failure));
          }
        }
      },
    );
  }
}
