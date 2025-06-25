import 'package:equatable/equatable.dart';
import 'package:langas_user/dto/payment_card_dto.dart';

abstract class PaymentCardEvent extends Equatable {
  const PaymentCardEvent();
  @override
  List<Object> get props => [];
}

class CreatePaymentCard extends PaymentCardEvent {
  final CreatePaymentCardRequestDto dto;
  const CreatePaymentCard(this.dto);
  @override
  List<Object> get props => [dto];
}

class FetchClientCards extends PaymentCardEvent {
  final int clientId;
  const FetchClientCards(this.clientId);
  @override
  List<Object> get props => [clientId];
}

class UpdatePaymentCard extends PaymentCardEvent {
  final int cardId;
  final UpdatePaymentCardRequestDto dto;
  const UpdatePaymentCard(this.cardId, this.dto);
  @override
  List<Object> get props => [cardId, dto];
}

class DeletePaymentCard extends PaymentCardEvent {
  final int cardId;
  const DeletePaymentCard(this.cardId);
  @override
  List<Object> get props => [cardId];
}

class SetDefaultPaymentCard extends PaymentCardEvent {
  final int clientId;
  final int cardId;
  const SetDefaultPaymentCard(this.clientId, this.cardId);
  @override
  List<Object> get props => [clientId, cardId];
}