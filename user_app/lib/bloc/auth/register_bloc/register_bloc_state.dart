import 'package:equatable/equatable.dart';
import 'package:langas_user/dto/auth_dto.dart';
import 'package:langas_user/util/api_failure_models.dart';

abstract class RegisterState extends Equatable {
  const RegisterState();

  @override
  List<Object> get props => [];
}

class RegisterInitial extends RegisterState {}

class RegisterLoading extends RegisterState {}

class RegisterSuccess extends RegisterState {
  final RegisterResponseDataDto registerResponseDataDto;

  const RegisterSuccess({required this.registerResponseDataDto});

  @override
  List<Object> get props => [registerResponseDataDto];
}

class RegisterFailure extends RegisterState {
  final Failure failure;

  const RegisterFailure({required this.failure});

  @override
  List<Object> get props => [failure];
}
