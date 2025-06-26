import 'package:dartz/dartz.dart';
import 'package:langas_driver/dto/notification_dto.dart';
import 'package:langas_driver/models/notification_model.dart';
import 'package:langas_driver/services/dio_client.dart';
import 'package:langas_driver/utils/api_constants.dart';
import 'package:langas_driver/utils/api_response_model.dart';
import 'package:langas_driver/utils/failure_models.dart';

class NotificationRepository {
  final DioClient _dioClient;

  NotificationRepository(this._dioClient);

  Future<Either<Failure, ApiResponse<NotificationModel>>>
      updateNotificationStatus(UpdateNotificationStatusRequest request) async {
    try {
      final response = await _dioClient.dio.put(
        ApiConstants.updateNotificationStatus,
        data: request.toJson(),
      );
      return Right(ApiResponse<NotificationModel>.fromJson(
        response.data,
        (dataJson) => NotificationModel.fromJson(dataJson),
      ));
    } catch (e) {
      return Left(_dioClient.handleError(e));
    }
  }

  Future<Either<Failure, ApiResponse<String>>> markAllNotificationsAsRead(
      String userId) async {
    try {
      final response = await _dioClient.dio.put(
        ApiConstants.markAllNotificationsAsRead(userId),
      );
      return Right(ApiResponse<String>.fromJsonSimpleData(response.data));
    } catch (e) {
      return Left(_dioClient.handleError(e));
    }
  }

  Future<Either<Failure, ApiResponse<String>>> deleteNotification(
      String notificationId) async {
    try {
      final response = await _dioClient.dio.delete(
        ApiConstants.deleteNotificationById(notificationId),
      );
      return Right(ApiResponse<String>.fromJsonSimpleData(response.data));
    } catch (e) {
      return Left(_dioClient.handleError(e));
    }
  }

  Future<Either<Failure, ApiResponse<PaginatedNotifications>>>
      getUserNotifications({
    required String userId,
    int pageNumber = 1,
    int pageSize = 20,
  }) async {
    try {
      final response = await _dioClient.dio.get(
        ApiConstants.getUserNotifications(userId),
        queryParameters: {
          'pageNumber': pageNumber,
          'pageSize': pageSize,
        },
      );
      return Right(ApiResponse<PaginatedNotifications>.fromJson(
        response.data,
        (dataJson) => PaginatedNotifications.fromJson(dataJson),
      ));
    } catch (e) {
      return Left(_dioClient.handleError(e));
    }
  }

  Future<Either<Failure, ApiResponse<int>>> getUnreadNotificationCount(
      String userId) async {
    try {
      final response = await _dioClient.dio.get(
        ApiConstants.getUnreadNotificationCount(userId),
      );
      return Right(ApiResponse<int>.fromJsonSimpleData(response.data));
    } catch (e) {
      return Left(_dioClient.handleError(e));
    }
  }
}
