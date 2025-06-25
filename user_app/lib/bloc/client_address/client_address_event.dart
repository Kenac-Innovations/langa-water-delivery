import 'package:equatable/equatable.dart';
import 'package:langas_user/dto/client_address_dto.dart';

abstract class ClientAddressEvent extends Equatable {
  const ClientAddressEvent();
  @override
  List<Object> get props => [];
}

class CreateClientAddress extends ClientAddressEvent {
  final CreateClientAddressDto dto;
  const CreateClientAddress(this.dto);
  @override
  List<Object> get props => [dto];
}

class FetchClientAddresses extends ClientAddressEvent {
  final int clientId;
  const FetchClientAddresses(this.clientId);
  @override
  List<Object> get props => [clientId];
}

class UpdateClientAddress extends ClientAddressEvent {
  final int addressId;
  final UpdateClientAddressDto dto;
  const UpdateClientAddress(this.addressId, this.dto);
  @override
  List<Object> get props => [addressId, dto];
}

class DeleteClientAddress extends ClientAddressEvent {
  final int addressId;
  const DeleteClientAddress(this.addressId);
  @override
  List<Object> get props => [addressId];
}

class SetDefaultClientAddress extends ClientAddressEvent {
  final int clientId;
  final int addressId;
  const SetDefaultClientAddress(this.clientId, this.addressId);
  @override
  List<Object> get props => [clientId, addressId];
}
