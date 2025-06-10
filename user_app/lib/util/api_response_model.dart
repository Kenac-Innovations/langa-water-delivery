class ApiResponse<T> {
  final String status;
  final String? message;
  final T? data;

  ApiResponse({
    required this.status,
    this.message,
    this.data,
  });

  factory ApiResponse.fromJson(Map<String, dynamic> json, T Function(Map<String, dynamic>)? fromJsonT) {
    return ApiResponse(
      status: json['status'],
      message: json['message'],
      data: json['data'] != null && fromJsonT != null ? fromJsonT(json['data']) : null,
    );
  }
}