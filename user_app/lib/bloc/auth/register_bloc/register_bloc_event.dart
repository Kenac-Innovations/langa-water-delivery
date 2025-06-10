import 'package:equatable/equatable.dart';
import 'package:langas_user/dto/auth_dto.dart';

abstract class RegisterEvent extends Equatable {
  const RegisterEvent();

  @override
  List<Object> get props => [];
}

class RegisterSubmitted extends RegisterEvent {
  final RegisterRequestDto registerRequestDto;

  const RegisterSubmitted({required this.registerRequestDto});

  @override
  List<Object> get props => [registerRequestDto];
}
