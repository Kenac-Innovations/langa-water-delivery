import 'package:equatable/equatable.dart';

abstract class WalletTransactionsEvent extends Equatable {
  const WalletTransactionsEvent();

  @override
  List<Object?> get props => [];
}

class FetchWalletTransactions extends WalletTransactionsEvent {
  final String driverId;
  final int pageNumber;
  final int pageSize;
  final bool isRefresh;

  const FetchWalletTransactions({
    required this.driverId,
    this.pageNumber = 1,
    this.pageSize = 15,
    this.isRefresh = false,
  });

  @override
  List<Object?> get props => [driverId, pageNumber, pageSize, isRefresh];
}

class FetchMoreWalletTransactions extends WalletTransactionsEvent {
  final String driverId;

  const FetchMoreWalletTransactions({required this.driverId});

  @override
  List<Object?> get props => [driverId];
}
