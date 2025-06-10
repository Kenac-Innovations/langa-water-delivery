import 'package:equatable/equatable.dart';
import 'package:langas_user/util/api_failure_models.dart';

abstract class PasswordResetState extends Equatable {
  const PasswordResetState();

  @override
  List<Object> get props => [];
}

class PasswordResetInitial extends PasswordResetState {}

class PasswordResetLoading extends PasswordResetState {}

class PasswordResetSuccess extends PasswordResetState {
  final String message;

  const PasswordResetSuccess({required this.message});

  @override
  List<Object> get props => [message];
}

class PasswordResetFailure extends PasswordResetState {
  final Failure failure;

  const PasswordResetFailure({required this.failure});

  @override
  List<Object> get props => [failure];
}
