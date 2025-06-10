import 'package:equatable/equatable.dart';
import 'package:langas_user/dto/delivery_dto.dart';

abstract class CreatePaymentEvent extends Equatable {
  const CreatePaymentEvent();
  @override
  List<Object> get props => [];
}

class CreatePaymentSubmitted extends CreatePaymentEvent {
  final String clientId;
  final CreatePaymentRequestDto requestDto;
  const CreatePaymentSubmitted(
      {required this.clientId, required this.requestDto});
  @override
  List<Object> get props => [clientId, requestDto];
}
