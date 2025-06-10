import 'package:dartz/dartz.dart';
import 'package:langas_user/models/driver_model.dart';
import 'package:langas_user/models/vehicle_model.dart';
import 'package:langas_user/services/dio_client.dart';
import 'package:langas_user/util/api_constants.dart';
import 'package:langas_user/util/api_failure_models.dart';

class DriverRepository {
  final DioClient _dioClient;

  DriverRepository({required DioClient dioClient}) : _dioClient = dioClient;

  Future<Either<Failure, List<Driver>>> getAvailableDrivers({
    required String deliveryId,
  }) async {
    try {
      final response = await _dioClient.dio.get(
        ApiConstants.availableDriversForDelivery(deliveryId),
      );

      if (response.statusCode == 200) {
        final responseData = response.data;
        if (responseData is List) {
          final List<Driver> drivers = responseData
              .map((driverJson) =>
                  Driver.fromJson(driverJson as Map<String, dynamic>))
              .toList();
          return Right(drivers);
        } else if (responseData is Map<String, dynamic> &&
            responseData.containsKey('data') &&
            responseData['data'] is List) {
          if (responseData.containsKey('success') &&
              responseData['success'] == false) {
            return Left(ServerFailure(
                message: responseData['message'] ??
                    'Failed to fetch available drivers: Server indicated failure.',
                statusCode: response.statusCode));
          }
          final List<dynamic> driversListJson = responseData['data'];
          final List<Driver> drivers = driversListJson
              .map((driverJson) =>
                  Driver.fromJson(driverJson as Map<String, dynamic>))
              .toList();
          return Right(drivers);
        } else {
          return Left(ServerFailure(
              message:
                  'Failed to fetch available drivers: Unexpected response format.',
              statusCode: response.statusCode));
        }
      } else {
        return Left(_dioClient
            .handleError(response.data ?? 'Failed to fetch available drivers'));
      }
    } catch (e) {
      return Left(_dioClient.handleError(e));
    }
  }
}
