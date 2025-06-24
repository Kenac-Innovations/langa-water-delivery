import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:langas_user/bloc/bloc/water_order_bloc_event.dart';
import 'package:langas_user/bloc/bloc/water_order_bloc_state.dart';
import 'package:langas_user/repository/water_order_repository.dart';

class WaterOrderBloc extends Bloc<WaterOrderEvent, WaterOrderState> {
  final WaterOrderRepository _waterOrderRepository;

  WaterOrderBloc({required WaterOrderRepository waterOrderRepository})
      : _waterOrderRepository = waterOrderRepository,
        super(WaterOrderInitial()) {
    on<CreateWaterOrder>(_onCreateWaterOrder);
    on<FetchWaterOrderById>(_onFetchWaterOrderById);
    on<FetchClientRecentDeliveries>(_onFetchClientRecentDeliveries);
    on<FetchWaterDeliveryById>(_onFetchWaterDeliveryById);
    on<FetchAllWaterDeliveriesByClientId>(_onFetchAllWaterDeliveriesByClientId);
  }

  Future<void> _onCreateWaterOrder(
      CreateWaterOrder event, Emitter<WaterOrderState> emit) async {
    emit(WaterOrderLoading());
    final result = await _waterOrderRepository.createWaterOrder(event.dto);
    result.fold(
      (failure) => emit(WaterOrderFailure(failure)),
      (waterOrder) => emit(WaterOrderCreationSuccess(waterOrder)),
    );
  }

  Future<void> _onFetchWaterOrderById(
      FetchWaterOrderById event, Emitter<WaterOrderState> emit) async {
    emit(WaterOrderLoading());
    final result = await _waterOrderRepository.getWaterOrderById(event.orderId);
    result.fold(
      (failure) => emit(WaterOrderFailure(failure)),
      (waterOrder) => emit(WaterOrderLoadSuccess(waterOrder)),
    );
  }

  Future<void> _onFetchClientRecentDeliveries(
      FetchClientRecentDeliveries event, Emitter<WaterOrderState> emit) async {
    emit(WaterOrderLoading());
    final result = await _waterOrderRepository.getClientRecentDeliveries(
      event.clientId,
      event.pageNumber,
      event.pageSize,
      event.status,
    );
    result.fold(
      (failure) => emit(WaterOrderFailure(failure)),
      (paginatedResponse) => emit(WaterOrderListLoadSuccess(paginatedResponse)),
    );
  }

  Future<void> _onFetchWaterDeliveryById(
      FetchWaterDeliveryById event, Emitter<WaterOrderState> emit) async {
    emit(WaterOrderLoading());
    final result =
        await _waterOrderRepository.getWaterDeliveryById(event.deliveryId);
    result.fold(
      (failure) => emit(WaterOrderFailure(failure)),
      (waterDelivery) => emit(WaterDeliveryLoadSuccess(waterDelivery)),
    );
  }

  Future<void> _onFetchAllWaterDeliveriesByClientId(
      FetchAllWaterDeliveriesByClientId event,
      Emitter<WaterOrderState> emit) async {
    emit(WaterOrderLoading());
    final result = await _waterOrderRepository
        .getAllWaterDeliveriesByClientId(event.clientId);
    result.fold(
      (failure) => emit(WaterOrderFailure(failure)),
      (paginatedResponse) =>
          emit(WaterDeliveryListLoadSuccess(paginatedResponse)),
    );
  }
}
