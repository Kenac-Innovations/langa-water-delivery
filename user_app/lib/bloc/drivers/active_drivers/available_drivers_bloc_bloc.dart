import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:langas_user/bloc/drivers/active_drivers/available_drivers_bloc_event.dart';
import 'package:langas_user/bloc/drivers/active_drivers/available_drivers_bloc_state.dart';
import 'package:langas_user/models/driver_model.dart';
import 'package:langas_user/repository/driver_repository.dart';
import 'package:langas_user/services/firebase_driver_service.dart';
import 'package:langas_user/util/api_failure_models.dart';

class AvailableDriversBloc
    extends Bloc<AvailableDriversEvent, AvailableDriversState> {
  final FirebaseDriverService _firebaseDriverService;
  StreamSubscription<List<Driver>>? _driversSubscription;

  AvailableDriversBloc({required FirebaseDriverService firebaseDriverService})
      : _firebaseDriverService = firebaseDriverService,
        super(AvailableDriversInitial()) {
    on<FetchAvailableDrivers>(_onFetchAvailableDrivers);
    on<DriversUpdated>(_onDriversUpdated);
    on<DriversError>(_onDriversError);
  }

  Future<void> _onFetchAvailableDrivers(
    FetchAvailableDrivers event,
    Emitter<AvailableDriversState> emit,
  ) async {
    emit(AvailableDriversLoading());

    try {
      // Cancel previous listener if it exists
      await _driversSubscription?.cancel();

      // Start Firebase listening for the given deliveryId
      debugPrint('=========> This is delivery Id  ${event.deliveryId}');
      _firebaseDriverService
          .startListeningForProposals(int.parse(event.deliveryId));

      _driversSubscription = _firebaseDriverService.driversStream.listen(
        (drivers) {
          // Log the drivers data received from the stream
          debugPrint('=========> Received drivers update: $drivers');

          // Dispatch the update event
          add(DriversUpdated(drivers));
        },
        onError: (error) {
          debugPrint('=========> Error from driversStream: $error');
          add(DriversError(_mapFirebaseErrorToFailure(error)));
        },
      );
    } catch (e) {
      debugPrint(
          '=========> This is the error on loading Proposed Deliveries: ${e.toString()}');
      emit(AvailableDriversFailure(
        failure: UnknownFailure(
            message: "An unexpected error occurred: ${e.toString()}"),
      ));
    }
  }

  void _onDriversUpdated(
    DriversUpdated event,
    Emitter<AvailableDriversState> emit,
  ) {
    if (event.drivers.isEmpty) {
      emit(AvailableDriversLoading());
    } else {
      emit(AvailableDriversSuccess(drivers: event.drivers));
    }
  }

  void _onDriversError(
    DriversError event,
    Emitter<AvailableDriversState> emit,
  ) {
    emit(AvailableDriversFailure(failure: event.failure));
  }

  @override
  Future<void> close() {
    _driversSubscription?.cancel();
    _firebaseDriverService.dispose();
    return super.close();
  }

  Failure _mapFirebaseErrorToFailure(dynamic error) {
    final message = error.toString();

    if (message.contains('SocketException')) {
      return const ConnectionFailure(message: 'No internet connection');
    } else if (message.contains('permission-denied')) {
      return const AuthFailure(message: 'Permission denied by Firebase');
    } else if (message.contains('databaseError')) {
      return ServerFailure(message: message, statusCode: 500);
    } else {
      return UnknownFailure(message: message);
    }
  }
}
