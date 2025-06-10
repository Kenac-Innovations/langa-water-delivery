import 'package:equatable/equatable.dart';
import 'package:langas_user/util/api_failure_models.dart';

abstract class CancelDeliveryState extends Equatable {
  const CancelDeliveryState();
  @override
  List<Object> get props => [];
}

class CancelDeliveryInitial extends CancelDeliveryState {}

class CancelDeliveryLoading extends CancelDeliveryState {}

class CancelDeliverySuccess extends CancelDeliveryState {
  final String message;
  const CancelDeliverySuccess({required this.message});
  @override
  List<Object> get props => [message];
}

class CancelDeliveryFailure extends CancelDeliveryState {
  final Failure failure;
  const CancelDeliveryFailure({required this.failure});
  @override
  List<Object> get props => [failure];
}
