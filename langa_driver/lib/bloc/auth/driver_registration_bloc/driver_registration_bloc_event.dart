import 'package:equatable/equatable.dart';
import 'package:langas_driver/dto/auth_dto.dart';

abstract class DriverRegistrationEvent extends Equatable {
  const DriverRegistrationEvent();
  @override
  List<Object?> get props => [];
}

class RegisterDriverSubmitted extends DriverRegistrationEvent {
  final DriverRegistrationRequest request;
  const RegisterDriverSubmitted({required this.request});
  @override
  List<Object?> get props => [request];
}
