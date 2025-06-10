import 'package:equatable/equatable.dart';
import 'package:langas_user/util/api_failure_models.dart';

abstract class PasswordResetRequestState extends Equatable {
  const PasswordResetRequestState();

  @override
  List<Object> get props => [];
}

class PasswordResetRequestInitial extends PasswordResetRequestState {}

class PasswordResetRequestLoading extends PasswordResetRequestState {}

class PasswordResetRequestSuccess extends PasswordResetRequestState {
  final String message;

  const PasswordResetRequestSuccess({required this.message});

  @override
  List<Object> get props => [message];
}

class PasswordResetRequestFailure extends PasswordResetRequestState {
  final Failure failure;

  const PasswordResetRequestFailure({required this.failure});

  @override
  List<Object> get props => [failure];
}
