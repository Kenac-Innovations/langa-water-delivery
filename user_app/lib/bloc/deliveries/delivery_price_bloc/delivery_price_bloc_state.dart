import 'package:equatable/equatable.dart';
import 'package:langas_user/util/api_failure_models.dart';

abstract class DeliveryPriceState extends Equatable {
  const DeliveryPriceState();
  @override
  List<Object> get props => [];
}

class DeliveryPriceInitial extends DeliveryPriceState {}

class DeliveryPriceLoading extends DeliveryPriceState {}

class DeliveryPriceSuccess extends DeliveryPriceState {
  final num price;
  const DeliveryPriceSuccess({required this.price});
  @override
  List<Object> get props => [price];
}

class DeliveryPriceFailure extends DeliveryPriceState {
  final Failure failure;
  const DeliveryPriceFailure({required this.failure});
  @override
  List<Object> get props => [failure];
}
