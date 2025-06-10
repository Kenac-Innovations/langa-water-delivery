import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:langas_user/bloc/deliveries/single_delivery_bloc/single_delivery_bloc_event.dart';
import 'package:langas_user/bloc/deliveries/single_delivery_bloc/single_delivery_bloc_state.dart';
import 'package:langas_user/repository/delivery_repository.dart';

class SingleDeliveryBloc
    extends Bloc<SingleDeliveryEvent, SingleDeliveryState> {
  final DeliveryRepository _deliveryRepository;

  SingleDeliveryBloc({required DeliveryRepository deliveryRepository})
      : _deliveryRepository = deliveryRepository,
        super(SingleDeliveryInitial()) {
    on<FetchSingleDeliveryRequested>(_onFetchSingleDeliveryRequested);
  }

  Future<void> _onFetchSingleDeliveryRequested(
      FetchSingleDeliveryRequested event,
      Emitter<SingleDeliveryState> emit) async {
    emit(SingleDeliveryLoading());
    final result = await _deliveryRepository.getDeliveryById(
        clientId: event.clientId, deliveryId: event.deliveryId);
    result.fold(
      (failure) => emit(SingleDeliveryFailure(failure: failure)),
      (delivery) => emit(SingleDeliverySuccess(delivery: delivery)),
    );
  }
}
