import 'package:dartz/dartz.dart';
import 'package:langas_user/dto/client_address_dto.dart';
import 'package:langas_user/models/client_address_model.dart';
import 'package:langas_user/services/dio_client.dart';
import 'package:langas_user/util/api_constants.dart';
import 'package:langas_user/util/api_failure_models.dart';

class ClientAddressRepository {
  final DioClient _dioClient;

  ClientAddressRepository({required DioClient dioClient})
      : _dioClient = dioClient;

  Future<Either<Failure, String>> createAddress(
      CreateClientAddressDto dto) async {
    try {
      final response = await _dioClient.dio
          .post(ApiConstants.createClientAddress, data: dto.toJson());
      if (response.statusCode == 200) {
        return Right(response.data['data'] as String);
      } else {
        return Left(ServerFailure(message: 'Failed to create address'));
      }
    } catch (e) {
      return Left(_dioClient.handleError(e));
    }
  }

  Future<Either<Failure, List<ClientAddress>>> getClientAddresses(
      int clientId) async {
    try {
      final response =
          await _dioClient.dio.get(ApiConstants.getClientAddresses(clientId));
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data['data'];
        final addresses = data
            .map((json) => ClientAddressResponseDto.fromJson(json).toDomain())
            .toList();
        return Right(addresses);
      } else {
        return Left(ServerFailure(message: 'Failed to fetch addresses'));
      }
    } catch (e) {
      return Left(_dioClient.handleError(e));
    }
  }

  Future<Either<Failure, String>> setDefaultAddress(
      int clientId, int addressId) async {
    try {
      final response = await _dioClient.dio.put(
        ApiConstants.setDefaultAddress,
        queryParameters: {'clientId': clientId, 'addressId': addressId},
      );
      if (response.statusCode == 200) {
        return Right(response.data['data'] as String);
      } else {
        return Left(ServerFailure(message: 'Failed to set default address'));
      }
    } catch (e) {
      return Left(_dioClient.handleError(e));
    }
  }

  Future<Either<Failure, String>> updateAddress(
      int addressId, UpdateClientAddressDto dto) async {
    try {
      final response = await _dioClient.dio.put(
        ApiConstants.updateClientAddress(addressId),
        data: dto.toJson(),
      );
      if (response.statusCode == 200) {
        return Right(response.data['data'] as String);
      } else {
        return Left(ServerFailure(message: 'Failed to update address'));
      }
    } catch (e) {
      return Left(_dioClient.handleError(e));
    }
  }

  Future<Either<Failure, String>> deleteAddress(int addressId) async {
    try {
      final response = await _dioClient.dio
          .delete(ApiConstants.deleteClientAddress(addressId));
      if (response.statusCode == 200) {
        return Right(response.data['data'] as String);
      } else {
        return Left(ServerFailure(message: 'Failed to delete address'));
      }
    } catch (e) {
      return Left(_dioClient.handleError(e));
    }
  }
}
