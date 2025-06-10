import 'package:equatable/equatable.dart';
import 'package:langas_user/dto/auth_dto.dart';

abstract class PasswordResetEvent extends Equatable {
  const PasswordResetEvent();

  @override
  List<Object> get props => [];
}

class PasswordResetSubmitted extends PasswordResetEvent {
  final ResetPasswordRequestDto resetPasswordRequestDto;

  const PasswordResetSubmitted({required this.resetPasswordRequestDto});

  @override
  List<Object> get props => [resetPasswordRequestDto];
}
