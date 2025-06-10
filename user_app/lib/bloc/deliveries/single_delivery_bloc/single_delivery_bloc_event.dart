import 'package:equatable/equatable.dart';

abstract class SingleDeliveryEvent extends Equatable {
  const SingleDeliveryEvent();
  @override List<Object> get props => [];
}

class FetchSingleDeliveryRequested extends SingleDeliveryEvent {
  final String clientId;
  final int deliveryId;
  const FetchSingleDeliveryRequested({required this.clientId, required this.deliveryId});
  @override List<Object> get props => [clientId, deliveryId];
}