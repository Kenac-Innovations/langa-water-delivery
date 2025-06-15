import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:langas_user/services/secure_storage.dart';
import 'package:langas_user/util/api_constants.dart';
import 'package:langas_user/util/api_failure_models.dart';
import 'dart:convert';

class _AuthInterceptor extends Interceptor {
  final SecureStorageService _storageService;
  _AuthInterceptor(this._storageService);

  @override
  void onRequest(
      RequestOptions options, RequestInterceptorHandler handler) async {
    final excludedPaths = [
      ApiConstants.login,
      ApiConstants.register,
      ApiConstants.requestOtp,
      ApiConstants.validateOtp,
      ApiConstants.getRandomSecurityQuestions,
      ApiConstants.requestPasswordResetOtp,
      ApiConstants.verifyPasswordResetOtp,
      ApiConstants.verifySecurityAnswers,
      ApiConstants.resetPasswordWithToken,
    ];

    if (!excludedPaths.contains(options.path)) {
      final String? token = await _storageService.getAccessToken();
      if (token != null && token.isNotEmpty) {
        options.headers['Authorization'] = 'Bearer $token';
      }
    }
    super.onRequest(options, handler);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    if (err.response?.statusCode == 401) {
      await _storageService.deleteAccessToken();
      debugPrint("_AuthInterceptor: Unauthorized error (401), tokens cleared.");
    }
    super.onError(err, handler);
  }
}

class DioClient {
  final String baseUrl;
  final Dio _dio;
  final SecureStorageService _storageService;

  DioClient(
      {required this.baseUrl, required SecureStorageService storageService})
      : _storageService = storageService,
        _dio = Dio(
          BaseOptions(
            baseUrl: baseUrl,
            connectTimeout: const Duration(seconds: 15),
            receiveTimeout: const Duration(seconds: 15),
            contentType: 'application/json',
            headers: {'Accept': 'application/json'},
          ),
        ) {
    _dio.interceptors.add(LogInterceptor(
      requestBody: true,
      responseBody: true,
      logPrint: (object) => debugPrint(object.toString()),
    ));
    _dio.interceptors.add(_AuthInterceptor(_storageService));
  }

  Dio get dio => _dio;

  Failure handleError(dynamic error) {
    if (error is DioException) {
      if (error.response != null) {
        final statusCode = error.response?.statusCode;
        var errorData = error.response?.data;
        String errorMessage = 'An unexpected error occurred.';

        // --- Start of new, more robust parsing logic ---

        Map<String, dynamic>? dataMap;
        if (errorData is String) {
          try {
            dataMap = json.decode(errorData) as Map<String, dynamic>;
          } catch (_) {
            errorMessage = errorData;
            dataMap = null;
          }
        } else if (errorData is Map<String, dynamic>) {
          dataMap = errorData;
        }

        if (dataMap != null) {
          // Check for the nested message structure first
          if (dataMap['data'] is Map && dataMap['data']['message'] != null) {
            errorMessage = dataMap['data']['message'];
            // Clean the prefix from the nested message
            const prefix = "An unexpected error occurred: ";
            if (errorMessage.startsWith(prefix)) {
              errorMessage = errorMessage.substring(prefix.length);
            }
          }
          // Fallback to the top-level message if the nested one isn't there
          else if (dataMap['message'] != null) {
            errorMessage = dataMap['message'];
          }
        }

        // --- End of new logic ---

        if (errorMessage == 'An unexpected error occurred.') {
          if (statusCode == 403) {
            errorMessage = 'Access Forbidden. You do not have permission.';
          } else if (statusCode == 401) {
            errorMessage = 'Unauthorized. Please log in again.';
          } else if (statusCode == 404) {
            errorMessage = 'Resource not found.';
          } else if (statusCode != null && statusCode >= 500) {
            errorMessage = 'Server error occurred. Please try again later.';
          }
        }

        switch (statusCode) {
          case 400:
            return _handleBadRequest(errorData, errorMessage);
          case 401:
          case 403:
            return AuthFailure(
              message: errorMessage,
              statusCode: statusCode,
            );
          case 422:
            return _handleValidationError(errorData);
          case 404:
          case 500:
          case 502:
          case 503:
            return ServerFailure(
              message: errorMessage,
              statusCode: statusCode,
            );
          default:
            if (statusCode != null) {
              return ServerFailure(
                message: errorMessage,
                statusCode: statusCode,
              );
            }
        }
      }
      return _handleNetworkError(error);
    }
    return UnknownFailure(message: error.toString());
  }

  ValidationFailure _handleValidationError(dynamic errorData) {
    Map<String, dynamic>? validationErrors;
    String message = 'Validation failed';

    if (errorData is Map<String, dynamic>) {
      if (errorData.containsKey('data') && errorData['data'] is Map) {
        final nestedData = errorData['data'] as Map<String, dynamic>;
        message = nestedData['message'] ?? errorData['message'] ?? message;
      } else {
        message = errorData['message'] ?? message;
      }

      if (errorData['errors'] is Map) {
        try {
          validationErrors = Map<String, dynamic>.from(errorData['errors']);
        } catch (_) {
          validationErrors = null;
        }
      }
    } else if (errorData is String && errorData.isNotEmpty) {
      message = errorData;
    }

    return ValidationFailure(
      message: message,
      statusCode: 422,
      errors: validationErrors,
    );
  }

  Failure _handleBadRequest(dynamic errorData, String extractedMessage) {
    if (errorData is Map<String, dynamic> && errorData.containsKey('errors')) {
      return _handleValidationError(errorData);
    }

    return AuthFailure(
      message: extractedMessage,
      statusCode: 400,
    );
  }

  ConnectionFailure _handleNetworkError(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return const ConnectionFailure(
            message:
                'Connection timeout. Please check your internet connection.');
      case DioExceptionType.connectionError:
        return const ConnectionFailure(
            message: 'Connection error. Please check your network.');
      case DioExceptionType.cancel:
        return const ConnectionFailure(message: 'Request was cancelled');
      case DioExceptionType.badResponse:
        return ConnectionFailure(
            message:
                'Received an invalid response from the server (Status: ${error.response?.statusCode}). Check network or server status.');
      case DioExceptionType.unknown:
      default:
        String detailedMessage =
            error.message ?? 'An unknown network error occurred';
        if (detailedMessage.toLowerCase().contains('socketexception') ||
            detailedMessage.toLowerCase().contains('host lookup')) {
          detailedMessage = 'Network error. Please check your connection.';
        } else if (detailedMessage.toLowerCase().contains('handshake error')) {
          detailedMessage =
              'Network security error. Please check connection or server certificate.';
        }
        return ConnectionFailure(message: detailedMessage);
    }
  }
}
