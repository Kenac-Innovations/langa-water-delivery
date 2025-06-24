import 'package:equatable/equatable.dart';
import 'package:langas_user/models/water_order_model.dart';
import 'package:langas_user/util/api_failure_models.dart';
import 'package:langas_user/util/api_pagenated_model.dart';

abstract class WaterOrderState extends Equatable {
  const WaterOrderState();

  @override
  List<Object> get props => [];
}

class WaterOrderInitial extends WaterOrderState {}

class WaterOrderLoading extends WaterOrderState {}

class WaterOrderCreationSuccess extends WaterOrderState {
  final WaterOrder waterOrder;

  const WaterOrderCreationSuccess(this.waterOrder);

  @override
  List<Object> get props => [waterOrder];
}

class WaterOrderLoadSuccess extends WaterOrderState {
  final WaterOrder waterOrder;

  const WaterOrderLoadSuccess(this.waterOrder);

  @override
  List<Object> get props => [waterOrder];
}

class WaterDeliveryLoadSuccess extends WaterOrderState {
  final WaterDelivery waterDelivery;

  const WaterDeliveryLoadSuccess(this.waterDelivery);

  @override
  List<Object> get props => [waterDelivery];
}

class WaterOrderListLoadSuccess extends WaterOrderState {
  final PaginatedResponse<WaterOrder> paginatedResponse;

  const WaterOrderListLoadSuccess(this.paginatedResponse);

  @override
  List<Object> get props => [paginatedResponse];
}

class WaterDeliveryListLoadSuccess extends WaterOrderState {
  final PaginatedResponse<WaterDelivery> paginatedResponse;

  const WaterDeliveryListLoadSuccess(this.paginatedResponse);

  @override
  List<Object> get props => [paginatedResponse];
}

class WaterOrderFailure extends WaterOrderState {
  final Failure failure;

  const WaterOrderFailure(this.failure);

  @override
  List<Object> get props => [failure];
}
