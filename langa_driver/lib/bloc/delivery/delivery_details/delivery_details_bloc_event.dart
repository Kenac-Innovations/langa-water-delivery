import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';

@immutable
abstract class DeliveryDetailsEvent extends Equatable {
  const DeliveryDetailsEvent();
  @override
  List<Object?> get props => [];
}

class FetchDeliveryRouteDetails extends DeliveryDetailsEvent {
  final String deliveryId;
  const FetchDeliveryRouteDetails({required this.deliveryId});
  @override
  List<Object?> get props => [deliveryId];
}
