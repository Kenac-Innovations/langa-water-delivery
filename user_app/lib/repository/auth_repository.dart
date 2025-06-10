import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:langas_user/dto/auth_dto.dart';
import 'package:langas_user/dto/fcm_dto.dart';
import 'package:langas_user/models/auth_response_model.dart';
import 'package:langas_user/models/user_model.dart';
import 'package:langas_user/services/dio_client.dart';
import 'package:langas_user/services/secure_storage.dart';
import 'package:langas_user/util/api_constants.dart';
import 'package:langas_user/util/api_failure_models.dart';

class AuthRepository {
  final DioClient _dioClient;
  final SecureStorageService _storageService;

  AuthRepository(
      {required DioClient dioClient,
      required SecureStorageService storageService})
      : _dioClient = dioClient,
        _storageService = storageService;

  Future<Either<Failure, RegisterResponseDataDto>> register(
      RegisterRequestDto requestDto) async {
    try {
      final response = await _dioClient.dio.post(
        ApiConstants.register,
        data: requestDto.toJson(),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final responseData = response.data as Map<String, dynamic>?;
        if (responseData != null &&
            responseData['success'] == true &&
            responseData['data'] != null) {
          final dataMap = responseData['data'] as Map<String, dynamic>;
          final registerData = RegisterResponseDataDto.fromJson(dataMap);
          return Right(registerData);
        } else {
          return Left(ServerFailure(
              message: responseData?['message'] ??
                  'Registration failed: Invalid response data.',
              statusCode: response.statusCode));
        }
      } else {
        return Left(ServerFailure(
          message: response.data?['message'] ??
              'Registration failed with status code ${response.statusCode}',
          statusCode: response.statusCode,
        ));
      }
    } catch (e) {
      return Left(_dioClient.handleError(e));
    }
  }

  Future<Either<Failure, String>> verifyAccount(
      VerifyAccountRequestDto requestDto) async {
    try {
      final response = await _dioClient.dio.post(
        ApiConstants.verifyAccount,
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

  Future<Either<Failure, AuthResult>> login(LoginRequestDto requestDto) async {
    try {
      final response = await _dioClient.dio.post(
        ApiConstants.login,
        data: requestDto.toJson(),
      );

      if (response.statusCode == 200) {
        final responseData = response.data as Map<String, dynamic>?;
        if (responseData != null &&
            responseData['success'] == true &&
            responseData['data'] != null) {
          final dataMap = responseData['data'] as Map<String, dynamic>;
          final authResult = AuthResult.fromJson(dataMap);

          await _storageService.saveAccessToken(authResult.accessToken);
          await _storageService.saveRefreshToken(authResult.refreshToken);

          return Right(authResult);
        } else {
          return Left(AuthFailure(
              message: responseData?['message'] ??
                  'Login failed: Invalid response data.',
              statusCode: response.statusCode));
        }
      } else {
        return Left(AuthFailure(
          message: response.data?['message'] ??
              'Login failed with status code ${response.statusCode}',
          statusCode: response.statusCode,
        ));
      }
    } catch (e) {
      return Left(_dioClient.handleError(e));
    }
  }

  Future<Either<Failure, String>> requestPasswordLink(String loginId) async {
    try {
      final response = await _dioClient.dio.get(
        ApiConstants.requestPasswordLink,
        queryParameters: {'loginId': loginId},
      );

      if (response.statusCode == 200) {
        final responseData = response.data as Map<String, dynamic>?;
        if (responseData != null && responseData['success'] == true) {
          final message = responseData['message'] as String? ??
              responseData['data'] as String? ??
              'Password reset link sent successfully.';
          return Right(message);
        } else {
          return Left(ServerFailure(
              message: responseData?['message'] ??
                  'Failed to request password reset link: Invalid response.',
              statusCode: response.statusCode));
        }
      } else {
        return Left(ServerFailure(
          message: response.data?['message'] ??
              'Request failed with status code ${response.statusCode}',
          statusCode: response.statusCode,
        ));
      }
    } catch (e) {
      return Left(_dioClient.handleError(e));
    }
  }

  Future<Either<Failure, String>> resetPassword(
      ResetPasswordRequestDto requestDto) async {
    try {
      final response = await _dioClient.dio.put(
        ApiConstants.resetPassword,
        data: requestDto.toJson(),
      );

      if (response.statusCode == 200) {
        final responseData = response.data as Map<String, dynamic>?;
        if (responseData != null && responseData['success'] == true) {
          final message = responseData['message'] as String? ??
              'Password reset successful.';
          return Right(message);
        } else {
          return Left(ServerFailure(
              message: responseData?['message'] ??
                  'Password reset failed: Invalid response.',
              statusCode: response.statusCode));
        }
      } else {
        return Left(ServerFailure(
          message: response.data?['message'] ??
              'Password reset failed with status code ${response.statusCode}',
          statusCode: response.statusCode,
        ));
      }
    } catch (e) {
      return Left(_dioClient.handleError(e));
    }
  }

  Future<Either<Failure, bool>> checkAuthenticationStatus() async {
    final User? storedUser = await _storageService.getUserDetails();
    if (storedUser == null) {
      return const Left(AuthFailure(
          message: 'User details not found for auth check.', statusCode: null));
    }
    final String clientId = storedUser.userId.toString();

    try {
      await _dioClient.dio.get(
        ApiConstants.clientDeliveries(clientId),
        queryParameters: {'pageSize': 1},
      );
      return const Right(true);
    } catch (e) {
      final failure = _dioClient.handleError(e);
      return Left(failure);
    }
  }

  Future<void> logout() async {
    await _storageService.deleteAllData();
  }

  Future<String?> getAccessToken() async {
    return await _storageService.getAccessToken();
  }

  Future<Either<Failure, FCMDeviceDataDto>> registerDeviceToken({
    required String userId,
    required FCMDeviceRegistrationRequestDto requestDto,
  }) async {
    try {
      final response = await _dioClient.dio.post(
        ApiConstants.registerDeviceToken(userId),
        data: requestDto.toJson(),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final responseData = response.data as Map<String, dynamic>?;
        if (responseData != null &&
            responseData['success'] == true &&
            responseData['data'] != null) {
          final dataMap = responseData['data'] as Map<String, dynamic>;
          final deviceData = FCMDeviceDataDto.fromJson(dataMap);
          return Right(deviceData);
        } else {
          return Left(ServerFailure(
              message: responseData?['message'] ??
                  'Device token registration failed: Invalid response data.',
              statusCode: response.statusCode));
        }
      } else {
        return Left(ServerFailure(
          message: response.data?['message'] ??
              'Device token registration failed with status code ${response.statusCode}',
          statusCode: response.statusCode,
        ));
      }
    } catch (e) {
      return Left(_dioClient.handleError(e));
    }
  }
}
