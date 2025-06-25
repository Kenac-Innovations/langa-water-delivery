import 'package:equatable/equatable.dart';

class PaymentCard extends Equatable {
  final int id;
  final String cardHolderName;
  final String maskedCardNumber;
  final String expiryDate;
  final String cardType;
  final bool isDefault;

  const PaymentCard({
    required this.id,
    required this.cardHolderName,
    required this.maskedCardNumber,
    required this.expiryDate,
    required this.cardType,
    required this.isDefault,
  });

  @override
  List<Object?> get props =>
      [id, cardHolderName, maskedCardNumber, expiryDate, cardType, isDefault];
}
