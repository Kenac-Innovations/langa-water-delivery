import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:langas_user/bloc/deliveries/delivery_price_bloc/delivery_price_bloc_event.dart';
import 'package:langas_user/bloc/deliveries/delivery_price_bloc/delivery_price_bloc_state.dart';
import 'package:langas_user/repository/delivery_repository.dart';

class DeliveryPriceBloc extends Bloc<DeliveryPriceEvent, DeliveryPriceState> {
  final DeliveryRepository _deliveryRepository;

  DeliveryPriceBloc({required DeliveryRepository deliveryRepository})
      : _deliveryRepository = deliveryRepository,
        super(DeliveryPriceInitial()) {
    on<GetDeliveryPriceRequested>(_onGetDeliveryPriceRequested);
  }

  Future<void> _onGetDeliveryPriceRequested(
      GetDeliveryPriceRequested event, Emitter<DeliveryPriceState> emit) async {
    emit(DeliveryPriceLoading());
    final result = await _deliveryRepository.getDeliveryPrice(
        requestDto: event.requestDto);
    result.fold(
      (failure) => emit(DeliveryPriceFailure(failure: failure)),
      (price) => emit(DeliveryPriceSuccess(price: price)),
    );
  }
}
