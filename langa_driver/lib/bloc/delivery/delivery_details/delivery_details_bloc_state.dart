import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:langas_driver/models/delivery_models.dart';
import 'package:langas_driver/utils/failure_models.dart';

@immutable
abstract class DeliveryDetailsState extends Equatable {
  const DeliveryDetailsState();
  @override
  List<Object?> get props => [];
}

class DeliveryDetailsInitial extends DeliveryDetailsState {}

class DeliveryDetailsLoading extends DeliveryDetailsState {}

class DeliveryDetailsLoadSuccess extends DeliveryDetailsState {
  final Delivery delivery;
  final List<LatLng> routeCoordinates;
  final String? estimatedTime;
  final double? estimatedDistance;

  const DeliveryDetailsLoadSuccess({
    required this.delivery,
    required this.routeCoordinates,
    this.estimatedTime,
    this.estimatedDistance,
  });

  @override
  List<Object?> get props =>
      [delivery, routeCoordinates, estimatedTime, estimatedDistance];
}

class DeliveryDetailsLoadFailure extends DeliveryDetailsState {
  final Failure failure;
  const DeliveryDetailsLoadFailure({required this.failure});
  @override
  List<Object?> get props => [failure];
}
