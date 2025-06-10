import 'package:equatable/equatable.dart';
import 'package:langas_user/dto/auth_dto.dart';

abstract class LoginEvent extends Equatable {
  const LoginEvent();

  @override
  List<Object> get props => [];
}

class LoginButtonPressed extends LoginEvent {
  final LoginRequestDto loginRequestDto;

  const LoginButtonPressed({required this.loginRequestDto});

  @override
  List<Object> get props => [loginRequestDto];
}
