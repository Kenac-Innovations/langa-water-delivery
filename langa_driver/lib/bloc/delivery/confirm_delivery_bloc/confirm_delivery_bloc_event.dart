import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:langas_driver/dto/delivery_dto.dart';

@immutable
abstract class ConfirmDeliveryEvent extends Equatable {
  const ConfirmDeliveryEvent();
  @override
  List<Object> get props => [];
}

class ConfirmDeliveryRequested extends ConfirmDeliveryEvent {
  final String clientId;
  final SelectDeliveryRequest request;

  const ConfirmDeliveryRequested({
    required this.clientId,
    required this.request,
  });

  @override
  List<Object> get props => [clientId, request];
}
