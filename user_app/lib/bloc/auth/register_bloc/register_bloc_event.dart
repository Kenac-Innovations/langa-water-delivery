import 'package:equatable/equatable.dart';
import 'package:langas_user/dto/auth_dto.dart';

abstract class RegisterEvent extends Equatable {
  const RegisterEvent();
  @override
  List<Object> get props => [];
}

class RegisterOtpRequested extends RegisterEvent {
  final RequestOtpDto dto;
  const RegisterOtpRequested({required this.dto});
  @override
  List<Object> get props => [dto];
}

class RegisterOtpValidated extends RegisterEvent {
  final ValidateOtpDto dto;
  const RegisterOtpValidated({required this.dto});
  @override
  List<Object> get props => [dto];
}

class RegisterSubmitted extends RegisterEvent {
  final RegisterRequestDto dto;
  const RegisterSubmitted({required this.dto});
  @override
  List<Object> get props => [dto];
}
