import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:langas_driver/utils/failure_models.dart';

@immutable
abstract class ConfirmDeliveryState extends Equatable {
  const ConfirmDeliveryState();
  @override
  List<Object> get props => [];
}

class ConfirmDeliveryInitial extends ConfirmDeliveryState {}

class ConfirmDeliveryInProgress extends ConfirmDeliveryState {}

class ConfirmDeliverySuccess extends ConfirmDeliveryState {
  final String message;
  const ConfirmDeliverySuccess({required this.message});
  @override
  List<Object> get props => [message];
}

class ConfirmDeliveryFailure extends ConfirmDeliveryState {
  final Failure failure;
  const ConfirmDeliveryFailure({required this.failure});
  @override
  List<Object> get props => [failure];
}
