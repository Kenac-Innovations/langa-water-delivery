import 'package:equatable/equatable.dart';
import 'package:langas_user/models/delivery_model.dart';
import 'package:langas_user/util/api_failure_models.dart';

abstract class SingleDeliveryState extends Equatable {
  const SingleDeliveryState();
  @override
  List<Object> get props => [];
}

class SingleDeliveryInitial extends SingleDeliveryState {}

class SingleDeliveryLoading extends SingleDeliveryState {}

class SingleDeliverySuccess extends SingleDeliveryState {
  final Delivery delivery;
  const SingleDeliverySuccess({required this.delivery});
  @override
  List<Object> get props => [delivery];
}

class SingleDeliveryFailure extends SingleDeliveryState {
  final Failure failure;
  const SingleDeliveryFailure({required this.failure});
  @override
  List<Object> get props => [failure];
}
