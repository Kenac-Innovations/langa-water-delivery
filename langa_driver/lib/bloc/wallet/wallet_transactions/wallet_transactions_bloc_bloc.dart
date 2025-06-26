import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:langas_driver/bloc/wallet/wallet_transactions/wallet_transactions_bloc_event.dart';
import 'package:langas_driver/bloc/wallet/wallet_transactions/wallet_transactions_bloc_state.dart';
import 'package:langas_driver/models/wallet_model.dart';
import 'package:langas_driver/repository/wallet_repository.dart';
import 'package:langas_driver/utils/api_response_model.dart';
import 'package:langas_driver/utils/failure_models.dart';
import 'package:dartz/dartz.dart';

class WalletTransactionsBloc
    extends Bloc<WalletTransactionsEvent, WalletTransactionsState> {
  final WalletRepository _walletRepository;

  WalletTransactionsBloc({required WalletRepository walletRepository})
      : _walletRepository = walletRepository,
        super(WalletTransactionsInitial()) {
    on<FetchWalletTransactions>(_onFetchWalletTransactions);
    on<FetchMoreWalletTransactions>(_onFetchMoreWalletTransactions);
  }

  Future<void> _onFetchWalletTransactions(FetchWalletTransactions event,
      Emitter<WalletTransactionsState> emit) async {
    if (event.pageNumber == 1 || event.isRefresh) {
      emit(WalletTransactionsLoading());
    }
    await _fetchAndEmitTransactions(
        event.driverId, event.pageNumber, event.pageSize, emit,
        isRefresh: event.isRefresh);
  }

  Future<void> _onFetchMoreWalletTransactions(FetchMoreWalletTransactions event,
      Emitter<WalletTransactionsState> emit) async {
    if (state is WalletTransactionsLoadSuccess &&
        !(state as WalletTransactionsLoadSuccess).hasReachedMax) {
      final currentState = state as WalletTransactionsLoadSuccess;
      emit(WalletTransactionsLoadingNextPage(
        transactions: currentState.transactions,
        hasReachedMax: currentState.hasReachedMax,
        currentPage: currentState.currentPage,
        pageSize: currentState.pageSize,
      ));
      await _fetchAndEmitTransactions(event.driverId,
          currentState.currentPage + 1, currentState.pageSize, emit,
          isLoadMore: true, currentTransactions: currentState.transactions);
    }
  }

  Future<void> _fetchAndEmitTransactions(
    String driverId,
    int pageNumber,
    int pageSize,
    Emitter<WalletTransactionsState> emit, {
    bool isLoadMore = false,
    List<WalletTransaction> currentTransactions = const [],
    bool isRefresh = false,
  }) async {
    final Either<Failure, ApiResponse<PaginatedWalletTransactions>> result =
        await _walletRepository.getDriverTransactions(
      driverId: driverId,
      pageNumber: pageNumber,
      pageSize: pageSize,
    );

    result.fold(
      (failure) {
        if (isLoadMore && state is WalletTransactionsLoadSuccess) {
          final s = state as WalletTransactionsLoadSuccess;
          emit(WalletTransactionsNextPageError(
            failure: failure,
            transactions: s.transactions,
            hasReachedMax: s.hasReachedMax,
            currentPage: s.currentPage,
            pageSize: s.pageSize,
          ));
        } else {
          emit(WalletTransactionsLoadFailure(failure: failure));
        }
      },
      (apiResponse) {
        if (apiResponse.success && apiResponse.data != null) {
          final pageData = apiResponse.data!;
          final bool hasReachedMax = pageData.pagination.pageNumber >=
                  pageData.pagination.totalPages ||
              pageData.content.isEmpty;

          final List<WalletTransaction> combinedList =
              (isLoadMore && !isRefresh)
                  ? (currentTransactions + pageData.content)
                  : pageData.content;

          emit(WalletTransactionsLoadSuccess(
            transactions: combinedList,
            hasReachedMax: hasReachedMax,
            currentPage: pageData.pagination.pageNumber,
            pageSize: pageData.pagination.pageSize,
          ));
        } else {
          final failure = ServerFailure(message: apiResponse.message);
          if (isLoadMore && state is WalletTransactionsLoadSuccess) {
            final s = state as WalletTransactionsLoadSuccess;
            emit(WalletTransactionsNextPageError(
              failure: failure,
              transactions: s.transactions,
              hasReachedMax: s.hasReachedMax,
              currentPage: s.currentPage,
              pageSize: s.pageSize,
            ));
          } else {
            emit(WalletTransactionsLoadFailure(failure: failure));
          }
        }
      },
    );
  }
}
