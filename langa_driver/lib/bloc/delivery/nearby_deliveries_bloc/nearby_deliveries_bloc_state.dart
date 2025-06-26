import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart' show immutable;
import 'package:langas_driver/models/delivery_models.dart';
import 'package:langas_driver/models/firebase_delivery_model.dart';
import 'package:langas_driver/utils/delivery_enums.dart';
import 'package:langas_driver/utils/failure_models.dart';

@immutable
abstract class NearbyDeliveriesState extends Equatable {
  const NearbyDeliveriesState();
  @override
  List<Object?> get props => [];
}

class NearbyDeliveriesInitial extends NearbyDeliveriesState {}

class NearbyDeliveriesLoading extends NearbyDeliveriesState {}

class NearbyDeliveriesLoadSuccess extends NearbyDeliveriesState {
  final List<FirebaseDelivery> deliveries; // todo l changed here
  final bool hasReachedMax;
  final int currentPage;
  final int pageSize;
  final String currentDriverId;
  final VehicleType currentVehicleType;

  const NearbyDeliveriesLoadSuccess({
    required this.deliveries,
    required this.hasReachedMax,
    required this.currentPage,
    required this.pageSize,
    required this.currentDriverId,
    required this.currentVehicleType,
  });

  NearbyDeliveriesLoadSuccess copyWith({
    List<FirebaseDelivery>? deliveries,
    bool? hasReachedMax,
    int? currentPage,
    int? pageSize,
    String? currentDriverId,
    VehicleType? currentVehicleType,
  }) {
    return NearbyDeliveriesLoadSuccess(
      deliveries: deliveries ?? this.deliveries,
      hasReachedMax: hasReachedMax ?? this.hasReachedMax,
      currentPage: currentPage ?? this.currentPage,
      pageSize: pageSize ?? this.pageSize,
      currentDriverId: currentDriverId ?? this.currentDriverId,
      currentVehicleType: currentVehicleType ?? this.currentVehicleType,
    );
  }

  @override
  List<Object?> get props => [
        deliveries,
        hasReachedMax,
        currentPage,
        pageSize,
        currentDriverId,
        currentVehicleType
      ];
}

class NearbyDeliveriesLoadFailure extends NearbyDeliveriesState {
  final Failure failure;
  const NearbyDeliveriesLoadFailure({required this.failure});
  @override
  List<Object?> get props => [failure];
}

class NearbyDeliveriesLoadingNextPage extends NearbyDeliveriesLoadSuccess {
  const NearbyDeliveriesLoadingNextPage({
    required super.deliveries,
    required super.hasReachedMax,
    required super.currentPage,
    required super.pageSize,
    required super.currentDriverId,
    required super.currentVehicleType,
  });
}

class NearbyDeliveriesNextPageError extends NearbyDeliveriesLoadSuccess {
  final Failure failure;
  const NearbyDeliveriesNextPageError({
    required this.failure,
    required super.deliveries,
    required super.hasReachedMax,
    required super.currentPage,
    required super.pageSize,
    required super.currentDriverId,
    required super.currentVehicleType,
  });
  @override
  List<Object?> get props => [...super.props, failure];
}

class ProposalSubmitting extends NearbyDeliveriesState {}

class ProposalSuccess extends NearbyDeliveriesState {
  final String message;

  const ProposalSuccess({required this.message});

  @override
  List<Object?> get props => [message];
}

class DeliveryAlreadyAccepted extends NearbyDeliveriesState {
  final String message;

  const DeliveryAlreadyAccepted({required this.message});

  @override
  List<Object?> get props => [message];
}

class ProposalFailure extends NearbyDeliveriesState {
  final Failure failure;
  const ProposalFailure({required this.failure});
  @override
  List<Object?> get props => [failure];
}
