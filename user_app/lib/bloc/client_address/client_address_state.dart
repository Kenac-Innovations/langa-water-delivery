import 'package:equatable/equatable.dart';
import 'package:langas_user/models/client_address_model.dart';
import 'package:langas_user/util/api_failure_models.dart';

abstract class ClientAddressState extends Equatable {
  const ClientAddressState();
  @override
  List<Object> get props => [];
}

class ClientAddressInitial extends ClientAddressState {}

class ClientAddressLoading extends ClientAddressState {}

class ClientAddressOperationSuccess extends ClientAddressState {
  final String message;
  const ClientAddressOperationSuccess(this.message);
  @override
  List<Object> get props => [message];
}

class ClientAddressLoadSuccess extends ClientAddressState {
  final List<ClientAddress> addresses;
  const ClientAddressLoadSuccess(this.addresses);
  @override
  List<Object> get props => [addresses];
}

class ClientAddressFailure extends ClientAddressState {
  final Failure failure;
  const ClientAddressFailure(this.failure);
  @override
  List<Object> get props => [failure];
}
