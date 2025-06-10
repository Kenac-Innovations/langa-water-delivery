import 'package:equatable/equatable.dart';
import 'package:langas_user/util/api_failure_models.dart';

abstract class CreatePaymentState extends Equatable {
  const CreatePaymentState();
  @override
  List<Object> get props => [];
}

class CreatePaymentInitial extends CreatePaymentState {}

class CreatePaymentLoading extends CreatePaymentState {}

class CreatePaymentSuccess extends CreatePaymentState {
  final String message;
  const CreatePaymentSuccess({required this.message});
  @override
  List<Object> get props => [message];
}

class CreatePaymentFailure extends CreatePaymentState {
  final Failure failure;
  const CreatePaymentFailure({required this.failure});
  @override
  List<Object> get props => [failure];
}
