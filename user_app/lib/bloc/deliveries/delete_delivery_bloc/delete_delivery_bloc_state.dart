import 'package:equatable/equatable.dart';
import 'package:langas_user/util/api_failure_models.dart';

abstract class DeleteDeliveryState extends Equatable {
  const DeleteDeliveryState();
  @override
  List<Object> get props => [];
}

class DeleteDeliveryInitial extends DeleteDeliveryState {}

class DeleteDeliveryLoading extends DeleteDeliveryState {}

class DeleteDeliverySuccess extends DeleteDeliveryState {
  final String message;
  const DeleteDeliverySuccess({required this.message});
  @override
  List<Object> get props => [message];
}

class DeleteDeliveryFailure extends DeleteDeliveryState {
  final Failure failure;
  const DeleteDeliveryFailure({required this.failure});
  @override
  List<Object> get props => [failure];
}
