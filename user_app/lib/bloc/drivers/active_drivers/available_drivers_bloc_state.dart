import 'package:equatable/equatable.dart';
import 'package:langas_user/models/driver_model.dart';
import 'package:langas_user/util/api_failure_models.dart';

import 'package:equatable/equatable.dart';
import 'package:langas_user/models/driver_model.dart';
import 'package:langas_user/util/api_failure_models.dart';

abstract class AvailableDriversState extends Equatable {
  const AvailableDriversState();
  @override
  List<Object> get props => [];
}

class AvailableDriversInitial extends AvailableDriversState {}

class AvailableDriversLoading extends AvailableDriversState {}

class AvailableDriversSuccess extends AvailableDriversState {
  final List<Driver> drivers; // Use your Driver model
  const AvailableDriversSuccess({required this.drivers});
  @override
  List<Object> get props => [drivers];
}

class AvailableDriversFailure extends AvailableDriversState {
  final Failure failure;
  const AvailableDriversFailure({required this.failure});
  @override
  List<Object> get props => [failure];
}
