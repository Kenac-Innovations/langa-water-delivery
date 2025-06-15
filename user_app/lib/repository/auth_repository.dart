import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:langas_user/dto/auth_dto.dart';
import 'package:langas_user/models/auth_response_model.dart';
import 'package:langas_user/models/security_question_model.dart';
import 'package:langas_user/services/dio_client.dart';
import 'package:langas_user/services/secure_storage.dart';
import 'package:langas_user/util/api_constants.dart';
import 'package:langas_user/util/api_failure_models.dart';

class AuthRepository {
  final DioClient _dioClient;
  final SecureStorageService _storageService;

  AuthRepository({
    required DioClient dioClient,
    required SecureStorageService storageService,
  })  : _dioClient = dioClient,
        _storageService = storageService;

  Future<Either<Failure, String>> requestOtp(RequestOtpDto dto) async {
    try {
      final response = await _dioClient.dio
          .post(ApiConstants.requestOtp, data: dto.toJson());
      if (response.statusCode == 200) {
        return Right(
            response.data['data'] as String? ?? 'OTP sent successfully');
      } else {
        return Left(ServerFailure(
            message: 'Request failed with status: ${response.statusCode}'));
      }
    } catch (e) {
      return Left(_dioClient.handleError(e));
    }
  }

  Future<Either<Failure, bool>> validateOtp(ValidateOtpDto dto) async {
    try {
      final response = await _dioClient.dio
          .post(ApiConstants.validateOtp, data: dto.toJson());
      if (response.statusCode == 200) {
        return Right(response.data['data'] as bool? ?? false);
      } else {
        return Left(ServerFailure(
            message: 'Request failed with status: ${response.statusCode}'));
      }
    } catch (e) {
      return Left(_dioClient.handleError(e));
    }
  }

  Future<Either<Failure, List<SecurityQuestion>>>
      getRandomSecurityQuestions() async {
    try {
      final response =
          await _dioClient.dio.get(ApiConstants.getRandomSecurityQuestions);
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data['data'];
        final questions =
            data.map((q) => SecurityQuestion.fromJson(q)).toList();
        return Right(questions);
      } else {
        return Left(ServerFailure(
            message: 'Request failed with status: ${response.statusCode}'));
      }
    } catch (e) {
      return Left(_dioClient.handleError(e));
    }
  }

  Future<Either<Failure, AuthResult>> register(RegisterRequestDto dto) async {
    try {
      final response =
          await _dioClient.dio.post(ApiConstants.register, data: dto.toJson());
      if (response.statusCode == 200) {
        final authResult = AuthResult.fromJson(response.data['data']);
        await _storageService.saveAuthResult(authResult);
        return Right(authResult);
      } else {
        return Left(ServerFailure(
            message: 'Request failed with status: ${response.statusCode}'));
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
        final authResult = AuthResult.fromJson(response.data['data']);
        await _storageService.saveAuthResult(authResult);
        return Right(authResult);
      } else {
        return Left(ServerFailure(
            message: 'Request failed with status: ${response.statusCode}'));
      }
    } catch (e) {
      return Left(_dioClient.handleError(e));
    }
  }

  Future<Either<Failure, String>> requestPasswordResetOtp(
      PasswordResetRequestOtpDto dto) async {
    try {
      final response = await _dioClient.dio.post(
        ApiConstants.requestPasswordResetOtp,
        data: dto.toJson(),
        options: Options(responseType: ResponseType.plain),
      );
      if (response.statusCode == 200) {
        return Right(response.data.toString());
      } else {
        return Left(ServerFailure(
            message: 'Request failed with status: ${response.statusCode}'));
      }
    } catch (e) {
      return Left(_dioClient.handleError(e));
    }
  }

  Future<Either<Failure, VerifyPasswordResetOtpResponseDto>>
      verifyPasswordResetOtp(VerifyPasswordResetOtpDto dto) async {
    try {
      final response = await _dioClient.dio.post(
        ApiConstants.verifyPasswordResetOtp,
        data: dto.toJson(),
      );
      if (response.statusCode == 200) {
        final List<dynamic> responseData = response.data;
        final questions = responseData
            .map((q) => SecurityQuestion.fromJson(q as Map<String, dynamic>))
            .toList();

        final data =
            VerifyPasswordResetOtpResponseDto(securityQuestions: questions);
        return Right(data);
      } else {
        return Left(ServerFailure(
            message: 'Request failed with status: ${response.statusCode}'));
      }
    } catch (e) {
      return Left(_dioClient.handleError(e));
    }
  }

  Future<Either<Failure, String>> verifySecurityAnswers(
      VerifySecurityAnswersDto dto) async {
    try {
      final response = await _dioClient.dio.post(
        ApiConstants.verifySecurityAnswers,
        data: dto.toJson(),
        options: Options(responseType: ResponseType.plain),
      );
      if (response.statusCode == 200) {
        return Right(response.data.toString());
      } else {
        return Left(ServerFailure(
            message: 'Request failed with status: ${response.statusCode}'));
      }
    } catch (e) {
      return Left(_dioClient.handleError(e));
    }
  }

  Future<Either<Failure, String>> resetPasswordWithToken(
      ResetPasswordWithTokenDto dto) async {
    try {
      final response = await _dioClient.dio.post(
          ApiConstants.resetPasswordWithToken,
          data: dto.toJson(),
          options: Options(responseType: ResponseType.plain));
      if (response.statusCode == 200) {
        return Right(response.data.toString());
      } else {
        return Left(ServerFailure(
            message: 'Request failed with status: ${response.statusCode}'));
      }
    } catch (e) {
      return Left(_dioClient.handleError(e));
    }
  }

  Future<void> logout() async {
    await _storageService.deleteAllData();
  }
}
