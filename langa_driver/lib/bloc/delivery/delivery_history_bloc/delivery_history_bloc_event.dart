import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart' show immutable;
import 'package:langas_driver/utils/delivery_enums.dart';

@immutable
abstract class DeliveryHistoryEvent extends Equatable {
  const DeliveryHistoryEvent();
  @override
  List<Object?> get props => [];
}

class LoadDeliveryHistory extends DeliveryHistoryEvent {
  final String driverId;
  final int pageNumber;
  final int pageSize;
  final List<DeliveryStatus> statuses; //
  final bool isRefresh;

  const LoadDeliveryHistory({
    required this.driverId,
    required this.statuses,
    this.pageNumber = 1,
    this.pageSize = 10,
    this.isRefresh = false,
  });
  @override
  List<Object?> get props =>
      [driverId, pageNumber, pageSize, statuses, isRefresh];
}

class LoadMoreDeliveryHistory extends DeliveryHistoryEvent {
  final String driverId;
  final List<DeliveryStatus> statuses;
  const LoadMoreDeliveryHistory(
      {required this.driverId, required this.statuses});
  @override
  List<Object?> get props => [driverId, statuses];
}
