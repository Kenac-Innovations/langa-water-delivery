import 'package:equatable/equatable.dart';
import 'package:langas_user/dto/auth_dto.dart';

abstract class VerifyAccountEvent extends Equatable {
  const VerifyAccountEvent();

  @override
  List<Object> get props => [];
}

class VerifyAccountSubmitted extends VerifyAccountEvent {
  final VerifyAccountRequestDto verifyAccountRequestDto;

  const VerifyAccountSubmitted({required this.verifyAccountRequestDto});

  @override
  List<Object> get props => [verifyAccountRequestDto];
}
