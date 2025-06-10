import 'package:equatable/equatable.dart';

abstract class Failure extends Equatable {
  final String message;
  final int? statusCode;

  const Failure({required this.message, this.statusCode});

  @override
  List<Object?> get props => [message, statusCode];
}

class ServerFailure extends Failure {
  const ServerFailure({required super.message, super.statusCode});
}

class ConnectionFailure extends Failure {
  const ConnectionFailure({required super.message}) : super(statusCode: null);
}

class AuthFailure extends Failure {
  const AuthFailure({required super.message, super.statusCode});
}

class ValidationFailure extends Failure {
  final Map<String, dynamic>? errors;

  const ValidationFailure({
    required super.message,
    super.statusCode = 422,
    this.errors,
  });

  @override
  List<Object?> get props => [...super.props, errors];
}

class UnknownFailure extends Failure {
  const UnknownFailure({required super.message}) : super(statusCode: null);
}