import 'package:equatable/equatable.dart';
import 'package:langas_user/models/payment_card_model.dart';
import 'package:langas_user/util/api_failure_models.dart';

abstract class PaymentCardState extends Equatable {
  const PaymentCardState();
  @override
  List<Object> get props => [];
}

class PaymentCardInitial extends PaymentCardState {}

class PaymentCardLoading extends PaymentCardState {}

class PaymentCardOperationSuccess extends PaymentCardState {
  final String message;
  const PaymentCardOperationSuccess(this.message);
  @override
  List<Object> get props => [message];
}

class PaymentCardLoadSuccess extends PaymentCardState {
  final List<PaymentCard> cards;
  const PaymentCardLoadSuccess(this.cards);
  @override
  List<Object> get props => [cards];
}

class PaymentCardFailure extends PaymentCardState {
  final Failure failure;
  const PaymentCardFailure(this.failure);
  @override
  List<Object> get props => [failure];
}
