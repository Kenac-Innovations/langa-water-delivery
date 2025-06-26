import 'package:equatable/equatable.dart';

abstract class WalletFloatEvent extends Equatable {
  const WalletFloatEvent();

  @override
  List<Object?> get props => [];
}

class FetchWalletFloat extends WalletFloatEvent {
  final String driverId;
  final int? currencyId;

  const FetchWalletFloat({required this.driverId, this.currencyId = 1});

  @override
  List<Object?> get props => [driverId, currencyId];
}