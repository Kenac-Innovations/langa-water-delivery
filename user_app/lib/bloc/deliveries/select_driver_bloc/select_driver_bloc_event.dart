import 'package:equatable/equatable.dart';
import 'package:langas_user/dto/delivery_dto.dart';

abstract class SelectDriverEvent extends Equatable {
  const SelectDriverEvent();
  @override
  List<Object> get props => [];
}

class SelectDriverSubmitted extends SelectDriverEvent {
  final String clientId;
  final SelectDriverRequestDto requestDto;
  const SelectDriverSubmitted(
      {required this.clientId, required this.requestDto});
  @override
  List<Object> get props => [clientId, requestDto];
}
