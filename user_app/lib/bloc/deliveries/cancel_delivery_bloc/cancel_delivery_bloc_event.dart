import 'package:equatable/equatable.dart';
import 'package:langas_user/dto/delivery_dto.dart';

abstract class CancelDeliveryEvent extends Equatable {
  const CancelDeliveryEvent();
  @override
  List<Object> get props => [];
}

class CancelDeliverySubmitted extends CancelDeliveryEvent {
  final String clientId;
  final CancelDeliveryRequestDto requestDto;
  const CancelDeliverySubmitted(
      {required this.clientId, required this.requestDto});
  @override
  List<Object> get props => [clientId, requestDto];
}
