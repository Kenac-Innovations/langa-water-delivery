import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart' show immutable, required;
import 'package:langas_driver/utils/delivery_enums.dart';

@immutable
class CreateVehicleRequest {
  final String vehicleModel;
  final String vehicleColor;
  final String vehicleMake;
  final String licensePlateNo;
  final VehicleType vehicleType;
  final File? registrationBookFile;
  final File? frontImageFile;
  final File? backImageFile;
  final File? sideImageFile;

  const CreateVehicleRequest({
    required this.vehicleModel,
    required this.vehicleColor,
    required this.vehicleMake,
    required this.licensePlateNo,
    required this.vehicleType,
    this.registrationBookFile,
    this.frontImageFile,
    this.backImageFile,
    this.sideImageFile,
  });

  Future<FormData> toFormData() async {
    final Map<String, dynamic> fields = {
      'vehicleModel': vehicleModel,
      'vehicleColor': vehicleColor,
      'vehicleMake': vehicleMake,
      'licensePlateNo': licensePlateNo,
      'vehicleType': vehicleType.toJson(),
    };

    if (registrationBookFile != null) {
      fields['registrationBookFile'] = await MultipartFile.fromFile(
        registrationBookFile!.path,
        filename: registrationBookFile!.path.split('/').last,
      );
    }
    if (frontImageFile != null) {
      fields['frontImageFile'] = await MultipartFile.fromFile(
        frontImageFile!.path,
        filename: frontImageFile!.path.split('/').last,
      );
    }
    if (backImageFile != null) {
      fields['backImageFile'] = await MultipartFile.fromFile(
        backImageFile!.path,
        filename: backImageFile!.path.split('/').last,
      );
    }
    if (sideImageFile != null) {
      fields['sideImageFile'] = await MultipartFile.fromFile(
        sideImageFile!.path,
        filename: sideImageFile!.path.split('/').last,
      );
    }
    return FormData.fromMap(fields);
  }
}
