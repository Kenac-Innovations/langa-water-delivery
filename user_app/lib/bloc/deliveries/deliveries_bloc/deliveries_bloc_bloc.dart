import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:langas_user/bloc/deliveries/deliveries_bloc/deliveries_bloc_event.dart';
import 'package:langas_user/bloc/deliveries/deliveries_bloc/deliveries_bloc_state.dart';
import 'package:langas_user/repository/delivery_repository.dart';
import 'package:langas_user/util/apps_enums.dart';

class DeliveriesBloc extends Bloc<DeliveriesEvent, DeliveriesState> {
  final DeliveryRepository _deliveryRepository;

  DeliveriesBloc({required DeliveryRepository deliveryRepository})
      : _deliveryRepository = deliveryRepository,
        super(DeliveriesInitial()) {
    on<FetchDeliveriesRequested>(_onFetchDeliveriesRequested);
  }

  Future<void> _onFetchDeliveriesRequested(
      FetchDeliveriesRequested event, Emitter<DeliveriesState> emit) async {
    emit(DeliveriesLoading());
    final result = event.isHistory
        ? await _deliveryRepository.getDeliveryHistory(
            clientId: event.clientId,
            pageNumber: event.pageNumber,
            pageSize: event.pageSize,
            status: event.status ?? DeliveryStatus.UNKNOWN,
          )
        : await _deliveryRepository.getCurrentDeliveries(
            clientId: event.clientId,
            pageNumber: event.pageNumber,
            pageSize: event.pageSize,
            statuses: event.status != null ? [event.status!] : null,
          );
    result.fold(
      (failure) => emit(DeliveriesFailure(failure: failure)),
      (paginatedResponse) =>
          emit(DeliveriesSuccess(response: paginatedResponse)),
    );
  }
}
