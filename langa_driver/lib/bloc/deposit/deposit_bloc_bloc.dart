import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:langas_driver/bloc/deposit/deposit_bloc_event.dart';
import 'package:langas_driver/bloc/deposit/deposit_bloc_state.dart';
import 'package:langas_driver/models/wallet_model.dart';
import 'package:langas_driver/repository/wallet_repository.dart';
import 'package:langas_driver/utils/api_response_model.dart';
import 'package:langas_driver/utils/failure_models.dart';
import 'package:dartz/dartz.dart';

class DepositBloc extends Bloc<DepositEvent, DepositState> {
  final WalletRepository _walletRepository;

  DepositBloc({
    required WalletRepository walletRepository,
  })  : _walletRepository = walletRepository,
        super(DepositInitial()) {
    on<InitiateDriverDepositRequested>(_onInitiateDriverDepositRequested);
    on<FirebaseTransactionUpdateReceived>(_onFirebaseTransactionUpdateReceived);
    on<ResetDepositBloc>(_onResetDepositBloc);
  }

  Future<void> _onInitiateDriverDepositRequested(
    InitiateDriverDepositRequested event,
    Emitter<DepositState> emit,
  ) async {
    emit(DepositInitiationLoading());

    final Either<Failure, ApiResponse<WalletTransaction>> result =
        await _walletRepository.initiateDriverDeposit(event.request);

    result.fold(
      (failure) => emit(DepositInitiationFailure(failure: failure)),
      (apiResponse) {
        if (apiResponse.success && apiResponse.data != null) {
          final transaction = apiResponse.data!;
          emit(DepositInitiationSuccess(
            transactionId: transaction.id,
            paymentLink: transaction.paymentLink,
            initialMessage: transaction.narration.isNotEmpty
                ? transaction.narration
                : apiResponse.message,
          ));
          emit(DepositAwaitingCompletion(
            transactionId: transaction.id,
            paymentLink: transaction.paymentLink,
            message:
                "Please complete your payment. We're listening for updates.",
          ));
        } else {
          emit(DepositInitiationFailure(
              failure: ServerFailure(message: apiResponse.message)));
        }
      },
    );
  }

  Future<void> _onFirebaseTransactionUpdateReceived(
    FirebaseTransactionUpdateReceived event,
    Emitter<DepositState> emit,
  ) async {
    final status = event.status.toUpperCase();
    final message = event.narration ?? "Transaction status updated.";

    if (status == "PAID" || status == "COMPLETED") {
      emit(DepositProcessingSuccess(
          transactionId: event.transactionId, message: message));
    } else if (status == "FAILED" ||
        status == "CANCELLED" ||
        status == "CANCELED") {
      emit(DepositProcessingFailure(
          transactionId: event.transactionId, error: message));
    } else if (status == "PENDING") {
      if (state is DepositAwaitingCompletion) {
        final currentState = state as DepositAwaitingCompletion;
        emit(DepositAwaitingCompletion(
          transactionId: event.transactionId,
          paymentLink: currentState.paymentLink,
          message:
              "Payment is still pending. Please wait or complete the action.",
        ));
      } else {
        emit(DepositAwaitingCompletion(
          transactionId: event.transactionId,
          message: "Payment is currently pending.",
        ));
      }
    }
  }

  void _onResetDepositBloc(
    ResetDepositBloc event,
    Emitter<DepositState> emit,
  ) {
    emit(DepositInitial());
  }
}
