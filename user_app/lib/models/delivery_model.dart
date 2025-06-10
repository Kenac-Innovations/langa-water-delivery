import 'package:equatable/equatable.dart';
import 'package:langas_user/models/driver_model.dart';
import 'package:langas_user/models/vehicle_model.dart';
import 'package:langas_user/util/apps_enums.dart';

class Delivery extends Equatable {
  final int deliveryId;
  final num priceAmount;
  final String currency;
  final bool autoAssign;
  final Sensitivity sensitivity;
  final PaymentStatus paymentStatus;
  final double pickupLatitude;
  final double pickupLongitude;
  final String pickupLocation;
  final String pickupContactName;
  final String pickupContactPhone;
  final double dropOffLatitude;
  final double dropOffLongitude;
  final String dropOffLocation;
  final String dropOffContactName;
  final String dropOffContactPhone;
  final String? deliveryInstructions;
  final String parcelDescription;
  final VehicleType vehicleType;
  final PaymentMethod paymentMethod;
  final String? deliveryImageUrl;
  final num? packageWeight;
  final DeliveryStatus deliveryStatus;
  final Driver? driver;
  final Vehicle? vehicle;

  const Delivery({
    required this.deliveryId,
    required this.priceAmount,
    required this.currency,
    required this.autoAssign,
    required this.sensitivity,
    required this.paymentStatus,
    required this.pickupLatitude,
    required this.pickupLongitude,
    required this.pickupLocation,
    required this.pickupContactName,
    required this.pickupContactPhone,
    required this.dropOffLatitude,
    required this.dropOffLongitude,
    required this.dropOffLocation,
    required this.dropOffContactName,
    required this.dropOffContactPhone,
    this.deliveryInstructions,
    required this.parcelDescription,
    required this.vehicleType,
    required this.paymentMethod,
    this.deliveryImageUrl,
    this.packageWeight,
    required this.deliveryStatus,
    this.driver,
    this.vehicle,
  });

  @override
  List<Object?> get props => [
        deliveryId,
        priceAmount,
        currency,
        autoAssign,
        sensitivity,
        paymentStatus,
        pickupLatitude,
        pickupLongitude,
        pickupLocation,
        pickupContactName,
        pickupContactPhone,
        dropOffLatitude,
        dropOffLongitude,
        dropOffLocation,
        dropOffContactName,
        dropOffContactPhone,
        deliveryInstructions,
        parcelDescription,
        vehicleType,
        paymentMethod,
        deliveryImageUrl,
        packageWeight,
        deliveryStatus,
        driver,
        vehicle,
      ];
}
