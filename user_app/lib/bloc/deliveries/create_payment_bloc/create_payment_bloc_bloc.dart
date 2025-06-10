import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:langas_user/bloc/deliveries/create_payment_bloc/create_payment_bloc_event.dart';
import 'package:langas_user/bloc/deliveries/create_payment_bloc/create_payment_bloc_state.dart';
import 'package:langas_user/repository/delivery_repository.dart';

class CreatePaymentBloc extends Bloc<CreatePaymentEvent, CreatePaymentState> {
  final DeliveryRepository _deliveryRepository;

  CreatePaymentBloc({required DeliveryRepository deliveryRepository})
      : _deliveryRepository = deliveryRepository,
        super(CreatePaymentInitial()) {
    on<CreatePaymentSubmitted>(_onCreatePaymentSubmitted);
  }

  Future<void> _onCreatePaymentSubmitted(
      CreatePaymentSubmitted event, Emitter<CreatePaymentState> emit) async {
    emit(CreatePaymentLoading());
    final result = await _deliveryRepository.createDeliveryPayment(
        clientId: event.clientId, requestDto: event.requestDto);
    result.fold(
      (failure) => emit(CreatePaymentFailure(failure: failure)),
      (message) => emit(CreatePaymentSuccess(message: message)),
    );
  }
}
