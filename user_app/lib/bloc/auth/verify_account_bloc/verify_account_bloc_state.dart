import 'package:equatable/equatable.dart';
import 'package:langas_user/models/auth_response_model.dart';
import 'package:langas_user/util/api_failure_models.dart';

abstract class VerifyAccountState extends Equatable {
  const VerifyAccountState();

  @override
  List<Object> get props => [];
}

class VerifyAccountInitial extends VerifyAccountState {}

class VerifyAccountLoading extends VerifyAccountState {}

class VerifyAccountSuccess extends VerifyAccountState {
  final String message;

  const VerifyAccountSuccess({required this.message});

  @override
  List<Object> get props => [message];
}

class VerifyAccountFailure extends VerifyAccountState {
  final Failure failure;

  const VerifyAccountFailure({required this.failure});

  @override
  List<Object> get props => [failure];
}
