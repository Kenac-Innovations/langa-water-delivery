import 'package:flutter/foundation.dart' show immutable, required;
import 'package:langas_driver/utils/delivery_enums.dart';

@immutable
class Vehicle {
  final int vehicleId;
  final String vehicleModel;
  final String vehicleColor;
  final String vehicleMake;
  final String licensePlateNo;
  final bool active;
  final VehicleType vehicleType;
  final VehicleStatus vehicleStatus;
  final String? driverName;
  final String? registrationBookUrl;
  final String? frontImageUrl;
  final String? backImageUrl;
  final String? sideImageUrl;

  const Vehicle({
    required this.vehicleId,
    required this.vehicleModel,
    required this.vehicleColor,
    required this.vehicleMake,
    required this.licensePlateNo,
    required this.active,
    required this.vehicleType,
    required this.vehicleStatus,
    this.driverName,
    this.registrationBookUrl,
    this.frontImageUrl,
    this.backImageUrl,
    this.sideImageUrl,
  });

  factory Vehicle.fromJson(Map<String, dynamic> json) {
    return Vehicle(
      vehicleId: json['vehicleId'] as int? ?? 0,
      vehicleModel: json['vehicleModel'] as String? ?? '',
      vehicleColor: json['vehicleColor'] as String? ?? '',
      vehicleMake: json['vehicleMake'] as String? ?? '',
      licensePlateNo: json['licensePlateNo'] as String? ?? '',
      active: json['active'] as bool? ?? false,
      vehicleType: VehicleType.fromJson(json['vehicleType'] as String?),
      vehicleStatus: VehicleStatus.fromJson(json['vehicleStatus'] as String?),
      driverName: json['driverName'] as String?,
      registrationBookUrl: json['registrationBookUrl'] as String?,
      frontImageUrl: json['frontImageUrl'] as String?,
      backImageUrl: json['backImageUrl'] as String?,
      sideImageUrl: json['sideImageUrl'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'vehicleId': vehicleId,
      'vehicleModel': vehicleModel,
      'vehicleColor': vehicleColor,
      'vehicleMake': vehicleMake,
      'licensePlateNo': licensePlateNo,
      'active': active,
      'vehicleType': vehicleType.toJson(),
      'vehicleStatus': vehicleStatus.toJson(),
      'driverName': driverName,
      'registrationBookUrl': registrationBookUrl,
      'frontImageUrl': frontImageUrl,
      'backImageUrl': backImageUrl,
      'sideImageUrl': sideImageUrl,
    };
  }
}
