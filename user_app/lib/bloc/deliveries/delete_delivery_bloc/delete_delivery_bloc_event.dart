import 'package:equatable/equatable.dart';

abstract class DeleteDeliveryEvent extends Equatable {
  const DeleteDeliveryEvent();
  @override
  List<Object> get props => [];
}

class DeleteDeliveryRequested extends DeleteDeliveryEvent {
  final String clientId;
  final int deliveryId;
  const DeleteDeliveryRequested(
      {required this.clientId, required this.deliveryId});
  @override
  List<Object> get props => [clientId, deliveryId];
}
