import 'package:dartz/dartz.dart';
import 'package:langas_user/models/promotion_model.dart';
import 'package:langas_user/services/dio_client.dart';
import 'package:langas_user/util/api_constants.dart';
import 'package:langas_user/util/api_failure_models.dart';

class PromotionsRepository {
  final DioClient _dioClient;

  PromotionsRepository({required DioClient dioClient}) : _dioClient = dioClient;

  Future<Either<Failure, List<Promotion>>> getAllPromotions() async {
    try {
      final response = await _dioClient.dio.get(ApiConstants.promotions);
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data['data'];
        final promotions = data.map((p) => Promotion.fromJson(p)).toList();
        return Right(promotions);
      } else {
        return Left(ServerFailure(
            message: 'Failed to load promotions: ${response.statusCode}'));
      }
    } catch (e) {
      return Left(_dioClient.handleError(e));
    }
  }

  Future<Either<Failure, Promotion>> getPromotionById(int id) async {
    try {
      final response = await _dioClient.dio.get(ApiConstants.promotionById(id));
      if (response.statusCode == 200) {
        final promotion = Promotion.fromJson(response.data['data']);
        return Right(promotion);
      } else {
        return Left(ServerFailure(
            message: 'Failed to load promotion: ${response.statusCode}'));
      }
    } catch (e) {
      return Left(_dioClient.handleError(e));
    }
  }
}
