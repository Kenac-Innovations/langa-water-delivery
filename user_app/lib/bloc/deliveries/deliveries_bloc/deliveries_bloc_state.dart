import 'package:equatable/equatable.dart';
import 'package:langas_user/models/delivery_model.dart';
import 'package:langas_user/util/api_failure_models.dart';
import 'package:langas_user/util/api_pagenated_model.dart';

abstract class DeliveriesState extends Equatable {
  const DeliveriesState();
  @override
  List<Object> get props => [];
}

class DeliveriesInitial extends DeliveriesState {}

class DeliveriesLoading extends DeliveriesState {}

class DeliveriesSuccess extends DeliveriesState {
  final PaginatedResponse<Delivery> response;
  const DeliveriesSuccess({required this.response});
  @override
  List<Object> get props => [response];
}

class DeliveriesFailure extends DeliveriesState {
  final Failure failure;
  const DeliveriesFailure({required this.failure});
  @override
  List<Object> get props => [failure];
}
