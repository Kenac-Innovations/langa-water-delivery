import 'dart:async';
import 'package:dartz/dartz.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';
import 'package:langas_driver/bloc/delivery/nearby_deliveries_bloc/nearby_deliveries_bloc_event.dart';
import 'package:langas_driver/bloc/delivery/nearby_deliveries_bloc/nearby_deliveries_bloc_state.dart';
import 'package:langas_driver/models/delivery_models.dart';
import 'package:langas_driver/models/firebase_delivery_model.dart';
import 'package:langas_driver/repository/delivery_repository.dart';
import 'package:langas_driver/services/firebase_delivery_service.dart';
import 'package:langas_driver/services/geolocation.dart';
import 'package:langas_driver/utils/delivery_enums.dart';
import 'package:langas_driver/utils/failure_models.dart';
import 'package:langas_driver/utils/api_response_model.dart';

class NearbyDeliveriesBloc
    extends Bloc<NearbyDeliveriesEvent, NearbyDeliveriesState> {
  final FirebaseDeliveryService _firebaseDeliveryService;
  final DeliveryRepository _deliveryRepository;
  final GeolocationService _geolocationService;
  StreamSubscription<List<FirebaseDelivery>>? _deliveriesSubscription;
  StreamSubscription<Map<String, dynamic>>? _proposalsSubscription;
  Position? _currentPosition;
  static const double _searchRadiusKm = 100000.0; // 10km radius
  Map<String, dynamic> _currentProposals = {};

  NearbyDeliveriesBloc(
    this._deliveryRepository, {
    required FirebaseDeliveryService firebaseDeliveryService,
    required GeolocationService geolocationService,
  })  : _firebaseDeliveryService = firebaseDeliveryService,
        _geolocationService = geolocationService,
        super(NearbyDeliveriesInitial()) {
    on<LoadNearbyDeliveries>(_onLoadNearbyDeliveries);
  }

  @override
  Future<void> close() {
    _deliveriesSubscription?.cancel();
    _proposalsSubscription?.cancel();
    return super.close();
  }

  Future<void> _onLoadNearbyDeliveries(
      LoadNearbyDeliveries event, Emitter<NearbyDeliveriesState> emit) async {
    try {
      emit(NearbyDeliveriesLoading());

      // Cancel any existing subscriptions
      await _deliveriesSubscription?.cancel();
      await _proposalsSubscription?.cancel();

      // Get current location
      _currentPosition = await _geolocationService.getCurrentLocation();
      if (_currentPosition == null) {
        if (!isClosed) {
          emit(NearbyDeliveriesLoadFailure(
              failure:
                  ServerFailure(message: 'Could not get current location')));
        }
        return;
      }

      // Create a completer to handle the subscriptions
      final completer = Completer<void>();

      // Subscribe to driver proposals
      _proposalsSubscription =
          _firebaseDeliveryService.getDriverProposals(event.driverId).listen(
        (proposals) {
          if (!isClosed) {
            _currentProposals = proposals;
            // If we already have deliveries loaded, update the state
            if (state is NearbyDeliveriesLoadSuccess) {
              final currentState = state as NearbyDeliveriesLoadSuccess;
              emit(currentState.copyWith(
                deliveries:
                    _updateDeliveryProposalStatus(currentState.deliveries),
              ));
            }
          }
        },
        onError: (error) {
          print('Error in proposals stream: $error');
        },
      );

      // Subscribe to open deliveries
      _deliveriesSubscription =
          _firebaseDeliveryService.getOpenDeliveries(VehicleType.CAR).listen(
        (allDeliveries) async {
          if (!isClosed) {
            try {
              // Filter deliveries by distance
              final nearbyDeliveries = allDeliveries.where((delivery) {
                final distance = Geolocator.distanceBetween(
                  _currentPosition!.latitude,
                  _currentPosition!.longitude,
                  delivery.pickupLatitude,
                  delivery.pickupLongitude,
                );
                return distance <=
                    _searchRadiusKm * 1000; // Convert km to meters
              }).toList();

              // Check for removed deliveries that were proposed
              if (state is NearbyDeliveriesLoadSuccess) {
                final currentState = state as NearbyDeliveriesLoadSuccess;
                final removedDeliveries =
                    currentState.deliveries.where((oldDelivery) {
                  return oldDelivery.isProposed &&
                      !nearbyDeliveries.any(
                          (newDelivery) => newDelivery.id == oldDelivery.id);
                }).toList();

                if (removedDeliveries.isNotEmpty) {
                  emit(DeliveryAlreadyAccepted(
                    message:
                        'Delivery #${removedDeliveries.first.id} has been accepted by another driver',
                  ));
                }
              }

              if (!isClosed) {
                emit(NearbyDeliveriesLoadSuccess(
                  deliveries: _updateDeliveryProposalStatus(nearbyDeliveries),
                  hasReachedMax: true, // No pagination with Firebase
                  currentPage: 1,
                  pageSize: nearbyDeliveries.length,
                  currentDriverId: event.driverId,
                  currentVehicleType: event.vehicleType,
                ));
              }
            } catch (e) {
              if (!isClosed) {
                emit(NearbyDeliveriesLoadFailure(
                    failure: ServerFailure(message: e.toString())));
              }
            }
          }
        },
        onError: (error) {
          if (!isClosed) {
            emit(NearbyDeliveriesLoadFailure(
                failure: ServerFailure(message: error.toString())));
          }
          completer.completeError(error);
        },
        onDone: () {
          if (!completer.isCompleted) {
            completer.complete();
          }
        },
      );

      // Wait for the initial data to be loaded
      await completer.future;
    } catch (e) {
      if (!isClosed) {
        emit(NearbyDeliveriesLoadFailure(
            failure: ServerFailure(message: e.toString())));
      }
    }
  }

  List<FirebaseDelivery> _updateDeliveryProposalStatus(
      List<FirebaseDelivery> deliveries) {
    return deliveries.map((delivery) {
      final proposalData = _currentProposals[delivery.id.toString()];
      if (proposalData != null) {
        // Create a copy of the delivery with updated proposal status
        return delivery.copyWith(
          isProposed: true,
          proposalId: proposalData['proposalId']?.toString(),
        );
      }
      return delivery;
    }).toList();
  }
}
