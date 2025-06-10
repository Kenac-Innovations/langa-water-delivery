import 'package:equatable/equatable.dart';
import 'package:langas_user/dto/delivery_dto.dart';

abstract class DeliveryPriceEvent extends Equatable {
  const DeliveryPriceEvent();
  @override
  List<Object> get props => [];
}

class GetDeliveryPriceRequested extends DeliveryPriceEvent {
  final PriceGeneratorRequestDto requestDto;
  const GetDeliveryPriceRequested({required this.requestDto});
  @override
  List<Object> get props => [requestDto];
}
