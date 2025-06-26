// ignore_for_file: constant_identifier_names

enum VehicleType {
  BIKE,
  CAR,
  TRUCK,
  VAN;

  String toJson() => name;

  // Helper to parse from string (case-insensitive)
  static VehicleType fromJson(String? value) {
    return VehicleType.values.firstWhere(
      (e) => e.name == value?.toUpperCase(),
      orElse: () => VehicleType.CAR,
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
  CASH,
  VISA,
  ECOCASH;

  String toJson() => name;

  static PaymentMethod fromJson(String? value) {
    return PaymentMethod.values.firstWhere(
      (e) => e.name == value?.toUpperCase(),
      orElse: () => PaymentMethod.CASH,
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

enum VehicleStatus {
  APPROVED,
  REJECTED,
  PENDING,
  SUSPENDED,
  UNKNOWN; // Added fallback

  String toJson() => name;

  static VehicleStatus fromJson(String? value) {
    return VehicleStatus.values.firstWhere(
      (e) => e.name == value?.toUpperCase(),
      orElse: () => VehicleStatus.UNKNOWN, // Default fallback
    );
  }
}
