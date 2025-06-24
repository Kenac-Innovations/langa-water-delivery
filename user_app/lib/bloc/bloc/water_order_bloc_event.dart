import 'package:equatable/equatable.dart';
import 'package:langas_user/dto/water_order_dto.dart';

abstract class WaterOrderEvent extends Equatable {
  const WaterOrderEvent();

  @override
  List<Object> get props => [];
}

class CreateWaterOrder extends WaterOrderEvent {
  final CreateWaterOrderRequestDto dto;

  const CreateWaterOrder(this.dto);

  @override
  List<Object> get props => [dto];
}

class FetchWaterOrderById extends WaterOrderEvent {
  final int orderId;

  const FetchWaterOrderById(this.orderId);

  @override
  List<Object> get props => [orderId];
}

class FetchClientRecentDeliveries extends WaterOrderEvent {
  final int clientId;
  final int pageNumber;
  final int pageSize;
  final String status;

  const FetchClientRecentDeliveries({
    required this.clientId,
    this.pageNumber = 1,
    this.pageSize = 25,
    this.status = 'ALL',
  });

  @override
  List<Object> get props => [clientId, pageNumber, pageSize, status];
}

class FetchWaterDeliveryById extends WaterOrderEvent {
  final int deliveryId;

  const FetchWaterDeliveryById(this.deliveryId);

  @override
  List<Object> get props => [deliveryId];
}

class FetchAllWaterDeliveriesByClientId extends WaterOrderEvent {
  final int clientId;

  const FetchAllWaterDeliveriesByClientId(this.clientId);

  @override
  List<Object> get props => [clientId];
}
