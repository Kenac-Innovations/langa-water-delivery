import 'package:langas_user/models/client_address_model.dart';

class CreateClientAddressDto {
  final String title;
  final String addressEntered;
  final double latitude;
  final double longitude;
  final String addressFormatted;
  final String geohash;
  final int clientId;

  CreateClientAddressDto({
    required this.title,
    required this.addressEntered,
    required this.latitude,
    required this.longitude,
    required this.addressFormatted,
    required this.geohash,
    required this.clientId,
  });

  Map<String, dynamic> toJson() => {
        'title': title,
        'addressEntered': addressEntered,
        'latitude': latitude,
        'longitude': longitude,
        'addressFormatted': addressFormatted,
        'geohash': geohash,
        'clientId': clientId,
      };
}

class UpdateClientAddressDto {
  final String title;
  final String addressEntered;
  final double latitude;
  final double longitude;
  final String addressFormatted;
  final String geohash;

  UpdateClientAddressDto({
    required this.title,
    required this.addressEntered,
    required this.latitude,
    required this.longitude,
    required this.addressFormatted,
    required this.geohash,
  });

  Map<String, dynamic> toJson() => {
        'title': title,
        'addressEntered': addressEntered,
        'latitude': latitude,
        'longitude': longitude,
        'addressFormatted': addressFormatted,
        'geohash': geohash,
      };
}

class ClientAddressResponseDto {
  final int entityId;
  final String title;
  final String addressEntered;
  final bool isDefault;
  final int clientId;
  final double latitude;
  final double longitude;
  final String addressFormatted;
  final String geohash;

  ClientAddressResponseDto({
    required this.entityId,
    required this.title,
    required this.addressEntered,
    required this.isDefault,
    required this.clientId,
    required this.latitude,
    required this.longitude,
    required this.addressFormatted,
    required this.geohash,
  });

  factory ClientAddressResponseDto.fromJson(Map<String, dynamic> json) {
    return ClientAddressResponseDto(
      entityId: json['entityId'],
      title: json['title'],
      addressEntered: json['addressEntered'],
      isDefault: json['isDefault'],
      clientId: json['clientId'],
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      addressFormatted: json['addressFormatted'],
      geohash: json['geohash'],
    );
  }

  ClientAddress toDomain() {
    return ClientAddress(
      entityId: entityId,
      title: title,
      addressEntered: addressEntered,
      isDefault: isDefault,
      clientId: clientId,
      latitude: latitude,
      longitude: longitude,
      addressFormatted: addressFormatted,
      geohash: geohash,
    );
  }
}