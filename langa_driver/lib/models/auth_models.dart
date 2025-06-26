import 'package:flutter/foundation.dart' show immutable, required;
import 'package:langas_driver/models/vehicle_model.dart';

@immutable
class DriverRegistrationResponseData {
  final int userId;
  final String email;
  final String phoneNumber;

  const DriverRegistrationResponseData({
    required this.userId,
    required this.email,
    required this.phoneNumber,
  });

  factory DriverRegistrationResponseData.fromJson(Map<String, dynamic> json) {
    return DriverRegistrationResponseData(
      userId: json['userId'] as int? ?? 0,
      email: json['email'] as String? ?? '',
      phoneNumber: json['phoneNumber'] as String? ?? '',
    );
  }
}

@immutable
class UserProfile {
  final int userId;
  final String email;
  final String phoneNumber;
  final String firstName;
  final String lastName;
  final double walletBalance;

  const UserProfile({
    required this.userId,
    required this.email,
    required this.phoneNumber,
    required this.firstName,
    required this.lastName,
    required this.walletBalance,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      userId: json['userId'] as int? ?? 0,
      email: json['email'] as String? ?? '',
      phoneNumber: json['phoneNumber'] as String? ?? '',
      firstName: json['firstName'] as String? ?? '',
      lastName: json['lastName'] as String? ?? '',
      walletBalance: (json['walletBalance'] as num?)?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'email': email,
      'phoneNumber': phoneNumber,
      'firstName': firstName,
      'lastName': lastName,
      'walletBalance': walletBalance,
    };
  }
}

@immutable
@immutable
class DriverProfile {
  final int id;
  final String firstname;
  final String lastname;
  final String? middleName;
  final String gender;
  final String mobileNumber;
  final String email;
  final String address;
  final String nationalIdNo;
  final String? driverLicenseNo;
  final String? approvalStatus;
  final String? approvedBy;
  final String? dateApproved;
  final String? profilePhotoUrl;
  final String? nationalIdImage;
  final String? driversLicenseUrl;
  final int userId;
  final int? walletId;
  final Vehicle? activeVehicle;
  final double? rating;
  final double? walletBalance;
  final bool onlineStatus;
  final double searchRadiusInKm;
  final int numberOfDeliveries;
  final bool isBusy;

  const DriverProfile({
    required this.id,
    required this.firstname,
    required this.lastname,
    this.middleName,
    required this.gender,
    required this.mobileNumber,
    required this.email,
    required this.address,
    required this.nationalIdNo,
    this.driverLicenseNo,
    this.approvalStatus,
    this.approvedBy,
    this.dateApproved,
    this.profilePhotoUrl,
    this.nationalIdImage,
    this.driversLicenseUrl,
    required this.userId,
    this.walletId,
    this.activeVehicle,
    this.rating,
    this.walletBalance,
    this.onlineStatus = false,
    this.searchRadiusInKm = 3.0,
    this.numberOfDeliveries = 0,
    this.isBusy = false,
  });

  factory DriverProfile.fromJson(Map<String, dynamic> json) {
    return DriverProfile(
      id: json['id'] as int? ?? json['driverID'] as int? ?? 0,
      firstname: json['firstname'] as String? ?? '',
      lastname: json['lastname'] as String? ?? '',
      middleName: json['middleName'] as String?,
      gender: json['gender'] as String? ?? '',
      mobileNumber: json['mobileNumber'] as String? ??
          json['phoneNumber'] as String? ??
          '',
      email: json['email'] as String? ?? '',
      address: json['address'] as String? ?? '',
      nationalIdNo: json['nationalIdNo'] as String? ??
          json['nationalIdNumber'] as String? ??
          '',
      driverLicenseNo: json['driverLicenseNo'] as String?,
      approvalStatus: json['approvalStatus'] as String?,
      approvedBy: json['approvedBy'] as String?,
      dateApproved: json['dateApproved'] as String?,
      profilePhotoUrl: json['profilePhotoUrl'] as String?,
      nationalIdImage: json['nationalIdImage'] as String?,
      driversLicenseUrl: json['driversLicenseUrl'] as String?,
      userId: json['userId'] as int? ?? 0,
      walletId: json['walletId'] as int?,
      activeVehicle: json['activeVehicle'] != null
          ? Vehicle.fromJson(json['activeVehicle'] as Map<String, dynamic>)
          : null,
      rating: (json['rating'] as num?)?.toDouble() ?? 0.0,
      walletBalance: (json['walletBalance'] as num?)?.toDouble(),
      onlineStatus: json['onlineStatus'] as bool? ?? false,
      searchRadiusInKm: (json['searchRadiusInKm'] as num?)?.toDouble() ?? 3.0,
      numberOfDeliveries: json['numberOfDeliveries'] as int? ?? 0,
      isBusy: json['isBusy'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'firstname': firstname,
      'lastname': lastname,
      'middleName': middleName,
      'gender': gender,
      'mobileNumber': mobileNumber,
      'email': email,
      'address': address,
      'nationalIdNo': nationalIdNo,
      'driverLicenseNo': driverLicenseNo,
      'approvalStatus': approvalStatus,
      'approvedBy': approvedBy,
      'dateApproved': dateApproved,
      'profilePhotoUrl': profilePhotoUrl,
      'nationalIdImage': nationalIdImage,
      'driversLicenseUrl': driversLicenseUrl,
      'userId': userId,
      'walletId': walletId,
      'activeVehicle': activeVehicle?.toJson(),
      'rating': rating,
      'walletBalance': walletBalance,
      'onlineStatus': onlineStatus,
      'searchRadiusInKm': searchRadiusInKm,
      'numberOfDeliveries': numberOfDeliveries,
      'isBusy': isBusy,
    };
  }
}

@immutable
class AuthResponseData {
  final String accessToken;
  final String refreshToken;
  final String userType;
  final int userID;
  final UserProfile? userProfile;
  final DriverProfile? driverProfile;

  const AuthResponseData({
    required this.accessToken,
    required this.refreshToken,
    required this.userType,
    required this.userID,
    this.userProfile,
    this.driverProfile,
  });

  factory AuthResponseData.fromJson(Map<String, dynamic> json) {
    return AuthResponseData(
      accessToken: json['accessToken'] as String? ?? '',
      refreshToken: json['refreshToken'] as String? ?? '',
      userType: json['userType'] as String? ?? '',
      userID: json['userID'] as int? ?? 0,
      userProfile: json['userProfile'] != null
          ? UserProfile.fromJson(json['userProfile'] as Map<String, dynamic>)
          : null,
      driverProfile: json['driverProfile'] != null
          ? DriverProfile.fromJson(
              json['driverProfile'] as Map<String, dynamic>)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'accessToken': accessToken,
      'refreshToken': refreshToken,
      'userType': userType,
      'userID': userID,
      'userProfile': userProfile?.toJson(),
      'driverProfile': driverProfile?.toJson(),
    };
  }
}
