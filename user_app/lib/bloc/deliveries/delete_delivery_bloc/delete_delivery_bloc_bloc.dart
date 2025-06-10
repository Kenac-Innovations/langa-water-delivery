import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:langas_user/bloc/deliveries/delete_delivery_bloc/delete_delivery_bloc_event.dart';
import 'package:langas_user/bloc/deliveries/delete_delivery_bloc/delete_delivery_bloc_state.dart';
import 'package:langas_user/repository/delivery_repository.dart';

class DeleteDeliveryBloc
    extends Bloc<DeleteDeliveryEvent, DeleteDeliveryState> {
  final DeliveryRepository _deliveryRepository;

  DeleteDeliveryBloc({required DeliveryRepository deliveryRepository})
      : _deliveryRepository = deliveryRepository,
        super(DeleteDeliveryInitial()) {
    on<DeleteDeliveryRequested>(_onDeleteDeliveryRequested);
  }

  Future<void> _onDeleteDeliveryRequested(
      DeleteDeliveryRequested event, Emitter<DeleteDeliveryState> emit) async {
    emit(DeleteDeliveryLoading());
    final result = await _deliveryRepository.deleteDeliveryById(
        clientId: event.clientId, deliveryId: event.deliveryId);
    result.fold(
      (failure) => emit(DeleteDeliveryFailure(failure: failure)),
      (message) => emit(DeleteDeliverySuccess(message: message)),
    );
  }
}
