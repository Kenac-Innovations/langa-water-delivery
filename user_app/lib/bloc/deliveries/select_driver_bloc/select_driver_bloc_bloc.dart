import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:langas_user/bloc/deliveries/select_driver_bloc/select_driver_bloc_event.dart';
import 'package:langas_user/bloc/deliveries/select_driver_bloc/select_driver_bloc_state.dart';
import 'package:langas_user/repository/delivery_repository.dart';

class SelectDriverBloc extends Bloc<SelectDriverEvent, SelectDriverState> {
  final DeliveryRepository _deliveryRepository;

  SelectDriverBloc({required DeliveryRepository deliveryRepository})
      : _deliveryRepository = deliveryRepository,
        super(SelectDriverInitial()) {
    on<SelectDriverSubmitted>(_onSelectDriverSubmitted);
  }

  Future<void> _onSelectDriverSubmitted(
      SelectDriverSubmitted event, Emitter<SelectDriverState> emit) async {
    emit(SelectDriverLoading());
    final result = await _deliveryRepository.selectDriverForDelivery(
        clientId: event.clientId, requestDto: event.requestDto);
    result.fold(
      (failure) => emit(SelectDriverFailure(failure: failure)),
      (message) => emit(SelectDriverSuccess(message: message)),
    );
  }
}
