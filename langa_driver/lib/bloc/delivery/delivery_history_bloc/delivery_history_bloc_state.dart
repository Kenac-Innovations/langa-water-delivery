import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart' show immutable;
import 'package:langas_driver/models/delivery_models.dart';
import 'package:langas_driver/utils/delivery_enums.dart';
import 'package:langas_driver/utils/failure_models.dart';

@immutable
abstract class DeliveryHistoryState extends Equatable {
  const DeliveryHistoryState();
  @override
  List<Object?> get props => [];
}

class DeliveryHistoryInitial extends DeliveryHistoryState {}

class DeliveryHistoryLoading extends DeliveryHistoryState {}

class DeliveryHistoryLoadSuccess extends DeliveryHistoryState {
  final List<Delivery> deliveries;
  final bool hasReachedMax;
  final int currentPage;
  final int pageSize;
  final List<DeliveryStatus> currentStatuses;

  const DeliveryHistoryLoadSuccess({
    required this.deliveries,
    required this.hasReachedMax,
    required this.currentPage,
    required this.pageSize,
    required this.currentStatuses,
  });

  DeliveryHistoryLoadSuccess copyWith({
    List<Delivery>? deliveries,
    bool? hasReachedMax,
    int? currentPage,
    int? pageSize,
    List<DeliveryStatus>? currentStatuses,
  }) {
    return DeliveryHistoryLoadSuccess(
      deliveries: deliveries ?? this.deliveries,
      hasReachedMax: hasReachedMax ?? this.hasReachedMax,
      currentPage: currentPage ?? this.currentPage,
      pageSize: pageSize ?? this.pageSize,
      currentStatuses: currentStatuses ?? this.currentStatuses,
    );
  }

  @override
  List<Object?> get props =>
      [deliveries, hasReachedMax, currentPage, pageSize, currentStatuses];
}

class DeliveryHistoryLoadFailure extends DeliveryHistoryState {
  final Failure failure;
  const DeliveryHistoryLoadFailure({required this.failure});
  @override
  List<Object?> get props => [failure];
}

class DeliveryHistoryLoadingNextPage extends DeliveryHistoryLoadSuccess {
  const DeliveryHistoryLoadingNextPage({
    required super.deliveries,
    required super.hasReachedMax,
    required super.currentPage,
    required super.pageSize,
    required super.currentStatuses,
  });
}

class DeliveryHistoryNextPageError extends DeliveryHistoryLoadSuccess {
  final Failure failure;
  const DeliveryHistoryNextPageError({
    required this.failure,
    required super.deliveries,
    required super.hasReachedMax,
    required super.currentPage,
    required super.pageSize,
    required super.currentStatuses,
  });
  @override
  List<Object?> get props => [...super.props, failure];
}
