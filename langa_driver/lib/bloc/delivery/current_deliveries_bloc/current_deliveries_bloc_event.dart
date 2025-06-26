import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart' show immutable;
import 'package:langas_driver/dto/delivery_dto.dart';

@immutable
abstract class CurrentDeliveriesEvent extends Equatable {
  const CurrentDeliveriesEvent();
  @override
  List<Object?> get props => [];
}

class LoadCurrentDeliveries extends CurrentDeliveriesEvent {
  final String driverId;
  final int pageNumber;
  final int pageSize;
  final bool isRefresh;

  const LoadCurrentDeliveries({
    required this.driverId,
    this.pageNumber = 1,
    this.pageSize = 10,
    this.isRefresh = false,
  });
  @override
  List<Object?> get props => [driverId, pageNumber, pageSize, isRefresh];
}

class LoadMoreCurrentDeliveries extends CurrentDeliveriesEvent {
  final String driverId;
  const LoadMoreCurrentDeliveries({required this.driverId});
  @override
  List<Object?> get props => [driverId];
}

class AcceptDeliveryRequested extends CurrentDeliveriesEvent {
  final String deliveryId;
  final AcceptDeliveryRequest request;
  const AcceptDeliveryRequested(
      {required this.deliveryId, required this.request});
  @override
  List<Object?> get props => [deliveryId, request];
}

class PickupDeliveryRequested extends CurrentDeliveriesEvent {
  final String deliveryId;
  final String driverId; // Add driverId here
  final PickupDeliveryRequest request;
  const PickupDeliveryRequested(
      {required this.deliveryId,
      required this.driverId,
      required this.request});
  @override
  List<Object?> get props => [deliveryId, driverId, request];
}

class CompleteDeliveryRequested extends CurrentDeliveriesEvent {
  final String deliveryId;
  final String driverId;
  final CompleteDeliveryRequest request;
  const CompleteDeliveryRequested(
      {required this.deliveryId,
      required this.driverId,
      required this.request});
  @override
  List<Object?> get props => [deliveryId, driverId, request];
}

class CancelDeliveryRequested extends CurrentDeliveriesEvent {
  final String deliveryId;
  final String driverId;
  final CancelDeliveryRequest request;
  const CancelDeliveryRequested(
      {required this.deliveryId,
      required this.driverId,
      required this.request});
  @override
  List<Object?> get props => [deliveryId, driverId, request];
}

class TriggerStartLocationTracking extends CurrentDeliveriesEvent {
  final String driverId;
  final String deliveryId;
  const TriggerStartLocationTracking(
      {required this.driverId, required this.deliveryId});
  @override
  List<Object?> get props => [driverId, deliveryId];
}

class TriggerStopLocationTracking extends CurrentDeliveriesEvent {
  final String deliveryId;
  const TriggerStopLocationTracking({required this.deliveryId});
  @override
  List<Object?> get props => [deliveryId];
}
