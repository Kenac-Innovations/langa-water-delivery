import 'package:dartz/dartz.dart';
import 'package:langas_driver/dto/delivery_dto.dart';
import 'package:langas_driver/models/delivery_models.dart';
import 'package:langas_driver/services/dio_client.dart';
import 'package:langas_driver/utils/api_constants.dart';
import 'package:langas_driver/utils/api_response_model.dart';
import 'package:langas_driver/utils/delivery_enums.dart';
import 'package:langas_driver/utils/failure_models.dart';

class DeliveryRepository {
  final DioClient _dioClient;

  DeliveryRepository(this._dioClient);

  Future<Either<Failure, ApiResponse<String>>> proposeDelivery(
      String deliveryId, ProposeDeliveryRequest request) async {
    try {
      final response = await _dioClient.dio.post(
        ApiConstants.proposeDelivery(deliveryId),
        data: request.toJson(),
      );
      return Right(ApiResponse<String>.fromJsonSimpleData(response.data));
    } catch (e) {
      return Left(_dioClient.handleError(e));
    }
  }

  Future<Either<Failure, ApiResponse<String>>> selectDelivery(
      String clientId, SelectDeliveryRequest request) async {
    try {
      final response = await _dioClient.dio.put(
        ApiConstants.selectDelivery(clientId),
        data: request.toJson(),
      );
      return Right(ApiResponse<String>.fromJsonSimpleData(response.data));
    } catch (e) {
      return Left(_dioClient.handleError(e));
    }
  }

  Future<Either<Failure, ApiResponse<String>>> pickupDelivery(
      String deliveryId, PickupDeliveryRequest request) async {
    try {
      final formData = await request.toFormData();
      final response = await _dioClient.dio.post(
        ApiConstants.pickupDelivery(deliveryId),
        data: formData,
      );
      return Right(ApiResponse<String>.fromJsonSimpleData(response.data));
    } catch (e) {
      return Left(_dioClient.handleError(e));
    }
  }

  Future<Either<Failure, ApiResponse<String>>> completeDelivery(
      String deliveryId, CompleteDeliveryRequest request) async {
    try {
      final response = await _dioClient.dio.put(
        ApiConstants.completeDelivery(deliveryId),
        data: request.toJson(),
      );
      return Right(ApiResponse<String>.fromJsonSimpleData(response.data));
    } catch (e) {
      return Left(_dioClient.handleError(e));
    }
  }

  Future<Either<Failure, ApiResponse<String>>> cancelDelivery(
      String deliveryId, CancelDeliveryRequest request) async {
    try {
      final response = await _dioClient.dio.put(
        ApiConstants.cancelDelivery(deliveryId),
        data: request.toJson(),
      );
      return Right(ApiResponse<String>.fromJsonSimpleData(response.data));
    } catch (e) {
      return Left(_dioClient.handleError(e));
    }
  }

  Future<Either<Failure, ApiResponse<String>>> acceptDelivery(
      String deliveryId, AcceptDeliveryRequest request) async {
    try {
      final response = await _dioClient.dio.put(
        ApiConstants.acceptDelivery(deliveryId),
        data: request.toJson(),
      );
      return Right(ApiResponse<String>.fromJsonSimpleData(response.data));
    } catch (e) {
      return Left(_dioClient.handleError(e));
    }
  }

  Future<Either<Failure, ApiResponse<PaginatedDeliveryResponse>>>
      getDriverDeliveriesHistory({
    required String driverId,
    int pageNumber = 1,
    int pageSize = 25,
    DeliveryStatus? status,
  }) async {
    try {
      final Map<String, dynamic> queryParams = {
        'pageNumber': pageNumber,
        'pageSize': pageSize,
      };
      if (status != null) {
        queryParams['status'] = status.toJson();
      }
      final response = await _dioClient.dio.get(
        ApiConstants.driverDeliveriesHistory(driverId),
        queryParameters: queryParams,
      );
      return Right(ApiResponse<PaginatedDeliveryResponse>.fromJson(
        response.data,
        (dataJson) => PaginatedDeliveryResponse.fromJson(dataJson),
      ));
    } catch (e) {
      return Left(_dioClient.handleError(e));
    }
  }

  Future<Either<Failure, ApiResponse<PaginatedDeliveryResponse>>>
      getOpenDeliveries({
    required String driverId,
    required VehicleType vehicleType,
    int pageNumber = 1,
    int pageSize = 10,
  }) async {
    try {
      final Map<String, dynamic> queryParams = {
        'vehicleType': vehicleType.toJson(),
        'pageNumber': pageNumber,
        'pageSize': pageSize,
      };
      final response = await _dioClient.dio.get(
        ApiConstants.driverOpenDeliveries(driverId),
        queryParameters: queryParams,
      );
      return Right(ApiResponse<PaginatedDeliveryResponse>.fromJson(
        response.data,
        (dataJson) => PaginatedDeliveryResponse.fromJson(dataJson),
      ));
    } catch (e) {
      return Left(_dioClient.handleError(e));
    }
  }

  Future<Either<Failure, ApiResponse<PaginatedDeliveryResponse>>>
      getCurrentDriverDeliveries({
    required String driverId,
    int pageNumber = 1,
    int pageSize = 10,
  }) async {
    try {
      final Map<String, dynamic> queryParams = {
        'pageNumber': pageNumber,
        'pageSize': pageSize,
      };
      final response = await _dioClient.dio.get(
        ApiConstants.driverCurrentDeliveries(driverId),
        queryParameters: queryParams,
      );
      return Right(ApiResponse<PaginatedDeliveryResponse>.fromJson(
        response.data,
        (dataJson) => PaginatedDeliveryResponse.fromJson(dataJson),
      ));
    } catch (e) {
      return Left(_dioClient.handleError(e));
    }
  }

  Future<Either<Failure, ApiResponse<Delivery>>> getDeliveryDetails(
      String deliveryId) async {
    try {
      final response = await _dioClient.dio.get(
        ApiConstants.deliveryDetails(deliveryId),
      );
      return Right(ApiResponse<Delivery>.fromJson(
        response.data,
        (dataJson) => Delivery.fromJson(dataJson),
      ));
    } catch (e) {
      return Left(_dioClient.handleError(e));
    }
  }
}
