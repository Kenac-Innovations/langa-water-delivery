// ignore_for_file: constant_identifier_names

enum VehicleType {
  BIKE,
  CAR,
  TRUCK;

  String toJson() => name;

  // Helper to parse from string (case-insensitive)
  static VehicleType fromJson(String? value) {
    return VehicleType.values.firstWhere(
      (e) => e.name == value?.toUpperCase(),
      orElse: () => VehicleType.CAR, // Default fallback
    );
  }
}

enum Sensitivity {
  BASIC,
  PREMIUM;

  String toJson() => name;

  static Sensitivity fromJson(String? value) {
    return Sensitivity.values.firstWhere(
      (e) => e.name == value?.toUpperCase(),
      orElse: () => Sensitivity.BASIC,
    );
  }
}

enum PaymentMethod {
  E_MONEY,
  CASH;

  String toJson() => name;

  static PaymentMethod fromJson(String? value) {
    return PaymentMethod.values.firstWhere(
      (e) => e.name == value?.toUpperCase(),
      orElse: () => PaymentMethod.CASH, // Or E_MONEY as default?
    );
  }
}

enum DeliveryStatus {
  OPEN,
  ASSIGNED,
  PICKED_UP,
  COMPLETED,
  CANCELLED,
  UNKNOWN;

  String toJson() => name;

  static DeliveryStatus fromJson(String? value) {
    return DeliveryStatus.values.firstWhere(
      (e) => e.name == value?.toUpperCase(),
      orElse: () => DeliveryStatus.UNKNOWN,
    );
  }
}

enum PaymentStatus {
  PENDING,
  PAID,
  FAILED,
  UNKNOWN;

  String toJson() => name;

  static PaymentStatus fromJson(String? value) {
    return PaymentStatus.values.firstWhere(
      (e) => e.name == value?.toUpperCase(),
      orElse: () => PaymentStatus.UNKNOWN,
    );
  }
}

enum NotificationType {
  WARNING,
  INFO,
  PROMOTIONAL,
  EXCEPTION,
  UNKNOWN;

  String toJson() => name;

  static NotificationType fromJson(String? value) {
    return NotificationType.values.firstWhere(
      (e) => e.name == value?.toUpperCase(),
      orElse: () => NotificationType.UNKNOWN,
    );
  }
}