import 'package:equatable/equatable.dart';
import 'package:langas_driver/models/wallet_model.dart';
import 'package:langas_driver/utils/failure_models.dart';

abstract class WalletFloatState extends Equatable {
  const WalletFloatState();

  @override
  List<Object?> get props => [];
}

class WalletFloatInitial extends WalletFloatState {}

class WalletFloatLoading extends WalletFloatState {}

class WalletFloatLoadSuccess extends WalletFloatState {
  final WalletFloat walletFloat;

  const WalletFloatLoadSuccess({required this.walletFloat});

  @override
  List<Object?> get props => [walletFloat];
}

class WalletFloatLoadFailure extends WalletFloatState {
  final Failure failure;

  const WalletFloatLoadFailure({required this.failure});

  @override
  List<Object?> get props => [failure];
}
