import 'package:equatable/equatable.dart';
import 'package:langas_driver/models/wallet_model.dart';
import 'package:langas_driver/utils/failure_models.dart';

abstract class WalletTransactionsState extends Equatable {
  const WalletTransactionsState();

  @override
  List<Object?> get props => [];
}

class WalletTransactionsInitial extends WalletTransactionsState {}

class WalletTransactionsLoading extends WalletTransactionsState {}

class WalletTransactionsLoadSuccess extends WalletTransactionsState {
  final List<WalletTransaction> transactions;
  final bool hasReachedMax;
  final int currentPage;
  final int pageSize;

  const WalletTransactionsLoadSuccess({
    required this.transactions,
    required this.hasReachedMax,
    required this.currentPage,
    required this.pageSize,
  });

  WalletTransactionsLoadSuccess copyWith({
    List<WalletTransaction>? transactions,
    bool? hasReachedMax,
    int? currentPage,
    int? pageSize,
  }) {
    return WalletTransactionsLoadSuccess(
      transactions: transactions ?? this.transactions,
      hasReachedMax: hasReachedMax ?? this.hasReachedMax,
      currentPage: currentPage ?? this.currentPage,
      pageSize: pageSize ?? this.pageSize,
    );
  }

  @override
  List<Object?> get props =>
      [transactions, hasReachedMax, currentPage, pageSize];
}

class WalletTransactionsLoadFailure extends WalletTransactionsState {
  final Failure failure;

  const WalletTransactionsLoadFailure({required this.failure});

  @override
  List<Object?> get props => [failure];
}

class WalletTransactionsLoadingNextPage extends WalletTransactionsLoadSuccess {
  const WalletTransactionsLoadingNextPage({
    required super.transactions,
    required super.hasReachedMax,
    required super.currentPage,
    required super.pageSize,
  });
}

class WalletTransactionsNextPageError extends WalletTransactionsLoadSuccess {
  final Failure failure;

  const WalletTransactionsNextPageError({
    required this.failure,
    required super.transactions,
    required super.hasReachedMax,
    required super.currentPage,
    required super.pageSize,
  });

  @override
  List<Object?> get props => [...super.props, failure];
}
