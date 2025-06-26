// ignore_for_file: constant_identifier_names

enum TransactionType {
  PAYMENT,
  TRANSFER,
  COMMISSION,
  WITHDRAWAL,
  DEPOSIT,
  CHARGE,
  UNKNOWN;

  String toJson() => name;
  static TransactionType fromJson(String? value) {
    return TransactionType.values.firstWhere(
      (e) => e.name.toUpperCase() == value?.toUpperCase().replaceAll(" ", "_"),
      orElse: () => TransactionType.UNKNOWN,
    );
  }
}

enum WalletOwnerType {
  Langa's_SYSTEM,
  ORGANIZATION,
  DRIVER,
  UNKNOWN;

  String toJson() => name;
  static WalletOwnerType fromJson(String? value) {
    return WalletOwnerType.values.firstWhere(
      (e) => e.name.toUpperCase() == value?.toUpperCase().replaceAll(" ", "_"),
      orElse: () => WalletOwnerType.UNKNOWN,
    );
  }
}

enum WalletBalanceType {
  CASH,
  E_MONEY,
  UNKNOWN;

  String toJson() => name;
  static WalletBalanceType fromJson(String? value) {
    return WalletBalanceType.values.firstWhere(
      (e) => e.name.toUpperCase() == value?.toUpperCase().replaceAll(" ", "_"),
      orElse: () => WalletBalanceType.UNKNOWN,
    );
  }
}

enum WalletAccountType {
  E_MONEY,
  CASH,
  SYSTEM_MAIN_SUSPENSE,
  SYSTEM_CHARGE_SUSPENSE,
  ORG_MAIN_SUSPENSE,
  DRIVER_MAIN_SUSPENSE,
  UNKNOWN;

  String toJson() => name;
  static WalletAccountType fromJson(String? value) {
    return WalletAccountType.values.firstWhere(
      (e) => e.name.toUpperCase() == value?.toUpperCase().replaceAll(" ", "_"),
      orElse: () => WalletAccountType.UNKNOWN,
    );
  }
}

enum WalletAccountStatus {
  AWAITING_APPROVAL,
  ACTIVE,
  INACTIVE,
  SUSPENDED,
  DISAPPROVED,
  DELETED,
  UNKNOWN;

  String toJson() => name;
  static WalletAccountStatus fromJson(String? value) {
    return WalletAccountStatus.values.firstWhere(
      (e) => e.name.toUpperCase() == value?.toUpperCase().replaceAll(" ", "_"),
      orElse: () => WalletAccountStatus.UNKNOWN,
    );
  }
}

enum TransactionStatus {
  PENDING,
  COMPLETED,
  FAILED,
  REVERSED,
  CANCELED,
  PAID,
  AWAITING_DELIVERY,
  DELIVERED,
  CREATED,
  SENT,
  DISPUTED,
  REFUNDED,
  UNKNOWN;

  String toJson() => name;
  static TransactionStatus fromJson(String? value) {
    if (value == null) return TransactionStatus.UNKNOWN;
    // Handle potential spelling difference for CANCELLED/CANCELED
    final normalizedValue = value.toUpperCase().replaceAll(" ", "_");
    if (normalizedValue == "CANCELED") return TransactionStatus.CANCELED;
    if (normalizedValue == "CANCELLED") return TransactionStatus.CANCELED;

    return TransactionStatus.values.firstWhere(
      (e) => e.name.toUpperCase() == normalizedValue,
      orElse: () => TransactionStatus.UNKNOWN,
    );
  }

  bool isSuccessful() {
    return this == PAID ||
        this == AWAITING_DELIVERY ||
        this == DELIVERED ||
        this == COMPLETED;
  }
}

enum WalletCurrency {
  ZIG,
  USD,
  UNKNOWN;

  String toJson() => name;
  static WalletCurrency fromJson(String? value) {
    return WalletCurrency.values.firstWhere(
      (e) => e.name.toUpperCase() == value?.toUpperCase().replaceAll(" ", "_"),
      orElse: () => WalletCurrency.UNKNOWN,
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
    if (value == null) return NotificationType.UNKNOWN;
    return NotificationType.values.firstWhere(
      (e) => e.name.toUpperCase() == value.toUpperCase().replaceAll(" ", "_"),
      orElse: () => NotificationType.UNKNOWN,
    );
  }
}
