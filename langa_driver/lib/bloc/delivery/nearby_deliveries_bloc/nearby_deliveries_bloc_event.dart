import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart' show immutable;
import 'package:langas_driver/dto/delivery_dto.dart';
import 'package:langas_driver/utils/delivery_enums.dart';

@immutable
abstract class NearbyDeliveriesEvent extends Equatable {
  const NearbyDeliveriesEvent();
  @override
  List<Object?> get props => [];
}

class LoadNearbyDeliveries extends NearbyDeliveriesEvent {
  final String driverId;
  final VehicleType vehicleType;
  final int pageNumber;
  final int pageSize;
  final bool isRefresh;

  const LoadNearbyDeliveries({
    required this.driverId,
    required this.vehicleType,
    this.pageNumber = 1,
    this.pageSize = 10,
    this.isRefresh = false,
  });

  @override
  List<Object?> get props =>
      [driverId, vehicleType, pageNumber, pageSize, isRefresh];
}

class LoadMoreNearbyDeliveries extends NearbyDeliveriesEvent {
  final String driverId;
  final VehicleType vehicleType;
  const LoadMoreNearbyDeliveries(
      {required this.driverId, required this.vehicleType});
  @override
  List<Object?> get props => [driverId, vehicleType];
}
