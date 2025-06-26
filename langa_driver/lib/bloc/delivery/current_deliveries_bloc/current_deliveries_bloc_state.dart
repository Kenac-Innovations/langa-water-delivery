import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart' show immutable;
import 'package:langas_driver/models/delivery_models.dart';
import 'package:langas_driver/utils/failure_models.dart';

@immutable
abstract class CurrentDeliveriesState extends Equatable {
  const CurrentDeliveriesState();
  @override
  List<Object?> get props => [];
}

class CurrentDeliveriesInitial extends CurrentDeliveriesState {}

class CurrentDeliveriesLoading extends CurrentDeliveriesState {}

class CurrentDeliveriesLoadSuccess extends CurrentDeliveriesState {
  final List<Delivery> deliveries;
  final bool hasReachedMax;
  final int currentPage;
  final int pageSize;

  const CurrentDeliveriesLoadSuccess({
    required this.deliveries,
    required this.hasReachedMax,
    required this.currentPage,
    required this.pageSize,
  });

  CurrentDeliveriesLoadSuccess copyWith({
    List<Delivery>? deliveries,
    bool? hasReachedMax,
    int? currentPage,
    int? pageSize,
  }) {
    return CurrentDeliveriesLoadSuccess(
      deliveries: deliveries ?? this.deliveries,
      hasReachedMax: hasReachedMax ?? this.hasReachedMax,
      currentPage: currentPage ?? this.currentPage,
      pageSize: pageSize ?? this.pageSize,
    );
  }

  @override
  List<Object?> get props => [deliveries, hasReachedMax, currentPage, pageSize];
}

class CurrentDeliveriesLoadFailure extends CurrentDeliveriesState {
  final Failure failure;
  const CurrentDeliveriesLoadFailure({required this.failure});
  @override
  List<Object?> get props => [failure];
}

class CurrentDeliveriesLoadingNextPage extends CurrentDeliveriesLoadSuccess {
  const CurrentDeliveriesLoadingNextPage({
    required super.deliveries,
    required super.hasReachedMax,
    required super.currentPage,
    required super.pageSize,
  });
}

class CurrentDeliveriesNextPageError extends CurrentDeliveriesLoadSuccess {
  final Failure failure;
  const CurrentDeliveriesNextPageError({
    required this.failure,
    required super.deliveries,
    required super.hasReachedMax,
    required super.currentPage,
    required super.pageSize,
  });
  @override
  List<Object?> get props => [...super.props, failure];
}

// States for Actions
class DeliveryActionLoading extends CurrentDeliveriesState {
  final String deliveryId; // ID of delivery being acted upon
  const DeliveryActionLoading({required this.deliveryId});
  @override
  List<Object?> get props => [deliveryId];
}

class DeliveryActionSuccess extends CurrentDeliveriesState {
  final String deliveryId;
  final String message;
  const DeliveryActionSuccess(
      {required this.deliveryId, required this.message});
  @override
  List<Object?> get props => [deliveryId, message];
}

class DeliveryActionFailure extends CurrentDeliveriesState {
  final String deliveryId;
  final Failure failure;
  const DeliveryActionFailure(
      {required this.deliveryId, required this.failure});
  @override
  List<Object?> get props => [deliveryId, failure];
}
