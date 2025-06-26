import 'package:dartz/dartz.dart';
import 'package:langas_driver/dto/wallet_dto.dart';
import 'package:langas_driver/models/wallet_model.dart';
import 'package:langas_driver/services/dio_client.dart';
import 'package:langas_driver/utils/api_constants.dart';
import 'package:langas_driver/utils/api_response_model.dart';
import 'package:langas_driver/utils/failure_models.dart';

class WalletRepository {
  final DioClient _dioClient;

  WalletRepository(this._dioClient);

  Future<Either<Failure, ApiResponse<WalletFloat>>> getDriverWalletFloat({
    required String driverId,
    int currencyId = 1,
  }) async {
    try {
      final response = await _dioClient.dio.get(
        ApiConstants.driverWalletFloat(driverId),
        queryParameters: {'currencyId': currencyId},
      );
      return Right(ApiResponse<WalletFloat>.fromJson(
        response.data,
        (dataJson) => WalletFloat.fromJson(dataJson),
      ));
    } catch (e) {
      return Left(_dioClient.handleError(e));
    }
  }

  Future<Either<Failure, ApiResponse<PaginatedWalletTransactions>>>
      getDriverTransactions({
    required String driverId,
    int pageNumber = 1,
    int pageSize = 15,
  }) async {
    try {
      final response = await _dioClient.dio.get(
        ApiConstants.driverTransactions(driverId),
        queryParameters: {
          'pageNumber': pageNumber,
          'pageSize': pageSize,
        },
      );
      return Right(ApiResponse<PaginatedWalletTransactions>.fromJson(
        response.data,
        (dataJson) => PaginatedWalletTransactions.fromJson(dataJson),
      ));
    } catch (e) {
      return Left(_dioClient.handleError(e));
    }
  }

  Future<Either<Failure, ApiResponse<WalletTransaction>>> initiateDriverDeposit(
      DriverWalletDepositRequest request) async {
    try {
      final response = await _dioClient.dio.post(
        ApiConstants.driverWalletDeposit,
        data: request.toJson(),
      );
      return Right(ApiResponse<WalletTransaction>.fromJson(
        response.data,
        (dataJson) => WalletTransaction.fromJson(dataJson),
      ));
    } catch (e) {
      return Left(_dioClient.handleError(e));
    }
  }
}
