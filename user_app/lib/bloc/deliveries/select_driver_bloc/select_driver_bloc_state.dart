import 'package:equatable/equatable.dart';
import 'package:langas_user/util/api_failure_models.dart';

abstract class SelectDriverState extends Equatable {
  const SelectDriverState();
  @override
  List<Object> get props => [];
}

class SelectDriverInitial extends SelectDriverState {}

class SelectDriverLoading extends SelectDriverState {}

class SelectDriverSuccess extends SelectDriverState {
  final String message;
  const SelectDriverSuccess({required this.message});
  @override
  List<Object> get props => [message];
}

class SelectDriverFailure extends SelectDriverState {
  final Failure failure;
  const SelectDriverFailure({required this.failure});
  @override
  List<Object> get props => [failure];
}
