import 'package:bloc/bloc.dart';
import 'package:langas_driver/bloc/delivery/confirm_delivery_bloc/confirm_delivery_bloc_event.dart';
import 'package:langas_driver/bloc/delivery/confirm_delivery_bloc/confirm_delivery_bloc_state.dart';
import 'package:langas_driver/repository/delivery_repository.dart';
import 'package:langas_driver/utils/failure_models.dart';

class ConfirmDeliveryBloc
    extends Bloc<ConfirmDeliveryEvent, ConfirmDeliveryState> {
  final DeliveryRepository _deliveryRepository;

  ConfirmDeliveryBloc({required DeliveryRepository deliveryRepository})
      : _deliveryRepository = deliveryRepository,
        super(ConfirmDeliveryInitial()) {
    on<ConfirmDeliveryRequested>(_onConfirmDeliveryRequested);
  }

  Future<void> _onConfirmDeliveryRequested(
    ConfirmDeliveryRequested event,
    Emitter<ConfirmDeliveryState> emit,
  ) async {
    emit(ConfirmDeliveryInProgress());
    final result = await _deliveryRepository.selectDelivery(
      event.clientId,
      event.request,
    );

    result.fold(
      (failure) => emit(ConfirmDeliveryFailure(failure: failure)),
      (apiResponse) {
        if (apiResponse.success) {
          emit(ConfirmDeliverySuccess(
              message: apiResponse.data ?? apiResponse.message));
        } else {
          emit(ConfirmDeliveryFailure(
              failure: ServerFailure(message: apiResponse.message)));
        }
      },
    );
  }
}
