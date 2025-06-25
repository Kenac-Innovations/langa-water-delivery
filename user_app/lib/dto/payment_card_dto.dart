import 'package:langas_user/models/payment_card_model.dart';

class CreatePaymentCardRequestDto {
  final int clientId;
  final String cardHolderName;
  final String cardNumber;
  final String expiryDate;
  final String cardType;

  CreatePaymentCardRequestDto({
    required this.clientId,
    required this.cardHolderName,
    required this.cardNumber,
    required this.expiryDate,
    required this.cardType,
  });

  Map<String, dynamic> toJson() => {
        'clientId': clientId,
        'cardHolderName': cardHolderName,
        'cardNumber': cardNumber,
        'expiryDate': expiryDate,
        'cardType': cardType,
      };
}

class UpdatePaymentCardRequestDto {
  final int clientId;
  final String cardHolderName;
  final String cardNumber;
  final String expiryDate;
  final String cardType;

  UpdatePaymentCardRequestDto({
    required this.clientId,
    required this.cardHolderName,
    required this.cardNumber,
    required this.expiryDate,
    required this.cardType,
  });

  Map<String, dynamic> toJson() => {
        'clientId': clientId,
        'cardHolderName': cardHolderName,
        'cardNumber': cardNumber,
        'expiryDate': expiryDate,
        'cardType': cardType,
      };
}

class PaymentCardResponseDto {
  final int id;
  final String cardHolderName;
  final String maskedCardNumber;
  final String expiryDate;
  final String cardType;
  final bool isDefault;

  PaymentCardResponseDto({
    required this.id,
    required this.cardHolderName,
    required this.maskedCardNumber,
    required this.expiryDate,
    required this.cardType,
    required this.isDefault,
  });

  factory PaymentCardResponseDto.fromJson(Map<String, dynamic> json) {
    return PaymentCardResponseDto(
      id: json['id'],
      cardHolderName: json['cardHolderName'],
      maskedCardNumber: json['maskedCardNumber'],
      expiryDate: json['expiryDate'],
      cardType: json['cardType'],
      isDefault: json['isDefault'],
    );
  }

  PaymentCard toDomain() {
    return PaymentCard(
      id: id,
      cardHolderName: cardHolderName,
      maskedCardNumber: maskedCardNumber,
      expiryDate: expiryDate,
      cardType: cardType,
      isDefault: isDefault,
    );
  }
}
