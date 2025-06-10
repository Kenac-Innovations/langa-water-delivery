import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:langas_user/bloc/deliveries/cancel_delivery_bloc/cancel_delivery_bloc_event.dart';
import 'package:langas_user/bloc/deliveries/cancel_delivery_bloc/cancel_delivery_bloc_state.dart';
import 'package:langas_user/repository/delivery_repository.dart';

class CancelDeliveryBloc
    extends Bloc<CancelDeliveryEvent, CancelDeliveryState> {
  final DeliveryRepository _deliveryRepository;

  CancelDeliveryBloc({required DeliveryRepository deliveryRepository})
      : _deliveryRepository = deliveryRepository,
        super(CancelDeliveryInitial()) {
    on<CancelDeliverySubmitted>(_onCancelDeliverySubmitted);
  }

  Future<void> _onCancelDeliverySubmitted(
      CancelDeliverySubmitted event, Emitter<CancelDeliveryState> emit) async {
    emit(CancelDeliveryLoading());
    final result = await _deliveryRepository.cancelDelivery(
        clientId: event.clientId, requestDto: event.requestDto);
    result.fold(
      (failure) => emit(CancelDeliveryFailure(failure: failure)),
      (message) => emit(CancelDeliverySuccess(message: message)),
    );
  }
}
