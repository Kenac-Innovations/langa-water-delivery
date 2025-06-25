import 'package:equatable/equatable.dart';

class ClientAddress extends Equatable {
  final int entityId;
  final String title;
  final String addressEntered;
  final bool isDefault;
  final int clientId;
  final double latitude;
  final double longitude;
  final String addressFormatted;
  final String geohash;

  const ClientAddress({
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

  @override
  List<Object?> get props => [
        entityId,
        title,
        addressEntered,
        isDefault,
        clientId,
        latitude,
        longitude,
        addressFormatted,
        geohash
      ];
}
