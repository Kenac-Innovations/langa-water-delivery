import 'package:equatable/equatable.dart';
import 'package:langas_driver/utils/failure_models.dart';

abstract class PasswordResetState extends Equatable {
  const PasswordResetState();
  @override
  List<Object?> get props => [];
}

class PasswordResetInitial extends PasswordResetState {}

class PasswordResetLoading extends PasswordResetState {}

class PasswordResetLinkSent extends PasswordResetState {}

class PasswordResetSuccess extends PasswordResetState {}

class PasswordResetFailure extends PasswordResetState {
  final Failure failure;
  const PasswordResetFailure({required this.failure});
  @override
  List<Object?> get props => [failure];
}
