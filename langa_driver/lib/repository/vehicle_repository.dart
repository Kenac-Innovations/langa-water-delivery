import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:langas_driver/dto/vehicle_dto.dart';
import 'package:langas_driver/models/vehicle_model.dart';
import 'package:langas_driver/services/dio_client.dart';
import 'package:langas_driver/utils/api_constants.dart';
import 'package:langas_driver/utils/api_response_model.dart';
import 'package:langas_driver/utils/failure_models.dart';

class VehicleRepository {
  final DioClient _dioClient;

  VehicleRepository(this._dioClient);

  Future<Either<Failure, ApiResponse<Vehicle>>> createVehicle(
      String driverId, CreateVehicleRequest request) async {
    try {
      final formData = await request.toFormData();
      final response = await _dioClient.dio.post(
        ApiConstants.driverVehicles(driverId),
        data: formData,
        options: Options(
          contentType: 'multipart/form-data',
        ),
      );
      return Right(ApiResponse<Vehicle>.fromJson(
        response.data,
        (dataJson) => Vehicle.fromJson(dataJson),
      ));
    } catch (e) {
      return Left(_dioClient.handleError(e));
    }
  }

  Future<Either<Failure, ApiResponse<List<Vehicle>>>> getDriverVehicles(
      String driverId) async {
    try {
      final response = await _dioClient.dio.get(
        ApiConstants.driverVehicles(driverId),
      );
      return Right(ApiResponse<List<Vehicle>>.fromJson(
        response.data,
        (dataJson) {
          if (dataJson is List) {
            return dataJson
                .map((vehicleJson) =>
                    Vehicle.fromJson(vehicleJson as Map<String, dynamic>))
                .toList();
          } else {
            return [];
          }
        },
      ));
    } catch (e) {
      return Left(_dioClient.handleError(e));
    }
  }

  Future<Either<Failure, ApiResponse<Vehicle>>> getVehicleDetails(
      String driverId, String vehicleId) async {
    try {
      final response = await _dioClient.dio.get(
        ApiConstants.specificVehicle(driverId, vehicleId),
      );
      return Right(ApiResponse<Vehicle>.fromJson(
        response.data,
        (dataJson) => Vehicle.fromJson(dataJson),
      ));
    } catch (e) {
      return Left(_dioClient.handleError(e));
    }
  }

  Future<Either<Failure, ApiResponse<String>>> switchActiveVehicle(
      String driverId, String vehicleId) async {
    try {
      final response = await _dioClient.dio.post(
        ApiConstants.switchVehicle(driverId, vehicleId),
      );
      return Right(ApiResponse<String>.fromJsonSimpleData(response.data));
    } catch (e) {
      return Left(_dioClient.handleError(e));
    }
  }

  Future<Either<Failure, ApiResponse<String>>> deleteVehicle(
      String driverId, String vehicleId) async {
    try {
      final response = await _dioClient.dio.delete(
        ApiConstants.specificVehicle(driverId, vehicleId),
      );
      return Right(ApiResponse<String>.fromJsonSimpleData(response.data));
    } catch (e) {
      return Left(_dioClient.handleError(e));
    }
  }
}
