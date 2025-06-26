import 'dart:io';
import 'package:flutter/foundation.dart' show immutable, required;
import 'package:dio/dio.dart';

@immutable
class DriverRegistrationRequest {
  final String phoneNumber;
  final String email;
  final String firstname;
  final String lastname;
  final String? middleName;
  final String password; // Keep the field
  final String gender;
  final String address;
  final String nationalIdNumber;
  final File? profilePhoto;
  final File? nationalIdImage;
  final File? driversLicenseImage;

  const DriverRegistrationRequest({
    required this.phoneNumber,
    required this.email,
    required this.firstname,
    required this.lastname,
    this.middleName,
    required this.password,
    required this.gender,
    required this.address,
    required this.nationalIdNumber,
    this.profilePhoto,
    this.nationalIdImage,
    this.driversLicenseImage,
  });

  Future<FormData> toFormData() async {
    final Map<String, dynamic> fields = {
      'phoneNumber': phoneNumber,
      'email': email,
      'firstname': firstname,
      'lastname': lastname,
      if (middleName != null) 'middleName': middleName,
      'password': password, // Send the actual password here
      'gender': gender,
      'address': address,
      'nationalIdNumber': nationalIdNumber,
    };

    // --- File handling remains the same ---
    if (profilePhoto != null) {
      fields['profilePhoto'] = await MultipartFile.fromFile(
        profilePhoto!.path,
        filename: profilePhoto!.path.split('/').last,
      );
    }
    if (nationalIdImage != null) {
      fields['nationalIdImage'] = await MultipartFile.fromFile(
        nationalIdImage!.path,
        filename: nationalIdImage!.path.split('/').last,
      );
    }
    if (driversLicenseImage != null) {
      fields['driversLicenseImage'] = await MultipartFile.fromFile(
        driversLicenseImage!.path,
        filename: driversLicenseImage!.path.split('/').last,
      );
    }

    return FormData.fromMap(fields);
  }

  // --- ADDED toString() METHOD ---
  @override
  String toString() {
    // Helper function to get filename or 'null'
    String fileInfo(File? file) {
      if (file == null) return 'null';
      // Extract filename from path
      try {
        return 'File(name: ${file.path.split('/').last})';
      } catch (e) {
        return 'File(path: ${file.path})'; // Fallback if split fails
      }
    }

    return 'DriverRegistrationRequest('
        'phoneNumber: $phoneNumber, '
        'email: $email, '
        'firstname: $firstname, '
        'lastname: $lastname, '
        'middleName: $middleName, '
        'password: ********, ' // MASK PASSWORD FOR SECURITY
        'gender: $gender, '
        'address: $address, '
        'nationalIdNumber: $nationalIdNumber, '
        'profilePhoto: ${fileInfo(profilePhoto)}, '
        'nationalIdImage: ${fileInfo(nationalIdImage)}, '
        'driversLicenseImage: ${fileInfo(driversLicenseImage)}'
        ')';
  }
  // --- END OF ADDED METHOD ---
}

// --- Other classes remain the same ---

@immutable
class VerifyOtpRequest {
  final String loginID;
  final String otp;

  const VerifyOtpRequest({
    required this.loginID,
    required this.otp,
  });

  Map<String, dynamic> toJson() => {
        'loginID': loginID,
        'otp': otp,
      };

  // Optional: Add toString here too if needed for debugging
  @override
  String toString() => 'VerifyOtpRequest(loginID: $loginID, otp: $otp)';
}

@immutable
class LoginRequest {
  final String loginId;
  final String password;

  const LoginRequest({
    required this.loginId,
    required this.password,
  });

  Map<String, dynamic> toJson() => {
        'loginId': loginId,
        'password': password, // Send actual password in JSON
      };

  // Optional: Add toString here too if needed for debugging
  @override
  String toString() =>
      'LoginRequest(loginId: $loginId, password: ********)'; // MASK PASSWORD
}

@immutable
class ResetPasswordRequest {
  final String loginId;
  final String token;
  final String password;

  const ResetPasswordRequest({
    required this.loginId,
    required this.token,
    required this.password,
  });

  Map<String, dynamic> toJson() => {
        'loginId': loginId,
        'token': token,
        'password': password, // Send actual password in JSON
      };

  // Optional: Add toString here too if needed for debugging
  @override
  String toString() =>
      'ResetPasswordRequest(loginId: $loginId, token: $token, password: ********)'; // MASK PASSWORD
}

class VerifyAccountRequestDto {
  final String loginID;
  final String otp;

  VerifyAccountRequestDto({
    required this.loginID,
    required this.otp,
  });

  Map<String, dynamic> toJson() {
    return {
      'loginID': loginID,
      'otp': otp,
    };
  }
}
