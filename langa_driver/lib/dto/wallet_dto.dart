import 'package:flutter/material.dart';
import 'package:langas_driver/utils/delivery_enums.dart';

@immutable
class DriverWalletDepositRequest {
  final int driverId;
  final double amount;
  final int currencyId;
  final String phoneNumber;
  final PaymentMethod paymentMethod;

  const DriverWalletDepositRequest({
    required this.driverId,
    required this.amount,
    required this.currencyId,
    required this.phoneNumber,
    required this.paymentMethod,
  });

  Map<String, dynamic> toJson() {
    return {
      'driverId': driverId,
      'amount': amount,
      'currencyId': currencyId,
      'phoneNumber': phoneNumber,
      'paymentMethod': paymentMethod.name,
    };
  }
}
