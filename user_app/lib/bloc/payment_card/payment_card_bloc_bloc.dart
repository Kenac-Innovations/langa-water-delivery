import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:langas_user/bloc/payment_card/payment_card_bloc_event.dart';
import 'package:langas_user/bloc/payment_card/payment_card_bloc_state.dart';

import 'package:langas_user/repository/payment_card_repository.dart';

class PaymentCardBloc extends Bloc<PaymentCardEvent, PaymentCardState> {
  final PaymentCardRepository _paymentCardRepository;

  PaymentCardBloc({required PaymentCardRepository paymentCardRepository})
      : _paymentCardRepository = paymentCardRepository,
        super(PaymentCardInitial()) {
    on<CreatePaymentCard>(_onCreatePaymentCard);
    on<FetchClientCards>(_onFetchClientCards);
    on<UpdatePaymentCard>(_onUpdatePaymentCard);
    on<DeletePaymentCard>(_onDeletePaymentCard);
    on<SetDefaultPaymentCard>(_onSetDefaultPaymentCard);
  }

  Future<void> _onCreatePaymentCard(
      CreatePaymentCard event, Emitter<PaymentCardState> emit) async {
    emit(PaymentCardLoading());
    final result = await _paymentCardRepository.createPaymentCard(event.dto);
    result.fold(
      (failure) => emit(PaymentCardFailure(failure)),
      (message) => emit(PaymentCardOperationSuccess(message)),
    );
  }

  Future<void> _onFetchClientCards(
      FetchClientCards event, Emitter<PaymentCardState> emit) async {
    emit(PaymentCardLoading());
    final result = await _paymentCardRepository.getClientCards(event.clientId);
    result.fold(
      (failure) => emit(PaymentCardFailure(failure)),
      (cards) => emit(PaymentCardLoadSuccess(cards)),
    );
  }

  Future<void> _onUpdatePaymentCard(
      UpdatePaymentCard event, Emitter<PaymentCardState> emit) async {
    emit(PaymentCardLoading());
    final result =
        await _paymentCardRepository.updatePaymentCard(event.cardId, event.dto);
    result.fold(
      (failure) => emit(PaymentCardFailure(failure)),
      (message) => emit(PaymentCardOperationSuccess(message)),
    );
  }

  Future<void> _onDeletePaymentCard(
      DeletePaymentCard event, Emitter<PaymentCardState> emit) async {
    emit(PaymentCardLoading());
    final result = await _paymentCardRepository.deletePaymentCard(event.cardId);
    result.fold(
      (failure) => emit(PaymentCardFailure(failure)),
      (message) => emit(PaymentCardOperationSuccess(message)),
    );
  }

  Future<void> _onSetDefaultPaymentCard(
      SetDefaultPaymentCard event, Emitter<PaymentCardState> emit) async {
    emit(PaymentCardLoading());
    final result = await _paymentCardRepository.setDefaultCard(
        event.clientId, event.cardId);
    result.fold(
      (failure) => emit(PaymentCardFailure(failure)),
      (message) => emit(PaymentCardOperationSuccess(message)),
    );
  }
}
