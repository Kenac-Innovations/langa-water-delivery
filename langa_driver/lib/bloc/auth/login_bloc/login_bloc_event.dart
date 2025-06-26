import 'package:equatable/equatable.dart';
import 'package:langas_driver/dto/auth_dto.dart';

abstract class DriverLoginEvent extends Equatable {
  const DriverLoginEvent();
  @override
  List<Object?> get props => [];
}

class LoginSubmitted extends DriverLoginEvent {
  final LoginRequest request;
  const LoginSubmitted({required this.request});
  @override
  List<Object?> get props => [request];
}
