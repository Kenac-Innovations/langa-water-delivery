import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:langas_user/dto/delivery_dto.dart';
import 'package:langas_user/models/delivery_model.dart';
import 'package:langas_user/models/driver_model.dart';
import 'package:langas_user/models/vehicle_model.dart';
import 'package:langas_user/services/dio_client.dart';
import 'package:langas_user/util/api_constants.dart';
import 'package:langas_user/util/api_failure_models.dart';
import 'package:langas_user/util/api_pagenated_model.dart';
import 'package:langas_user/util/apps_enums.dart';

class DeliveryRepository {
  final DioClient _dioClient;

  DeliveryRepository({required DioClient dioClient}) : _dioClient = dioClient;

  Future<Either<Failure, String>> _handleSimpleSuccessResponse(
      Response response) async {
    try {
      final responseData = response.data as Map<String, dynamic>;
      if (responseData['success'] == true) {
        return Right(responseData['message'] as String? ??
            responseData['data'] as String? ??
            'Operation successful.');
      } else {
        return Left(ServerFailure(
          message: responseData['message'] ??
              'API returned success=false without a message.',
          statusCode: response.statusCode,
        ));
      }
    } catch (e) {
      return Left(UnknownFailure(
          message: 'Failed to parse success response: ${e.toString()}'));
    }
  }

  Future<Either<Failure, Delivery>> createDelivery(
      {required String clientId,
      required CreateDeliveryRequestDto requestDto}) async {
    try {
      final response = await _dioClient.dio.post(
        ApiConstants.clientDeliveries(clientId),
        data: requestDto.toJson(),
      );
      final responseData = response.data as Map<String, dynamic>;
      if (responseData['success'] == true && responseData['data'] != null) {
        final deliveryDto = DeliveryDto.fromJson(responseData['data']);
        return Right(deliveryDto.toDomain());
      } else {
        return Left(ServerFailure(
            message: responseData['message'] ?? 'Failed to create delivery.',
            statusCode: response.statusCode));
      }
    } catch (e) {
      return Left(_dioClient.handleError(e));
    }
  }

  Future<Either<Failure, Delivery>> getDeliveryById(
      {required String clientId, required int deliveryId}) async {
    try {
      final response = await _dioClient.dio.get(
        ApiConstants.deliveryById(clientId, deliveryId),
      );
      final responseData = response.data as Map<String, dynamic>;
      if (responseData['success'] == true && responseData['data'] != null) {
        final deliveryDto = DeliveryDto.fromJson(responseData['data']);
        return Right(deliveryDto.toDomain());
      } else {
        return Left(ServerFailure(
            message: responseData['message'] ?? 'Failed to fetch delivery.',
            statusCode: response.statusCode));
      }
    } catch (e) {
      return Left(_dioClient.handleError(e));
    }
  }

  Future<Either<Failure, String>> deleteDeliveryById(
      {required String clientId, required int deliveryId}) async {
    try {
      final response = await _dioClient.dio.delete(
        ApiConstants.deliveryById(clientId, deliveryId),
      );
      return _handleSimpleSuccessResponse(response);
    } catch (e) {
      return Left(_dioClient.handleError(e));
    }
  }

  Future<Either<Failure, PaginatedResponse<Delivery>>> getDeliveryHistory({
    required String clientId,
    int pageNumber = 0,
    int pageSize = 25,
    DeliveryStatus status = DeliveryStatus.UNKNOWN,
  }) async {
    try {
      final queryParams = {
        'pageNumber': pageNumber,
        'pageSize': pageSize,
      };
      if (status != DeliveryStatus.UNKNOWN) {
        queryParams['status'] = status.toJson() as int;
      }

      final response = await _dioClient.dio.get(
        ApiConstants.clientDeliveryHistory(clientId),
        queryParameters: queryParams,
      );
      final paginatedDto = PaginatedDeliveryResponseDto.fromJson(response.data);
      return Right(paginatedDto.toDomain());
    } catch (e) {
      return Left(_dioClient.handleError(e));
    }
  }

  Future<Either<Failure, PaginatedResponse<Delivery>>> getCurrentDeliveries({
    required String clientId,
    int pageNumber = 0,
    int pageSize = 25,
    List<DeliveryStatus>? statuses,
  }) async {
    try {
      final queryParams = <String, dynamic>{
        'pageNumber': pageNumber,
        'pageSize': pageSize,
      };
      if (statuses != null && statuses.isNotEmpty) {
        queryParams['status'] = statuses.map((s) => s.toJson()).join(',');
      }

      final response = await _dioClient.dio.get(
        ApiConstants.clientDeliveries(clientId),
        queryParameters: queryParams,
      );
      final paginatedDto = PaginatedDeliveryResponseDto.fromJson(response.data);
      return Right(paginatedDto.toDomain());
    } catch (e) {
      return Left(_dioClient.handleError(e));
    }
  }

  Future<Either<Failure, String>> selectDriverForDelivery(
      {required String clientId,
      required SelectDriverRequestDto requestDto}) async {
    try {
      final response = await _dioClient.dio.put(
        ApiConstants.selectDriverForDelivery(clientId),
        data: requestDto.toJson(),
      );
      return _handleSimpleSuccessResponse(response);
    } catch (e) {
      return Left(_dioClient.handleError(e));
    }
  }

  Future<Either<Failure, String>> cancelDelivery(
      {required String clientId,
      required CancelDeliveryRequestDto requestDto}) async {
    try {
      final response = await _dioClient.dio.put(
        ApiConstants.cancelClientDelivery(clientId),
        data: requestDto.toJson(),
      );
      return _handleSimpleSuccessResponse(response);
    } catch (e) {
      return Left(_dioClient.handleError(e));
    }
  }

  Future<Either<Failure, String>> createDeliveryPayment(
      {required String clientId,
      required CreatePaymentRequestDto requestDto}) async {
    try {
      final response = await _dioClient.dio.post(
        ApiConstants.createDeliveryPayment(clientId),
        data: requestDto.toJson(),
      );
      return _handleSimpleSuccessResponse(response);
    } catch (e) {
      return Left(_dioClient.handleError(e));
    }
  }

  Future<Either<Failure, num>> getDeliveryPrice(
      {required PriceGeneratorRequestDto requestDto}) async {
    try {
      final response = await _dioClient.dio.post(
        ApiConstants.priceGenerator,
        data: requestDto.toJson(),
      );
      final responseData = response.data as Map<String, dynamic>;
      if (responseData['success'] == true && responseData['data'] != null) {
        final price = responseData['data'] as num? ?? 0;
        return Right(price);
      } else {
        return Left(ServerFailure(
            message: responseData['message'] ?? 'Failed to get price estimate.',
            statusCode: response.statusCode));
      }
    } catch (e) {
      return Left(_dioClient.handleError(e));
    }
  }
}
