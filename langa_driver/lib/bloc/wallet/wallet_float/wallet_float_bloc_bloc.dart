import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:langas_driver/bloc/wallet/wallet_float/wallet_float_bloc_event.dart';
import 'package:langas_driver/bloc/wallet/wallet_float/wallet_float_bloc_state.dart';
import 'package:langas_driver/models/wallet_model.dart';
import 'package:langas_driver/repository/wallet_repository.dart';
import 'package:langas_driver/utils/api_response_model.dart';
import 'package:langas_driver/utils/failure_models.dart';
import 'package:dartz/dartz.dart';

class WalletFloatBloc extends Bloc<WalletFloatEvent, WalletFloatState> {
  final WalletRepository _walletRepository;

  WalletFloatBloc({required WalletRepository walletRepository})
      : _walletRepository = walletRepository,
        super(WalletFloatInitial()) {
    on<FetchWalletFloat>(_onFetchWalletFloat);
  }

  Future<void> _onFetchWalletFloat(
      FetchWalletFloat event, Emitter<WalletFloatState> emit) async {
    emit(WalletFloatLoading());
    final Either<Failure, ApiResponse<WalletFloat>> result =
        await _walletRepository.getDriverWalletFloat(
      driverId: event.driverId,
      currencyId: event.currencyId ?? 1,
    );

    result.fold(
      (failure) => emit(WalletFloatLoadFailure(failure: failure)),
      (apiResponse) {
        if (apiResponse.success && apiResponse.data != null) {
          emit(WalletFloatLoadSuccess(walletFloat: apiResponse.data!));
        } else {
          emit(WalletFloatLoadFailure(
              failure: ServerFailure(message: apiResponse.message)));
        }
      },
    );
  }
}
