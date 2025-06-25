import 'package:dartz/dartz.dart';
import 'package:langas_user/dto/payment_card_dto.dart';
import 'package:langas_user/models/payment_card_model.dart';
import 'package:langas_user/services/dio_client.dart';
import 'package:langas_user/util/api_constants.dart';
import 'package:langas_user/util/api_failure_models.dart';

class PaymentCardRepository {
  final DioClient _dioClient;

  PaymentCardRepository({required DioClient dioClient}) : _dioClient = dioClient;

  Future<Either<Failure, String>> createPaymentCard(
      CreatePaymentCardRequestDto dto) async {
    try {
      final response = await _dioClient.dio
          .post(ApiConstants.createPaymentCard, data: dto.toJson());
      if (response.statusCode == 200) {
        return Right(response.data['data'] as String);
      } else {
        return Left(ServerFailure(message: 'Failed to create payment card'));
      }
    } catch (e) {
      return Left(_dioClient.handleError(e));
    }
  }

  Future<Either<Failure, String>> setDefaultCard(
      int clientId, int cardId) async {
    try {
      final response = await _dioClient.dio.put(
        ApiConstants.setDefaultPaymentCard,
        queryParameters: {'clientId': clientId, 'cardId': cardId},
      );
      if (response.statusCode == 200) {
        return Right(response.data['data'] as String);
      } else {
        return Left(ServerFailure(message: 'Failed to set default card'));
      }
    } catch (e) {
      return Left(_dioClient.handleError(e));
    }
  }

  Future<Either<Failure, String>> updatePaymentCard(
      int cardId, UpdatePaymentCardRequestDto dto) async {
    try {
      final response = await _dioClient.dio.put(
        ApiConstants.updatePaymentCard(cardId),
        data: dto.toJson(),
      );
      if (response.statusCode == 200) {
        return Right(response.data['data'] as String);
      } else {
        return Left(ServerFailure(message: 'Failed to update payment card'));
      }
    } catch (e) {
      return Left(_dioClient.handleError(e));
    }
  }

  Future<Either<Failure, List<PaymentCard>>> getClientCards(
      int clientId) async {
    try {
      final response =
          await _dioClient.dio.get(ApiConstants.getClientPaymentCards(clientId));
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data['data'];
        final cards = data
            .map((cardJson) =>
                PaymentCardResponseDto.fromJson(cardJson).toDomain())
            .toList();
        return Right(cards);
      } else {
        return Left(ServerFailure(message: 'Failed to fetch client cards'));
      }
    } catch (e) {
      return Left(_dioClient.handleError(e));
    }
  }

  Future<Either<Failure, String>> deletePaymentCard(int cardId) async {
    try {
      final response =
          await _dioClient.dio.delete(ApiConstants.deletePaymentCard(cardId));
      if (response.statusCode == 200) {
        return Right(response.data['data'] as String);
      } else {
        return Left(ServerFailure(message: 'Failed to delete payment card'));
      }
    } catch (e) {
      return Left(_dioClient.handleError(e));
    }
  }
}