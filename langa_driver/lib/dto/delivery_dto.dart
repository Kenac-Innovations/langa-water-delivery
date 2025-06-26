import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart' show immutable, required;

@immutable
class ProposeDeliveryRequest {
  final int driverId;
  final double longitude;
  final double latitude;

  const ProposeDeliveryRequest({
    required this.driverId,
    required this.longitude,
    required this.latitude,
  });

  Map<String, dynamic> toJson() => {
        'driverId': driverId,
        'longitude': longitude,
        'latitude': latitude,
      };
}

@immutable
class SelectDeliveryRequest {
  final int deliveryId;
  final int driverId;

  const SelectDeliveryRequest({
    required this.deliveryId,
    required this.driverId,
  });

  Map<String, dynamic> toJson() => {
        'deliveryId': deliveryId,
        'driverId': driverId,
      };
}

@immutable
class PickupDeliveryRequest {
  final int driverId;
  final double latitude;
  final double longitude;
  final File? pickupImage;

  const PickupDeliveryRequest({
    required this.driverId,
    required this.latitude,
    required this.longitude,
    this.pickupImage,
  });

  Future<FormData> toFormData() async {
    final Map<String, dynamic> fields = {
      'driverId': driverId,
      'latitude': latitude,
      'longitude': longitude,
    };
    if (pickupImage != null) {
      fields['pickupImage'] = await MultipartFile.fromFile(
        pickupImage!.path,
        filename: pickupImage!.path.split('/').last,
      );
    }
    return FormData.fromMap(fields);
  }
}

@immutable
class CompleteDeliveryRequest {
  final String otp;
  final int driverId;
  final double latitude;
  final double longitude;

  const CompleteDeliveryRequest({
    required this.otp,
    required this.driverId,
    required this.latitude,
    required this.longitude,
  });

  Map<String, dynamic> toJson() => {
        'otp': otp,
        'driverId': driverId,
        'latitude': latitude,
        'longitude': longitude,
      };
}

@immutable
class CancelDeliveryRequest {
  final int driverId;
  final double longitude;
  final double latitude;

  const CancelDeliveryRequest({
    required this.driverId,
    required this.longitude,
    required this.latitude,
  });

  Map<String, dynamic> toJson() => {
        'driverId': driverId,
        'longitude': longitude,
        'latitude': latitude,
      };
}

@immutable
class AcceptDeliveryRequest {
  final int driverId;
  final double longitude;
  final double latitude;

  const AcceptDeliveryRequest({
    required this.driverId,
    required this.longitude,
    required this.latitude,
  });

  Map<String, dynamic> toJson() => {
        'driverId': driverId,
        'longitude': longitude,
        'latitude': latitude,
      };
}
