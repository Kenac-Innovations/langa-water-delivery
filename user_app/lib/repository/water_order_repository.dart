import 'package:dartz/dartz.dart';
import 'package:langas_user/dto/water_order_dto.dart';
import 'package:langas_user/dto/pagination_dto.dart';
import 'package:langas_user/models/water_order_model.dart';
import 'package:langas_user/services/dio_client.dart';
import 'package:langas_user/util/api_constants.dart';
import 'package:langas_user/util/api_failure_models.dart';
import 'package:langas_user/util/api_pagenated_model.dart';

class WaterOrderRepository {
  final DioClient _dioClient;

  WaterOrderRepository({required DioClient dioClient}) : _dioClient = dioClient;

  Future<Either<Failure, WaterOrder>> createWaterOrder(
      CreateWaterOrderRequestDto dto) async {
    try {
      final response = await _dioClient.dio
          .post(ApiConstants.createWaterOrder, data: dto.toJson());

      if (response.statusCode == 200) {
        final waterOrder =
            WaterOrderResponseDto.fromJson(response.data['data']).toDomain();
        return Right(waterOrder);
      } else {
        return Left(ServerFailure(
            message: 'Failed to create water order: ${response.statusCode}'));
      }
    } catch (e) {
      return Left(_dioClient.handleError(e));
    }
  }

  Future<Either<Failure, WaterOrder>> getWaterOrderById(int orderId) async {
    try {
      final response =
          await _dioClient.dio.get(ApiConstants.waterOrderById(orderId));
      if (response.statusCode == 200) {
        final waterOrder =
            WaterOrderResponseDto.fromJson(response.data['data']).toDomain();
        return Right(waterOrder);
      } else {
        return Left(ServerFailure(
            message: 'Failed to get water order: ${response.statusCode}'));
      }
    } catch (e) {
      return Left(_dioClient.handleError(e));
    }
  }

  Future<Either<Failure, PaginatedResponse<WaterOrder>>>
      getClientRecentDeliveries(
          int clientId, int pageNumber, int pageSize, String status) async {
    try {
      final response = await _dioClient.dio.get(
        ApiConstants.clientRecentDeliveries(clientId),
        queryParameters: {
          'status': status,
          'pageNumber': pageNumber,
          'pageSize': pageSize,
        },
      );
      if (response.statusCode == 200) {
        final paginatedResponse =
            PaginatedWaterOrderResponseDto.fromJson(response.data['data'])
                .toDomain();
        return Right(paginatedResponse);
      } else {
        return Left(ServerFailure(
            message:
                'Failed to get client recent deliveries: ${response.statusCode}'));
      }
    } catch (e) {
      return Left(_dioClient.handleError(e));
    }
  }

  Future<Either<Failure, WaterDelivery>> getWaterDeliveryById(
      int orderId) async {
    try {
      final response =
          await _dioClient.dio.get(ApiConstants.waterDeliveryById(orderId));
      if (response.statusCode == 200) {
        final waterDelivery =
            WaterDeliveryResponseDto.fromJson(response.data['data']).toDomain();
        return Right(waterDelivery);
      } else {
        return Left(ServerFailure(
            message:
                'Failed to get water delivery by id: ${response.statusCode}'));
      }
    } catch (e) {
      return Left(_dioClient.handleError(e));
    }
  }

  Future<Either<Failure, PaginatedResponse<WaterDelivery>>>
      getAllWaterDeliveriesByClientId(int clientId) async {
    try {
      final response = await _dioClient.dio
          .get(ApiConstants.allWaterDeliveriesByClientId(clientId));
      if (response.statusCode == 200) {
        final List<dynamic> content = response.data['data']['content'];
        final deliveries = content
            .map((d) => WaterDeliveryResponseDto.fromJson(d).toDomain())
            .toList();
        final pagination =
            PaginationDto.fromJson(response.data['data']['pagination']);
        return Right(
            PaginatedResponse(content: deliveries, pagination: pagination));
      } else {
        return Left(ServerFailure(
            message:
                'Failed to get all water deliveries by client id: ${response.statusCode}'));
      }
    } catch (e) {
      return Left(_dioClient.handleError(e));
    }
  }
}
