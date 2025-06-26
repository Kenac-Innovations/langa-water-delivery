import 'package:flutter/foundation.dart' show immutable, required;
import 'package:langas_driver/models/delivery_models.dart';
import 'package:langas_driver/utils/delivery_enums.dart';

@immutable
class FirebaseCustomer {
  final int clientId;
  final String firstname;
  final String lastname;

  const FirebaseCustomer({
    required this.clientId,
    required this.firstname,
    required this.lastname,
  });

  factory FirebaseCustomer.fromJson(Map<String, dynamic> json) {
    return FirebaseCustomer(
      clientId: _parseInt(json['clientId']),
      firstname: json['firstname'] as String? ?? '',
      lastname: json['lastname'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'clientId': clientId,
      'firstname': firstname,
      'lastname': lastname,
    };
  }

  static int _parseInt(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    if (value is String) return int.tryParse(value) ?? 0;
    if (value is double) return value.toInt();
    return 0;
  }
}

@immutable
class FirebaseVehicle {
  final int id;
  final String vehicleModel;
  final String vehicleColor;
  final String vehicleMake;
  final String licensePlateNo;
  final VehicleType vehicleType;

  const FirebaseVehicle({
    required this.id,
    required this.vehicleModel,
    required this.vehicleColor,
    required this.vehicleMake,
    required this.licensePlateNo,
    required this.vehicleType,
  });

  factory FirebaseVehicle.fromJson(Map<String, dynamic> json) {
    return FirebaseVehicle(
      id: _parseInt(json['id']),
      vehicleModel: json['vehicleModel'] as String? ?? '',
      vehicleColor: json['vehicleColor'] as String? ?? '',
      vehicleMake: json['vehicleMake'] as String? ?? '',
      licensePlateNo: json['licensePlateNo'] as String? ?? '',
      vehicleType: VehicleType.fromJson(json['vehicleType'] as String?),
    );
  }

  static int _parseInt(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    if (value is String) {
      return int.tryParse(value) ?? 0;
    }
    if (value is double) return value.toInt();
    return 0;
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'vehicleModel': vehicleModel,
      'vehicleColor': vehicleColor,
      'vehicleMake': vehicleMake,
      'licensePlateNo': licensePlateNo,
      'vehicleType': vehicleType.toJson(),
    };
  }
}

@immutable
class FirebaseDelivery {
  final int id;
  final double priceAmount;
  final String currency;
  final Sensitivity sensitivity;
  final PaymentStatus paymentStatus;
  final String geohash;
  final List<double> coordinates;
  final String pickupLocation;
  final String dropOffLocation;
  final double pickupLatitude;
  final double pickupLongitude;
  final double dropOffLatitude;
  final double dropOffLongitude;
  final String? deliveryInstructions;
  final String parcelDescription;
  final VehicleType vehicleType;
  final PaymentMethod paymentMethod;
  final double packageWeight;
  final DeliveryStatus deliveryStatus;
  final double commissionRequired;
  final String createdAt;
  final FirebaseCustomer? client;
  final FirebaseVehicle? vehicle;
  final bool isProposed;
  final String? proposalId;
  final int numberOfSeats;
  final String deliveryType;
  final bool isScheduled;
  final bool autoDispatch;

  const FirebaseDelivery({
    required this.id,
    required this.priceAmount,
    required this.currency,
    required this.sensitivity,
    required this.paymentStatus,
    required this.geohash,
    required this.coordinates,
    required this.pickupLocation,
    required this.dropOffLocation,
    required this.pickupLatitude,
    required this.pickupLongitude,
    required this.dropOffLatitude,
    required this.dropOffLongitude,
    this.deliveryInstructions,
    required this.parcelDescription,
    required this.vehicleType,
    required this.paymentMethod,
    required this.packageWeight,
    required this.deliveryStatus,
    required this.commissionRequired,
    required this.createdAt,
    this.client,
    this.vehicle,
    this.isProposed = false,
    this.proposalId,
    required this.numberOfSeats,
    required this.deliveryType,
    required this.isScheduled,
    required this.autoDispatch,
  });

  factory FirebaseDelivery.fromJson(Map<String, dynamic> json) {
    List<double> coords = [];
    if (json['l'] is List) {
      final coordsList = json['l'] as List;
      coords = coordsList.map((e) => _parseDouble(e)).toList();
    }
    while (coords.length < 2) {
      coords.add(0.0);
    }

    return FirebaseDelivery(
      id: _parseInt(json['id']),
      priceAmount: _parseDouble(json['priceAmount']),
      currency: json['currency'] as String? ?? '',
      sensitivity: Sensitivity.fromJson(json['sensitivity'] as String?),
      paymentStatus: PaymentStatus.fromJson(json['paymentStatus'] as String?),
      geohash: json['g'] as String? ?? '',
      coordinates: coords,
      pickupLocation: json['pickupLocation'] as String? ?? '',
      dropOffLocation: json['dropOffLocation'] as String? ?? '',
      pickupLatitude: _parseDouble(json['pickupLatitude']),
      pickupLongitude: _parseDouble(json['pickupLongitude']),
      dropOffLatitude: _parseDouble(json['dropOffLatitude']),
      dropOffLongitude: _parseDouble(json['dropOffLongitude']),
      deliveryInstructions: json['deliveryInstructions'] as String?,
      parcelDescription: json['parcelDescription'] as String? ?? '',
      vehicleType: VehicleType.fromJson(json['vehicleType'] as String?),
      paymentMethod: PaymentMethod.fromJson(json['paymentMethod'] as String?),
      packageWeight: _parseDouble(json['packageWeight']),
      deliveryStatus:
          DeliveryStatus.fromJson(json['deliveryStatus'] as String?),
      commissionRequired: _parseDouble(json['commissionRequired']),
      createdAt: json['createdAt'] as String? ?? '',
      client: json['client'] != null
          ? FirebaseCustomer.fromJson(json['client'] as Map<String, dynamic>)
          : null,
      vehicle: json['vehicle'] != null
          ? FirebaseVehicle.fromJson(json['vehicle'] as Map<String, dynamic>)
          : null,
      isProposed: json['isProposed'] as bool? ?? false,
      proposalId: json['proposalId'] as String?,
      numberOfSeats: _parseInt(json['numberOfSeats']),
      deliveryType: json['deliveryType'] as String? ?? 'PARCEL',
      isScheduled: json['isScheduled'] as bool? ?? false,
      autoDispatch: json['autoDispatch'] as bool? ?? false,
    );
  }

  static int _parseInt(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    if (value is String) {
      return int.tryParse(value) ?? 0;
    }
    if (value is double) return value.toInt();
    return 0;
  }

  static double _parseDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) {
      return double.tryParse(value) ?? 0.0;
    }
    return 0.0;
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'priceAmount': priceAmount.toString(),
      'currency': currency,
      'sensitivity': sensitivity.toJson(),
      'paymentStatus': paymentStatus.toJson(),
      'g': geohash,
      'l': coordinates,
      'pickupLocation': pickupLocation,
      'dropOffLocation': dropOffLocation,
      'pickupLatitude': pickupLatitude,
      'pickupLongitude': pickupLongitude,
      'dropOffLatitude': dropOffLatitude,
      'dropOffLongitude': dropOffLongitude,
      'deliveryInstructions': deliveryInstructions,
      'parcelDescription': parcelDescription,
      'vehicleType': vehicleType.toJson(),
      'paymentMethod': paymentMethod.toJson(),
      'packageWeight': packageWeight,
      'deliveryStatus': deliveryStatus.toJson(),
      'commissionRequired': commissionRequired,
      'createdAt': createdAt,
      'client': client?.toJson(),
      'vehicle': vehicle?.toJson(),
      'isProposed': isProposed,
      'proposalId': proposalId,
      'numberOfSeats': numberOfSeats,
      'deliveryType': deliveryType,
      'isScheduled': isScheduled,
      'autoDispatch': autoDispatch,
    };
  }

  double get latitude => coordinates.isNotEmpty ? coordinates[0] : 0.0;
  double get longitude => coordinates.length > 1 ? coordinates[1] : 0.0;

  Delivery toDelivery() {
    return Delivery(
      deliverId: id,
      priceAmount: priceAmount,
      currency: currency,
      sensitivity: sensitivity,
      paymentStatus: paymentStatus,
      pickupLatitude: pickupLatitude,
      pickupLongitude: pickupLongitude,
      pickupLocation: pickupLocation,
      pickupContactName: '',
      pickupContactPhone: '',
      dropOffLatitude: dropOffLatitude,
      dropOffLongitude: dropOffLongitude,
      dropOffLocation: dropOffLocation,
      dropOffContactName: '',
      dropOffContactPhone: '',
      deliveryInstructions: deliveryInstructions,
      parcelDescription: parcelDescription,
      vehicleType: vehicleType,
      paymentMethod: paymentMethod,
      packageWeight: packageWeight,
      deliveryStatus: deliveryStatus,
      commissionRequired: commissionRequired,
      isProposed: isProposed,
      numberOfSeats: numberOfSeats,
      deliveryType: deliveryType,
      isScheduled: isScheduled,
      customer: Customer(
        clientId: client?.clientId ?? 0,
        firstname: client?.firstname ?? '',
        lastname: client?.lastname ?? '',
        mobileNumber: '',
        emailAddress: '',
      ),
      vehicle: vehicle != null
          ? DeliveryVehicleInfo(
              vehicleId: vehicle!.id,
              vehicleModel: vehicle!.vehicleModel,
              vehicleColor: vehicle!.vehicleColor,
              vehicleMake: vehicle!.vehicleMake,
              licensePlateNo: vehicle!.licensePlateNo,
              vehicleType: vehicle!.vehicleType,
            )
          : null,
    );
  }

  FirebaseDelivery copyWith({
    int? id,
    double? priceAmount,
    String? currency,
    Sensitivity? sensitivity,
    PaymentStatus? paymentStatus,
    String? geohash,
    List<double>? coordinates,
    String? pickupLocation,
    String? dropOffLocation,
    double? pickupLatitude,
    double? pickupLongitude,
    double? dropOffLatitude,
    double? dropOffLongitude,
    String? deliveryInstructions,
    String? parcelDescription,
    VehicleType? vehicleType,
    PaymentMethod? paymentMethod,
    double? packageWeight,
    DeliveryStatus? deliveryStatus,
    double? commissionRequired,
    String? createdAt,
    FirebaseCustomer? client,
    FirebaseVehicle? vehicle,
    bool? isProposed,
    String? proposalId,
    int? numberOfSeats,
    String? deliveryType,
    bool? isScheduled,
    bool? autoDispatch,
  }) {
    return FirebaseDelivery(
      id: id ?? this.id,
      priceAmount: priceAmount ?? this.priceAmount,
      currency: currency ?? this.currency,
      sensitivity: sensitivity ?? this.sensitivity,
      paymentStatus: paymentStatus ?? this.paymentStatus,
      geohash: geohash ?? this.geohash,
      coordinates: coordinates ?? this.coordinates,
      pickupLocation: pickupLocation ?? this.pickupLocation,
      dropOffLocation: dropOffLocation ?? this.dropOffLocation,
      pickupLatitude: pickupLatitude ?? this.pickupLatitude,
      pickupLongitude: pickupLongitude ?? this.pickupLongitude,
      dropOffLatitude: dropOffLatitude ?? this.dropOffLatitude,
      dropOffLongitude: dropOffLongitude ?? this.dropOffLongitude,
      deliveryInstructions: deliveryInstructions ?? this.deliveryInstructions,
      parcelDescription: parcelDescription ?? this.parcelDescription,
      vehicleType: vehicleType ?? this.vehicleType,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      packageWeight: packageWeight ?? this.packageWeight,
      deliveryStatus: deliveryStatus ?? this.deliveryStatus,
      commissionRequired: commissionRequired ?? this.commissionRequired,
      createdAt: createdAt ?? this.createdAt,
      client: client ?? this.client,
      vehicle: vehicle ?? this.vehicle,
      isProposed: isProposed ?? this.isProposed,
      proposalId: proposalId ?? this.proposalId,
      numberOfSeats: numberOfSeats ?? this.numberOfSeats,
      deliveryType: deliveryType ?? this.deliveryType,
      isScheduled: isScheduled ?? this.isScheduled,
      autoDispatch: autoDispatch ?? this.autoDispatch,
    );
  }
}
