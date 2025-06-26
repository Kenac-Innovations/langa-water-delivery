import 'dart:async';
import 'package:dartz/dartz.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:langas_driver/bloc/delivery/current_deliveries_bloc/current_deliveries_bloc_event.dart';
import 'package:langas_driver/bloc/delivery/current_deliveries_bloc/current_deliveries_bloc_state.dart';
import 'package:langas_driver/models/delivery_models.dart';
import 'package:langas_driver/repository/delivery_repository.dart';
import 'package:langas_driver/services/location_tracking.dart';
import 'package:langas_driver/utils/api_response_model.dart';
import 'package:langas_driver/utils/failure_models.dart';

class CurrentDeliveriesBloc
    extends Bloc<CurrentDeliveriesEvent, CurrentDeliveriesState> {
  final DeliveryRepository _deliveryRepository;
  final LocationTrackingManager _locationTrackingManager;

  CurrentDeliveriesBloc({
    required DeliveryRepository deliveryRepository,
    required LocationTrackingManager locationTrackingManager,
  })  : _deliveryRepository = deliveryRepository,
        _locationTrackingManager = locationTrackingManager,
        super(CurrentDeliveriesInitial()) {
    on<LoadCurrentDeliveries>(_onLoadCurrentDeliveries);
    on<LoadMoreCurrentDeliveries>(_onLoadMoreCurrentDeliveries);
    on<AcceptDeliveryRequested>(_onAcceptDelivery);
    on<PickupDeliveryRequested>(_onPickupDelivery);
    on<CompleteDeliveryRequested>(_onCompleteDelivery);
    on<CancelDeliveryRequested>(_onCancelDelivery);
    on<TriggerStartLocationTracking>(_onTriggerStartLocationTracking);
    on<TriggerStopLocationTracking>(_onTriggerStopLocationTracking);
  }

  Future<void> _onLoadCurrentDeliveries(
      LoadCurrentDeliveries event, Emitter<CurrentDeliveriesState> emit) async {
    if (event.pageNumber == 1 || event.isRefresh) {
      emit(CurrentDeliveriesLoading());
    }
    await _fetchAndEmitCurrentDeliveries(
        event.driverId, event.pageNumber, event.pageSize, emit,
        isRefresh: event.isRefresh);
  }

  Future<void> _onLoadMoreCurrentDeliveries(LoadMoreCurrentDeliveries event,
      Emitter<CurrentDeliveriesState> emit) async {
    if (state is CurrentDeliveriesLoadSuccess &&
        !(state as CurrentDeliveriesLoadSuccess).hasReachedMax) {
      final currentState = state as CurrentDeliveriesLoadSuccess;
      emit(CurrentDeliveriesLoadingNextPage(
        deliveries: currentState.deliveries,
        hasReachedMax: currentState.hasReachedMax,
        currentPage: currentState.currentPage,
        pageSize: currentState.pageSize,
      ));
      await _fetchAndEmitCurrentDeliveries(event.driverId,
          currentState.currentPage + 1, currentState.pageSize, emit,
          isLoadMore: true, currentDeliveries: currentState.deliveries);
    }
  }

  Future<void> _fetchAndEmitCurrentDeliveries(String driverId, int pageNumber,
      int pageSize, Emitter<CurrentDeliveriesState> emit,
      {bool isLoadMore = false,
      List<Delivery> currentDeliveries = const [],
      bool isRefresh = false}) async {
    final Either<Failure, ApiResponse<PaginatedDeliveryResponse>> result =
        await _deliveryRepository.getCurrentDriverDeliveries(
      driverId: driverId,
      pageNumber: pageNumber,
      pageSize: pageSize,
    );

    result.fold(
      (failure) {
        if (isLoadMore && state is CurrentDeliveriesLoadSuccess) {
          final s = state as CurrentDeliveriesLoadSuccess;
          emit(CurrentDeliveriesNextPageError(
            failure: failure,
            deliveries: s.deliveries,
            hasReachedMax: s.hasReachedMax,
            currentPage: s.currentPage,
            pageSize: s.pageSize,
          ));
        } else {
          emit(CurrentDeliveriesLoadFailure(failure: failure));
        }
      },
      (apiResponse) {
        if (apiResponse.success && apiResponse.data != null) {
          final pageData = apiResponse.data!;
          final bool hasReachedMax = pageData.pagination.pageNumber >=
                  pageData.pagination.totalPages ||
              pageData.content.isEmpty;

          final List<Delivery> combinedList = (isLoadMore && !isRefresh)
              ? (currentDeliveries + pageData.content)
              : pageData.content;

          emit(CurrentDeliveriesLoadSuccess(
            deliveries: combinedList,
            hasReachedMax: hasReachedMax,
            currentPage: pageData.pagination.pageNumber,
            pageSize: pageData.pagination.pageSize,
          ));
        } else {
          final failure = ServerFailure(message: apiResponse.message);
          if (isLoadMore && state is CurrentDeliveriesLoadSuccess) {
            final s = state as CurrentDeliveriesLoadSuccess;
            emit(CurrentDeliveriesNextPageError(
              failure: failure,
              deliveries: s.deliveries,
              hasReachedMax: s.hasReachedMax,
              currentPage: s.currentPage,
              pageSize: s.pageSize,
            ));
          } else {
            emit(CurrentDeliveriesLoadFailure(failure: failure));
          }
        }
      },
    );
  }

  Future<void> _onAcceptDelivery(AcceptDeliveryRequested event,
      Emitter<CurrentDeliveriesState> emit) async {
    emit(DeliveryActionLoading(deliveryId: event.deliveryId));
    final result = await _deliveryRepository.acceptDelivery(
        event.deliveryId, event.request);
    _handleActionResult(
        result: result,
        deliveryId: event.deliveryId,
        driverIdForReload: event.request.driverId.toString(),
        emit: emit);
  }

  Future<void> _onPickupDelivery(PickupDeliveryRequested event,
      Emitter<CurrentDeliveriesState> emit) async {
    emit(DeliveryActionLoading(deliveryId: event.deliveryId));
    final result = await _deliveryRepository.pickupDelivery(
        event.deliveryId, event.request);
    _handleActionResult(
        result: result,
        deliveryId: event.deliveryId,
        driverIdForReload: event.driverId,
        emit: emit,
        onSuccessAction: () => add(TriggerStartLocationTracking(
            driverId: event.driverId, deliveryId: event.deliveryId)));
  }

  Future<void> _onCompleteDelivery(CompleteDeliveryRequested event,
      Emitter<CurrentDeliveriesState> emit) async {
    emit(DeliveryActionLoading(deliveryId: event.deliveryId));
    final result = await _deliveryRepository.completeDelivery(
        event.deliveryId, event.request);
    _handleActionResult(
        result: result,
        deliveryId: event.deliveryId,
        driverIdForReload: event.driverId,
        emit: emit,
        onStopTrackingAction: () =>
            add(TriggerStopLocationTracking(deliveryId: event.deliveryId)));
  }

  Future<void> _onCancelDelivery(CancelDeliveryRequested event,
      Emitter<CurrentDeliveriesState> emit) async {
    emit(DeliveryActionLoading(deliveryId: event.deliveryId));
    final result = await _deliveryRepository.cancelDelivery(
        event.deliveryId, event.request);
    _handleActionResult(
        result: result,
        deliveryId: event.deliveryId,
        driverIdForReload: event.driverId,
        emit: emit,
        onStopTrackingAction: () =>
            add(TriggerStopLocationTracking(deliveryId: event.deliveryId)));
  }

  void _handleActionResult({
    required Either<Failure, ApiResponse<String>> result,
    required String deliveryId,
    required String? driverIdForReload,
    required Emitter<CurrentDeliveriesState> emit,
    Function? onSuccessAction, // For pickup
    Function? onStopTrackingAction, // For complete/cancel
  }) {
    result.fold(
      (failure) =>
          emit(DeliveryActionFailure(deliveryId: deliveryId, failure: failure)),
      (apiResponse) {
        if (apiResponse.success) {
          emit(DeliveryActionSuccess(
              deliveryId: deliveryId,
              message: apiResponse.data ?? apiResponse.message));

          onSuccessAction?.call();
          onStopTrackingAction?.call();

          if (driverIdForReload != null) {
            add(LoadCurrentDeliveries(
                driverId: driverIdForReload, isRefresh: true));
          }
        } else {
          emit(DeliveryActionFailure(
              deliveryId: deliveryId,
              failure: ServerFailure(message: apiResponse.message)));
        }
      },
    );
  }

  Future<void> _onTriggerStartLocationTracking(
      TriggerStartLocationTracking event,
      Emitter<CurrentDeliveriesState> emit) async {
    try {
      await _locationTrackingManager.startTrackingService(
          event.driverId, event.deliveryId);
      print(
          'CurrentDeliveriesBloc: Location tracking started for delivery ${event.deliveryId}');
    } catch (e) {
      print('CurrentDeliveriesBloc: Error starting location tracking: $e');
    }
  }

  Future<void> _onTriggerStopLocationTracking(TriggerStopLocationTracking event,
      Emitter<CurrentDeliveriesState> emit) async {
    try {
      await _locationTrackingManager.stopTrackingService();
      print(
          'CurrentDeliveriesBloc: Location tracking stopped for delivery ${event.deliveryId}');
    } catch (e) {
      print('CurrentDeliveriesBloc: Error stopping location tracking: $e');
    }
  }
}
