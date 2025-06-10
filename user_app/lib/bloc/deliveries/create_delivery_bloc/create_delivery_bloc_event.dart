import 'package:equatable/equatable.dart';
import 'package:langas_user/dto/delivery_dto.dart';

abstract class CreateDeliveryEvent extends Equatable {
  const CreateDeliveryEvent();
  @override
  List<Object> get props => [];
}

class SubmitDelivery extends CreateDeliveryEvent {
  final String clientId;
  final CreateDeliveryRequestDto requestDto;
  const SubmitDelivery({required this.clientId, required this.requestDto});
  @override
  List<Object> get props => [clientId, requestDto];
}
