import 'package:equatable/equatable.dart';
import 'package:langas_user/models/driver_model.dart';
import 'package:langas_user/util/api_failure_models.dart';

abstract class AvailableDriversEvent extends Equatable {
  const AvailableDriversEvent();
  @override
  List<Object?> get props => [];
}

class FetchAvailableDrivers extends AvailableDriversEvent {
  final String deliveryId;

  const FetchAvailableDrivers({required this.deliveryId});

  @override
  List<Object?> get props => [deliveryId];
}

// This event is triggered by the Firebase listener when the list of drivers updates
class DriversUpdated extends AvailableDriversEvent {
  final List<Driver> drivers;

  const DriversUpdated(this.drivers);

  @override
  List<Object?> get props => [drivers];
}

// This event is triggered by the Firebase listener if an error occurs
class DriversError extends AvailableDriversEvent {
  final Failure failure;

  const DriversError(this.failure);

  @override
  List<Object> get props => [failure];
}
