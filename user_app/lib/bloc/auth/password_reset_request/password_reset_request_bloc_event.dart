import 'package:equatable/equatable.dart';

abstract class PasswordResetRequestEvent extends Equatable {
  const PasswordResetRequestEvent();

  @override
  List<Object> get props => [];
}

class PasswordResetLinkRequested extends PasswordResetRequestEvent {
  final String loginId;

  const PasswordResetLinkRequested({required this.loginId});

  @override
  List<Object> get props => [loginId];
}
