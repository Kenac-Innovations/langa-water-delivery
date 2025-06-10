import 'package:equatable/equatable.dart';
import 'package:langas_user/models/vehicle_model.dart';

class Driver extends Equatable {
  final int driverId;
  final String? email;
  final String? phoneNumber;
  final String? firstname;
  final String? lastname;
  final String? gender;
  final String? profilePhotoUrl;
  final num? rating;
  final double? longitude;
  final double? latitude;
  final int? totalDeliveries;

  final Vehicle? activeVehicle;
  final String? status;

  const Driver(
      {required this.driverId,
      this.email,
      this.phoneNumber,
      this.firstname,
      this.lastname,
      this.gender,
      this.profilePhotoUrl,
      this.rating,
      this.longitude,
      this.latitude,
      this.totalDeliveries,
      this.activeVehicle,
      this.status});

  factory Driver.fromJson(Map<String, dynamic> json) {
    return Driver(
      driverId: json['driverID'] as int? ?? 0,
      email: json['email'] as String?,
      phoneNumber: json['phoneNumber'] as String?,
      firstname: json['firstname'] as String?,
      lastname: json['lastname'] as String?,
      gender: json['gender'] as String?,
      profilePhotoUrl: json['profilePhotoUrl'] as String?,
      rating: json['rating'] as num?,
      longitude: (json['longitude'] as num?)?.toDouble(),
      latitude: (json['latitude'] as num?)?.toDouble(),
      totalDeliveries: json['total_deliveries'] as int?,
      activeVehicle: json['active_vehicle'] != null
          ? Vehicle.fromJson(json['active_vehicle'] as Map<String, dynamic>)
          : null,
    );
  }

  factory Driver.fromFirebase(Map<dynamic, dynamic> data) {
    // Assuming the data map directly corresponds to the driver fields from Firebase RTDB
    return Driver(
      driverId: data['driverID'] as int,
      firstname: data['firstname'] as String?,
      lastname: data['lastname'] as String?,
      latitude: (data['latitude'] as num?)?.toDouble(),
      longitude: (data['longitude'] as num?)?.toDouble(),
      profilePhotoUrl: data['profilePhotoUrl'] as String?,
      status: data['status'],
      rating: (data['rating'] as num?)?.toDouble(),
      totalDeliveries: data['totalDeliveries'] as int?,
      activeVehicle: data['activeVehicle'] != null
          ? Vehicle.fromFirebase(data['activeVehicle'] as Map<dynamic, dynamic>)
          : null,
    );
  }

  @override
  List<Object?> get props => [
        driverId,
        email,
        phoneNumber,
        firstname,
        lastname,
        gender,
        profilePhotoUrl,
        rating,
        longitude,
        latitude,
        totalDeliveries,
        activeVehicle,
        status
      ];
}
