import 'package:equatable/equatable.dart';

class Promotion extends Equatable {
  final int entityId;
  final String createdDate;
  final String lastModifiedDate;
  final String title;
  final String description;
  final String promoCode;
  final bool isActive;
  final String startDate;
  final String endDate;
  final num discountPercentage;

  const Promotion({
    required this.entityId,
    required this.createdDate,
    required this.lastModifiedDate,
    required this.title,
    required this.description,
    required this.promoCode,
    required this.isActive,
    required this.startDate,
    required this.endDate,
    required this.discountPercentage,
  });

  @override
  List<Object?> get props => [
        entityId,
        title,
        promoCode,
        isActive,
        startDate,
        endDate,
        discountPercentage
      ];

  factory Promotion.fromJson(Map<String, dynamic> json) {
    return Promotion(
      entityId: json['entityId'] as int,
      createdDate: json['createdDate'] as String,
      lastModifiedDate: json['lastModifiedDate'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      promoCode: json['promoCode'] as String,
      isActive: json['isActive'] as bool,
      startDate: json['startDate'] as String,
      endDate: json['endDate'] as String,
      discountPercentage: json['discountPercentage'] as num,
    );
  }
}