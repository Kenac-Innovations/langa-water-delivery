// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

class Address {
  final int id;
  final int userId;
  final String nickName;
  final String streetAddress;
  final String city;
  final String country;
  final double latitude;
  final double longitude;
  final DateTime createdAt;
  final DateTime updatedAt;
  Address({
    required this.id,
    required this.userId,
    required this.nickName,
    required this.streetAddress,
    required this.city,
    required this.country,
    required this.latitude,
    required this.longitude,
    required this.createdAt,
    required this.updatedAt,
  });

  Address copyWith({
    int? id,
    int? userId,
    String? nickName,
    String? streetAddress,
    String? city,
    String? country,
    double? latitude,
    double? longitude,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Address(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      nickName: nickName ?? this.nickName,
      streetAddress: streetAddress ?? this.streetAddress,
      city: city ?? this.city,
      country: country ?? this.country,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'userId': userId,
      'nickName': nickName,
      'streetAddress': streetAddress,
      'city': city,
      'country': country,
      'latitude': latitude,
      'longitude': longitude,
      'createdAt': createdAt.millisecondsSinceEpoch,
      'updatedAt': updatedAt.millisecondsSinceEpoch,
    };
  }

  factory Address.fromMap(Map<String, dynamic> map) {
    return Address(
      id: map['id'] as int,
      userId: map['userId'] as int,
      nickName: map['nickName'] as String,
      streetAddress: map['streetAddress'] as String,
      city: map['city'] as String,
      country: map['country'] as String,
      latitude: map['latitude'] as double,
      longitude: map['longitude'] as double,
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['createdAt'] as int),
      updatedAt: DateTime.fromMillisecondsSinceEpoch(map['updatedAt'] as int),
    );
  }

  String toJson() => json.encode(toMap());

  factory Address.fromJson(String source) =>
      Address.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'Address(id: $id, userId: $userId, nickName: $nickName, streetAddress: $streetAddress, city: $city, country: $country, latitude: $latitude, longitude: $longitude, createdAt: $createdAt, updatedAt: $updatedAt)';
  }

  @override
  bool operator ==(covariant Address other) {
    if (identical(this, other)) return true;

    return other.id == id &&
        other.userId == userId &&
        other.nickName == nickName &&
        other.streetAddress == streetAddress &&
        other.city == city &&
        other.country == country &&
        other.latitude == latitude &&
        other.longitude == longitude &&
        other.createdAt == createdAt &&
        other.updatedAt == updatedAt;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        userId.hashCode ^
        nickName.hashCode ^
        streetAddress.hashCode ^
        city.hashCode ^
        country.hashCode ^
        latitude.hashCode ^
        longitude.hashCode ^
        createdAt.hashCode ^
        updatedAt.hashCode;
  }
}
