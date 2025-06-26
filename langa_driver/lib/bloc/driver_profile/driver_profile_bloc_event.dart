import 'dart:ffi';

import 'package:equatable/equatable.dart';

abstract class DriverProfileEvent extends Equatable {
  const DriverProfileEvent();

  @override
  List<Object?> get props => [];
}

class LoadDriverProfile extends DriverProfileEvent {
  final String driverId;

  const LoadDriverProfile({required this.driverId});

  @override
  List<Object?> get props => [driverId];
}

class UpdateWorkStatus extends DriverProfileEvent{
  final int driverId;
  final bool status;
  const UpdateWorkStatus({required this.driverId,required this.status});
  @override
  List<Object?> get props => [driverId];
}
class UpdateAvailabilityStatus extends DriverProfileEvent{
  final Long driverId;
  final Bool status;
  const UpdateAvailabilityStatus({required this.driverId,required this.status});
  @override
  List<Object?> get props => [driverId];
}
class UpdateSearchRadius extends DriverProfileEvent{
  final Long driverId;
  final double radius;
  const UpdateSearchRadius({required this.driverId,required this.radius});
  @override
  List<Object?> get props => [driverId];
}

class DeleteDriverProfile extends DriverProfileEvent {
  final String driverId;

  const DeleteDriverProfile({required this.driverId});

  @override
  List<Object?> get props => [driverId];
}
