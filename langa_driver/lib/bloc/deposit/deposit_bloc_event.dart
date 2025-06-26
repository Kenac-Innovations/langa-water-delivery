import 'package:equatable/equatable.dart';
import 'package:langas_driver/dto/wallet_dto.dart';

abstract class DepositEvent extends Equatable {
  const DepositEvent();

  @override
  List<Object?> get props => [];
}

class InitiateDriverDepositRequested extends DepositEvent {
  final DriverWalletDepositRequest request;

  const InitiateDriverDepositRequested({
    required this.request,
  });

  @override
  List<Object?> get props => [request];
}

class FirebaseTransactionUpdateReceived extends DepositEvent {
  final String transactionId;
  final String status;
  final String? narration;

  const FirebaseTransactionUpdateReceived({
    required this.transactionId,
    required this.status,
    this.narration,
  });

  @override
  List<Object?> get props => [transactionId, status, narration];
}

class ResetDepositBloc extends DepositEvent {
  const ResetDepositBloc();
}
