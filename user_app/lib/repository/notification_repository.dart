import 'package:dartz/dartz.dart';
import 'package:langas_user/dto/notifications_dto.dart';
import 'package:langas_user/models/notifications_model.dart';
import 'package:langas_user/services/dio_client.dart';
import 'package:langas_user/util/api_constants.dart';
import 'package:langas_user/util/api_failure_models.dart';
import 'package:langas_user/util/api_pagenated_model.dart';

class NotificationRepository {
  final DioClient _dioClient;

  NotificationRepository({required DioClient dioClient})
      : _dioClient = dioClient;

  Future<Either<Failure, NotificationModel>> updateNotificationStatus(
      UpdateNotificationStatusRequestDto requestDto) async {
    try {
      final response = await _dioClient.dio.put(
        ApiConstants.updateNotificationStatus,
        data: requestDto.toJson(),
      );
      final responseData = response.data as Map<String, dynamic>;
      if (responseData['success'] == true && responseData['data'] != null) {
        final notificationDto = NotificationDto.fromJson(responseData['data']);
        return Right(notificationDto.toDomain());
      } else {
        return Left(ServerFailure(
            message: responseData['message'] ??
                'Failed to update notification status.',
            statusCode: response.statusCode));
      }
    } catch (e) {
      return Left(_dioClient.handleError(e));
    }
  }

  Future<Either<Failure, String>> markAllNotificationsAsRead(int userId) async {
    try {
      final response = await _dioClient.dio.put(
        ApiConstants.markAllNotificationsReadByUserId(userId),
      );
      final responseData = response.data as Map<String, dynamic>;
      if (responseData['success'] == true) {
        return Right(responseData['message'] as String? ??
            responseData['data'] as String? ??
            'Marked all as read.');
      } else {
        return Left(ServerFailure(
            message: responseData['message'] ??
                'Failed to mark all notifications as read.',
            statusCode: response.statusCode));
      }
    } catch (e) {
      return Left(_dioClient.handleError(e));
    }
  }

  Future<Either<Failure, String>> deleteNotificationById(
      int notificationId) async {
    try {
      final response = await _dioClient.dio.delete(
        ApiConstants.notificationById(notificationId),
      );
      final responseData = response.data as Map<String, dynamic>;
      if (responseData['success'] == true) {
        return Right(responseData['message'] as String? ??
            responseData['data'] as String? ??
            'Notification deleted.');
      } else {
        return Left(ServerFailure(
            message:
                responseData['message'] ?? 'Failed to delete notification.',
            statusCode: response.statusCode));
      }
    } catch (e) {
      return Left(_dioClient.handleError(e));
    }
  }

  Future<Either<Failure, PaginatedResponse<NotificationModel>>>
      getNotificationsByUserId({
    required int userId,
    int pageNumber = 1,
    int pageSize = 20,
  }) async {
    try {
      final queryParams = {
        'pageNumber': pageNumber,
        'pageSize': pageSize,
      };
      final response = await _dioClient.dio.get(
        ApiConstants.notificationsByUserId(userId),
        queryParameters: queryParams,
      );
      final responseData = response.data as Map<String, dynamic>;
      if (responseData['success'] == true && responseData['data'] != null) {
        final paginatedDto =
            PaginatedNotificationResponseDto.fromJson(responseData['data']);
        return Right(paginatedDto.toDomain());
      } else {
        return Left(ServerFailure(
            message:
                responseData['message'] ?? 'Failed to fetch notifications.',
            statusCode: response.statusCode));
      }
    } catch (e) {
      return Left(_dioClient.handleError(e));
    }
  }

  Future<Either<Failure, int>> getUnreadNotificationCount(int userId) async {
    try {
      final response = await _dioClient.dio.get(
        ApiConstants.unreadNotificationCountByUserId(userId),
      );
      final responseData = response.data as Map<String, dynamic>;
      if (responseData['success'] == true && responseData['data'] != null) {
        return Right(responseData['data'] as int? ?? 0);
      } else {
        return Left(ServerFailure(
            message: responseData['message'] ??
                'Failed to fetch unread notification count.',
            statusCode: response.statusCode));
      }
    } catch (e) {
      return Left(_dioClient.handleError(e));
    }
  }
}
