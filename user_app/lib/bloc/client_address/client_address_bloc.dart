import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:langas_user/bloc/client_address/client_address_event.dart';
import 'package:langas_user/bloc/client_address/client_address_state.dart';
import 'package:langas_user/repository/client_address_repository.dart';

class ClientAddressBloc extends Bloc<ClientAddressEvent, ClientAddressState> {
  final ClientAddressRepository _clientAddressRepository;

  ClientAddressBloc({required ClientAddressRepository clientAddressRepository})
      : _clientAddressRepository = clientAddressRepository,
        super(ClientAddressInitial()) {
    on<CreateClientAddress>(_onCreateAddress);
    on<FetchClientAddresses>(_onFetchClientAddresses);
    on<UpdateClientAddress>(_onUpdateAddress);
    on<DeleteClientAddress>(_onDeleteAddress);
    on<SetDefaultClientAddress>(_onSetDefaultAddress);
  }

  Future<void> _onCreateAddress(
      CreateClientAddress event, Emitter<ClientAddressState> emit) async {
    emit(ClientAddressLoading());
    final result = await _clientAddressRepository.createAddress(event.dto);
    result.fold(
      (failure) => emit(ClientAddressFailure(failure)),
      (message) => emit(ClientAddressOperationSuccess(message)),
    );
  }

  Future<void> _onFetchClientAddresses(
      FetchClientAddresses event, Emitter<ClientAddressState> emit) async {
    emit(ClientAddressLoading());
    final result =
        await _clientAddressRepository.getClientAddresses(event.clientId);
    result.fold(
      (failure) => emit(ClientAddressFailure(failure)),
      (addresses) => emit(ClientAddressLoadSuccess(addresses)),
    );
  }

  Future<void> _onUpdateAddress(
      UpdateClientAddress event, Emitter<ClientAddressState> emit) async {
    emit(ClientAddressLoading());
    final result = await _clientAddressRepository.updateAddress(
        event.addressId, event.dto);
    result.fold(
      (failure) => emit(ClientAddressFailure(failure)),
      (message) => emit(ClientAddressOperationSuccess(message)),
    );
  }

  Future<void> _onDeleteAddress(
      DeleteClientAddress event, Emitter<ClientAddressState> emit) async {
    emit(ClientAddressLoading());
    final result =
        await _clientAddressRepository.deleteAddress(event.addressId);
    result.fold(
      (failure) => emit(ClientAddressFailure(failure)),
      (message) => emit(ClientAddressOperationSuccess(message)),
    );
  }

  Future<void> _onSetDefaultAddress(
      SetDefaultClientAddress event, Emitter<ClientAddressState> emit) async {
    emit(ClientAddressLoading());
    final result = await _clientAddressRepository.setDefaultAddress(
        event.clientId, event.addressId);
    result.fold(
      (failure) => emit(ClientAddressFailure(failure)),
      (message) => emit(ClientAddressOperationSuccess(message)),
    );
  }
}
