import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:langas_user/bloc/deliveries/create_delivery_bloc/create_delivery_bloc_event.dart';
import 'package:langas_user/bloc/deliveries/create_delivery_bloc/create_delivery_bloc_state.dart';
import 'package:langas_user/repository/delivery_repository.dart';

class CreateDeliveryBloc
    extends Bloc<CreateDeliveryEvent, CreateDeliveryState> {
  final DeliveryRepository _deliveryRepository;

  CreateDeliveryBloc({required DeliveryRepository deliveryRepository})
      : _deliveryRepository = deliveryRepository,
        super(CreateDeliveryInitial()) {
    on<SubmitDelivery>(_onSubmitDelivery);
  }

  Future<void> _onSubmitDelivery(
      SubmitDelivery event, Emitter<CreateDeliveryState> emit) async {
    emit(CreateDeliveryLoading());
    final result = await _deliveryRepository.createDelivery(
        clientId: event.clientId, requestDto: event.requestDto);
    result.fold(
      (failure) => emit(CreateDeliveryFailure(failure: failure)),
      (delivery) => emit(CreateDeliverySuccess(delivery: delivery)),
    );
  }
}
