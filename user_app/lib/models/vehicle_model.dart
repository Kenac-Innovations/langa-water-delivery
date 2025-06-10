import 'package:equatable/equatable.dart';
import 'package:langas_user/util/apps_enums.dart';

class Vehicle extends Equatable {
  final int vehicleId;
  final String? vehicleModel;
  final String? vehicleColor;
  final String? vehicleMake;
  final String? licensePlateNo;
  final VehicleType vehicleType;

  const Vehicle({
    required this.vehicleId,
    this.vehicleModel,
    this.vehicleColor,
    this.vehicleMake,
    this.licensePlateNo,
    required this.vehicleType,
  });

  // Added fromJson factory constructor
  factory Vehicle.fromJson(Map<String, dynamic> json) {
    return Vehicle(
      vehicleId: json['vehicleId'] as int? ?? 0,
      vehicleModel: json['vehicleModel'] as String?,
      vehicleColor: json['vehicleColor'] as String?,
      vehicleMake: json['vehicleMake'] as String?,
      licensePlateNo: json['licensePlateNo'] as String?,
      vehicleType: VehicleType.fromJson(json['vehicleType'] as String?),
    );
  }

  factory Vehicle.fromFirebase(Map<dynamic, dynamic> data) {
    // Implement parsing logic here based on your actual vehicle data structure
    // Example:
    return Vehicle(
      vehicleId: data['vehicleId'] as int? ??
          0, // Assuming vehicleId exists in Firebase
      vehicleMake: data['vehicleMake'] as String?,
      vehicleModel: data['vehicleModel'] as String?,
      vehicleColor: data['vehicleColor'] as String?,
      licensePlateNo: data['licensePlateNo'] as String?,
      vehicleType: VehicleType.values.firstWhere(
        (e) =>
            e.toString().split('.').last ==
            data['vehicleType'], // Match enum name
        orElse: () => VehicleType.CAR, // Default type if not found
      ),
    );
  }

  @override
  List<Object?> get props => [
        vehicleId,
        vehicleModel,
        vehicleColor,
        vehicleMake,
        licensePlateNo,
        vehicleType,
      ];
}
