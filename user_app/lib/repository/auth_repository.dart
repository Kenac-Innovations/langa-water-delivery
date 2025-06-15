import 'package:dartz/dartz.dart';
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
      return Right(response.data['data'] as String? ?? 'OTP sent successfully');
    } catch (e) {
      return Left(_dioClient.handleError(e));
    }
  }

  Future<Either<Failure, bool>> validateOtp(ValidateOtpDto dto) async {
    try {
      final response = await _dioClient.dio
          .post(ApiConstants.validateOtp, data: dto.toJson());
      return Right(response.data['data'] as bool? ?? false);
    } catch (e) {
      return Left(_dioClient.handleError(e));
    }
  }

  Future<Either<Failure, List<SecurityQuestion>>>
      getRandomSecurityQuestions() async {
    try {
      final response =
          await _dioClient.dio.get(ApiConstants.getRandomSecurityQuestions);
      final List<dynamic> data = response.data['data'];
      final questions = data.map((q) => SecurityQuestion.fromJson(q)).toList();
      return Right(questions);
    } catch (e) {
      return Left(_dioClient.handleError(e));
    }
  }

  Future<Either<Failure, AuthResult>> register(RegisterRequestDto dto) async {
    try {
      final response =
          await _dioClient.dio.post(ApiConstants.register, data: dto.toJson());
      final authResult = AuthResult.fromJson(response.data['data']);
      await _storageService.saveAuthResult(authResult);
      return Right(authResult);
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
      final authResult = AuthResult.fromJson(response.data['data']);
      await _storageService.saveAuthResult(authResult);
      return Right(authResult);
    } catch (e) {
      return Left(_dioClient.handleError(e));
    }
  }

  Future<Either<Failure, String>> requestPasswordResetOtp(
      PasswordResetRequestOtpDto dto) async {
    try {
      final response = await _dioClient.dio
          .post(ApiConstants.requestPasswordResetOtp, data: dto.toJson());
      return Right(response.data['message'] as String? ?? 'OTP sent');
    } catch (e) {
      return Left(_dioClient.handleError(e));
    }
  }

  Future<Either<Failure, VerifyPasswordResetOtpResponseDto>>
      verifyPasswordResetOtp(VerifyPasswordResetOtpDto dto) async {
    try {
      final response = await _dioClient.dio
          .post(ApiConstants.verifyPasswordResetOtp, data: dto.toJson());
      final data =
          VerifyPasswordResetOtpResponseDto.fromJson(response.data['data']);
      return Right(data);
    } catch (e) {
      return Left(_dioClient.handleError(e));
    }
  }

  Future<Either<Failure, String>> verifySecurityAnswers(
      VerifySecurityAnswersDto dto) async {
    try {
      final response = await _dioClient.dio
          .post(ApiConstants.verifySecurityAnswers, data: dto.toJson());
  
      return Right(response.data['data']['token'] as String);
    } catch (e) {
      return Left(_dioClient.handleError(e));
    }
  }

  Future<Either<Failure, String>> resetPasswordWithToken(
      ResetPasswordWithTokenDto dto) async {
    try {
      final response = await _dioClient.dio
          .post(ApiConstants.resetPasswordWithToken, data: dto.toJson());
      return Right(
          response.data['message'] as String? ?? 'Password reset successfully');
    } catch (e) {
      return Left(_dioClient.handleError(e));
    }
  }

  Future<void> logout() async {
    await _storageService.deleteAllData();
  }
}
