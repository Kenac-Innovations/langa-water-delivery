class AcceptDeliveryRequest {
  final String driverId;
  final String deliveryId;
  final double latitude;
  final double longitude;

  AcceptDeliveryRequest({
    required this.driverId,
    required this.deliveryId,
    required this.latitude,
    required this.longitude,
  });

  Map<String, dynamic> toJson() {
    return {
      'driver_id': driverId,
      'delivery_id': deliveryId,
      'latitude': latitude,
      'longitude': longitude,
    };
  }
}