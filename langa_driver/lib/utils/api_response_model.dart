import 'package:flutter/foundation.dart' show immutable;

@immutable
class ApiResponse<T> {
  final bool success;
  final String message;
  final T? data;

  const ApiResponse({
    required this.success,
    required this.message,
    this.data,
  });

  factory ApiResponse.fromJson(
      Map<String, dynamic> json, T Function(dynamic)? fromJsonT) {
    return ApiResponse<T>(
      success: json['success'] as bool? ?? false,
      message: json['message'] as String? ?? 'Unknown error',
      data: json['data'] != null && fromJsonT != null
          ? fromJsonT(json['data'])
          : null,
    );
  }

  factory ApiResponse.fromJsonSimpleData(Map<String, dynamic> json) {
    return ApiResponse<T>(
      success: json['success'] as bool? ?? false,
      message: json['message'] as String? ?? 'Unknown error',
      data: json['data'] as T?,
    );
  }

  factory ApiResponse.fromJsonNoData(Map<String, dynamic> json) {
    return ApiResponse<T>(
      success: json['success'] as bool? ?? false,
      message: json['message'] as String? ?? 'Unknown error',
      data: null,
    );
  }
}
