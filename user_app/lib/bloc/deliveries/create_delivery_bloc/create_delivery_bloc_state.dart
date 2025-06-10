import 'package:equatable/equatable.dart';
import 'package:langas_user/models/delivery_model.dart';
import 'package:langas_user/util/api_failure_models.dart';

abstract class CreateDeliveryState extends Equatable {
  const CreateDeliveryState();
  @override
  List<Object> get props => [];
}

class CreateDeliveryInitial extends CreateDeliveryState {}

class CreateDeliveryLoading extends CreateDeliveryState {}

class CreateDeliverySuccess extends CreateDeliveryState {
  final Delivery delivery;
  const CreateDeliverySuccess({required this.delivery});
  @override
  List<Object> get props => [delivery];
}

class CreateDeliveryFailure extends CreateDeliveryState {
  final Failure failure;
  const CreateDeliveryFailure({required this.failure});
  @override
  List<Object> get props => [failure];
}
