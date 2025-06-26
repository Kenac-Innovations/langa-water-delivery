import 'dart:async';
import 'dart:ffi';
import 'dart:io';
import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:langas_driver/dto/auth_dto.dart';
import 'package:langas_driver/models/auth_models.dart';
import 'package:langas_driver/services/dio_client.dart';
import 'package:langas_driver/utils/api_constants.dart';
import 'package:langas_driver/utils/api_response_model.dart';
import 'package:langas_driver/utils/failure_models.dart';

class AuthRepository {
  final DioClient _dioClient;

  AuthRepository(this._dioClient);

  Future<Either<Failure, ApiResponse<DriverRegistrationResponseData>>>
      registerDriver(DriverRegistrationRequest request) async {
    try {
      final formData = await request.toFormData();
      print('now');
      print(formData.toString());
      print(request.toString());
      final response = await _dioClient.dio.post(
        ApiConstants.driverRegister,
        data: formData,
        options: Options(
          contentType: 'multipart/form-data',
          headers: {
            'Accept': 'application/json',
          },
        ),
      );

      return Right(ApiResponse<DriverRegistrationResponseData>.fromJson(
        response.data,
        (dataJson) => DriverRegistrationResponseData.fromJson(dataJson),
      ));
    } catch (e) {
      return Left(_dioClient.handleError(e));
    }
  }

  Future<Either<Failure, String>> verifyAccount(
      VerifyAccountRequestDto requestDto) async {
    try {
      final response = await _dioClient.dio.post(
        ApiConstants.driverVerifyAccount,
        data: requestDto.toJson(),
      );

      if (response.statusCode == 200) {
        final responseData = response.data as Map<String, dynamic>?;
        if (responseData != null &&
            responseData['success'] == true &&
            responseData['data'] != null) {
          final message = responseData['data'] as String? ??
              responseData['message'] as String? ??
              'Account verified successfully.';
          return Right(message);
        } else {
          return Left(ServerFailure(
              message: responseData?['message'] ??
                  'Verification failed: Invalid response data.',
              statusCode: response.statusCode));
        }
      } else {
        return Left(ServerFailure(
          message: response.data?['message'] ??
              'Verification failed with status code ${response.statusCode}',
          statusCode: response.statusCode,
        ));
      }
    } catch (e) {
      return Left(_dioClient.handleError(e));
    }
  }

  Future<Either<Failure, ApiResponse<AuthResponseData>>> login(
      LoginRequest request) async {
    try {
      final response = await _dioClient.dio.post(
        ApiConstants.driverLogin,
        data: request.toJson(),
      );
      return Right(ApiResponse<AuthResponseData>.fromJson(
        response.data,
        (dataJson) => AuthResponseData.fromJson(dataJson),
      ));
    } catch (e) {
      return Left(_dioClient.handleError(e));
    }
  }

  Future<Either<Failure, ApiResponse<String>>> requestPasswordLink(
      String loginId) async {
    try {
      final response = await _dioClient.dio.get(
        ApiConstants.requestPasswordLink(loginId),
      );
      return Right(ApiResponse<String>.fromJsonSimpleData(response.data));
    } catch (e) {
      return Left(_dioClient.handleError(e));
    }
  }

  Future<Either<Failure, ApiResponse<void>>> resetPassword(
      ResetPasswordRequest request) async {
    try {
      final response = await _dioClient.dio.put(
        ApiConstants.resetPassword,
        data: request.toJson(),
      );
      return Right(ApiResponse<void>.fromJsonNoData(response.data));
    } catch (e) {
      return Left(_dioClient.handleError(e));
    }
  }

  Future<Either<Failure, ApiResponse<DriverProfile>>> getDriverProfile(
      String driverId) async {
    try {
      final response = await _dioClient.dio.get(
        ApiConstants.driverProfile(driverId),
      );
      return Right(ApiResponse<DriverProfile>.fromJson(
        response.data,
        (dataJson) => DriverProfile.fromJson(dataJson),
      ));
    } catch (e) {
      return Left(_dioClient.handleError(e));
    }
  }

  Future<Either<Failure, ApiResponse<String>>> deleteDriverProfile(
      String driverId) async {
    try {
      final response = await _dioClient.dio.delete(
        ApiConstants.driverProfile(driverId),
      );
      return Right(ApiResponse<String>.fromJsonSimpleData(response.data));
    } catch (e) {
      return Left(_dioClient.handleError(e));
    }
  }

  Future<Either<Failure, ApiResponse<DriverProfile>>> updateWorkStatus(
      int driverId, bool status) async {
    try {
      final response = await _dioClient.dio.put(
        ApiConstants.driverUpdateWorkStatus(driverId),
        queryParameters: {'status': status},
      );

      // Handle the response data properly
      if (response.data is Map<String, dynamic>) {
        final responseData = response.data as Map<String, dynamic>;
        print(
            "=======> This is the response from update work status ${responseData}");
        return Right(ApiResponse<DriverProfile>.fromJson(
          response.data,
          (dataJson) => DriverProfile.fromJson(dataJson),
        ));
      } else {
        return Left(ServerFailure(message: 'Invalid response format'));
      }
    } catch (e) {
      print("========> Error on updating work status $e");
      return Left(_dioClient.handleError(e));
    }
  }
}
