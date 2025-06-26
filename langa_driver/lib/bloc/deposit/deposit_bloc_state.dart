import 'package:equatable/equatable.dart';
import 'package:langas_driver/utils/failure_models.dart';

abstract class DepositState extends Equatable {
  const DepositState();

  @override
  List<Object?> get props => [];
}

class DepositInitial extends DepositState {}

class DepositInitiationLoading extends DepositState {}

class DepositInitiationSuccess extends DepositState {
  final String transactionId;
  final String? paymentLink;
  final String? initialMessage;

  const DepositInitiationSuccess({
    required this.transactionId,
    this.paymentLink,
    this.initialMessage,
  });

  @override
  List<Object?> get props => [transactionId, paymentLink, initialMessage];
}

class DepositInitiationFailure extends DepositState {
  final Failure failure;

  const DepositInitiationFailure({required this.failure});

  @override
  List<Object?> get props => [failure];
}

class DepositAwaitingCompletion extends DepositState {
  final String transactionId;
  final String? paymentLink;
  final String message;

  const DepositAwaitingCompletion({
    required this.transactionId,
    this.paymentLink,
    this.message = "Processing payment. Please complete if prompted.",
  });
  @override
  List<Object?> get props => [transactionId, paymentLink, message];
}

class DepositProcessingSuccess extends DepositState {
  final String transactionId;
  final String message;

  const DepositProcessingSuccess({
    required this.transactionId,
    required this.message,
  });

  @override
  List<Object?> get props => [transactionId, message];
}

class DepositProcessingFailure extends DepositState {
  final String transactionId;
  final String error;

  const DepositProcessingFailure({
    required this.transactionId,
    required this.error,
  });

  @override
  List<Object?> get props => [transactionId, error];
}
