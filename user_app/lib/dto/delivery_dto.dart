import 'package:langas_user/models/delivery_model.dart';
import 'package:langas_user/models/vehicle_model.dart';
import 'package:langas_user/util/api_pagenated_model.dart';
import 'package:langas_user/util/apps_enums.dart';

class VehicleDto {
  final int vehicleId;
  final String? vehicleModel;
  final String? vehicleColor;
  final String? vehicleMake;
  final String? licensePlateNo;
  final String? vehicleType;

  VehicleDto({
    required this.vehicleId,
    this.vehicleModel,
    this.vehicleColor,
    this.vehicleMake,
    this.licensePlateNo,
    this.vehicleType,
  });

  factory VehicleDto.fromJson(Map<String, dynamic> json) {
    return VehicleDto(
      vehicleId: json['vehicleId'] as int? ?? 0,
      vehicleModel: json['vehicleModel'] as String?,
      vehicleColor: json['vehicleColor'] as String?,
      vehicleMake: json['vehicleMake'] as String?,
      licensePlateNo: json['licensePlateNo'] as String?,
      vehicleType: json['vehicleType'] as String?,
    );
  }

  Vehicle toDomain() {
    return Vehicle(
      vehicleId: vehicleId,
      vehicleModel: vehicleModel,
      vehicleColor: vehicleColor,
      vehicleMake: vehicleMake,
      licensePlateNo: licensePlateNo,
      vehicleType: VehicleType.fromJson(vehicleType),
    );
  }
}

class DeliveryDto {
  final int deliveryId;
  final num? priceAmount;
  final String? currency;
  final bool? autoAssign;
  final String? sensitivity;
  final String? paymentStatus;
  final double? pickupLatitude;
  final double? pickupLongitude;
  final String? pickupLocation;
  final String? pickupContactName;
  final String? pickupContactPhone;
  final double? dropOffLatitude;
  final double? dropOffLongitude;
  final String? dropOffLocation;
  final String? dropOffContactName;
  final String? dropOffContactPhone;
  final String? deliveryInstructions;
  final String? parcelDescription;
  final String? vehicleType;
  final String? paymentMethod;
  final String? deliveryImageUrl;
  final num? packageWeight;
  final String? deliveryStatus;

  DeliveryDto({
    required this.deliveryId,
    this.priceAmount,
    this.currency,
    this.autoAssign,
    this.sensitivity,
    this.paymentStatus,
    this.pickupLatitude,
    this.pickupLongitude,
    this.pickupLocation,
    this.pickupContactName,
    this.pickupContactPhone,
    this.dropOffLatitude,
    this.dropOffLongitude,
    this.dropOffLocation,
    this.dropOffContactName,
    this.dropOffContactPhone,
    this.deliveryInstructions,
    this.parcelDescription,
    this.vehicleType,
    this.paymentMethod,
    this.deliveryImageUrl,
    this.packageWeight,
    this.deliveryStatus,
  });

  factory DeliveryDto.fromJson(Map<String, dynamic> json) {
    return DeliveryDto(
      deliveryId: json['deliveryId'] as int? ?? 0,
      priceAmount: json['priceAmount'] as num?,
      currency: json['currency'] as String?,
      autoAssign: json['autoAssign'] as bool?,
      sensitivity: json['sensitivity'] as String?,
      paymentStatus: json['paymentStatus'] as String?,
      pickupLatitude: (json['pickupLatitude'] as num?)?.toDouble(),
      pickupLongitude: (json['pickupLongitude'] as num?)?.toDouble(),
      pickupLocation: json['pickupLocation'] as String?,
      pickupContactName: json['pickupContactName'] as String?,
      pickupContactPhone: json['pickupContactPhone'] as String?,
      dropOffLatitude: (json['dropOffLatitude'] as num?)?.toDouble(),
      dropOffLongitude: (json['dropOffLongitude'] as num?)?.toDouble(),
      dropOffLocation: json['dropOffLocation'] as String?,
      dropOffContactName: json['dropOffContactName'] as String?,
      dropOffContactPhone: json['dropOffContactPhone'] as String?,
      deliveryInstructions: json['deliveryInstructions'] as String?,
      parcelDescription: json['parcelDescription'] as String?,
      vehicleType: json['vehicleType'] as String?,
      paymentMethod: json['paymentMethod'] as String?,
      deliveryImageUrl: json['deliveryImageUrl'] as String?,
      packageWeight: json['packageWeight'] as num?,
      deliveryStatus: json['deliveryStatus'] as String?,
    );
  }

  Delivery toDomain() {
    return Delivery(
      deliveryId: deliveryId,
      priceAmount: priceAmount ?? 0,
      currency: currency ?? 'USD',
      autoAssign: autoAssign ?? true,
      sensitivity: Sensitivity.fromJson(sensitivity),
      paymentStatus: PaymentStatus.fromJson(paymentStatus),
      pickupLatitude: pickupLatitude ?? 0.0,
      pickupLongitude: pickupLongitude ?? 0.0,
      pickupLocation: pickupLocation ?? '',
      pickupContactName: pickupContactName ?? '',
      pickupContactPhone: pickupContactPhone ?? '',
      dropOffLatitude: dropOffLatitude ?? 0.0,
      dropOffLongitude: dropOffLongitude ?? 0.0,
      dropOffLocation: dropOffLocation ?? '',
      dropOffContactName: dropOffContactName ?? '',
      dropOffContactPhone: dropOffContactPhone ?? '',
      deliveryInstructions: deliveryInstructions,
      parcelDescription: parcelDescription ?? '',
      vehicleType: VehicleType.fromJson(vehicleType),
      paymentMethod: PaymentMethod.fromJson(paymentMethod),
      deliveryImageUrl: deliveryImageUrl,
      packageWeight: packageWeight,
      deliveryStatus: DeliveryStatus.fromJson(deliveryStatus),
    );
  }
}

class CreateDeliveryRequestDto {
  final num priceAmount;
  final bool autoAssign;
  final String currency;
  final Sensitivity sensitivity;
  final double pickupLatitude;
  final double pickupLongitude;
  final String pickupLocation;
  final String pickupContactName;
  final String pickupContactPhone;
  final double dropOffLatitude;
  final double dropOffLongitude;
  final String dropOffLocation;
  final String dropOffContactName;
  final String dropOffContactPhone;
  final String? deliveryInstructions;
  final String parcelDescription;
  final VehicleType vehicleType;
  final PaymentMethod paymentMethod;
  final DateTime deliveryDate;

  CreateDeliveryRequestDto({
    required this.priceAmount,
    this.autoAssign = true,
    this.currency = 'USD',
    required this.sensitivity,
    required this.pickupLatitude,
    required this.pickupLongitude,
    required this.pickupLocation,
    required this.pickupContactName,
    required this.pickupContactPhone,
    required this.dropOffLatitude,
    required this.dropOffLongitude,
    required this.dropOffLocation,
    required this.dropOffContactName,
    required this.dropOffContactPhone,
    this.deliveryInstructions,
    required this.parcelDescription,
    required this.vehicleType,
    required this.paymentMethod,
    required this.deliveryDate,
  });

  Map<String, dynamic> toJson() {
    return {
      'priceAmount': priceAmount,
      'autoAssign': autoAssign,
      'currency': currency,
      'sensitivity': sensitivity.toJson(),
      'pickupLatitude': pickupLatitude,
      'pickupLongitude': pickupLongitude,
      'pickupLocation': pickupLocation,
      'pickupContactName': pickupContactName,
      'pickupContactPhone': pickupContactPhone,
      'dropOffLatitude': dropOffLatitude,
      'dropOffLongitude': dropOffLongitude,
      'dropOffLocation': dropOffLocation,
      'dropOffContactName': dropOffContactName,
      'dropOffContactPhone': dropOffContactPhone,
      'deliveryInstructions': deliveryInstructions,
      'parcelDescription': parcelDescription,
      'vehicleType': vehicleType.toJson(),
      'paymentMethod': paymentMethod.toJson(),
      'deliveryDate': deliveryDate.toIso8601String(),
    };
  }
}

class PaginationDto {
  final int total;
  final int totalPages;
  final int pageNumber;
  final int pageSize;

  PaginationDto({
    required this.total,
    required this.totalPages,
    required this.pageNumber,
    required this.pageSize,
  });

  factory PaginationDto.fromJson(Map<String, dynamic> json) {
    return PaginationDto(
      total: json['total'] as int? ?? 0,
      totalPages: json['totalPages'] as int? ?? json['pages'] as int? ?? 0,
      pageNumber: json['pageNumber'] as int? ?? json['page'] as int? ?? 0,
      pageSize: json['pageSize'] as int? ?? json['limit'] as int? ?? 0,
    );
  }
}

class PaginatedDeliveryResponseDto {
  final List<DeliveryDto>? content;
  final PaginationDto? pagination;

  PaginatedDeliveryResponseDto({
    this.content,
    this.pagination,
  });

  factory PaginatedDeliveryResponseDto.fromJson(Map<String, dynamic> json) {
    return PaginatedDeliveryResponseDto(
      content: (json['content'] as List<dynamic>?)
          ?.map((item) => DeliveryDto.fromJson(item as Map<String, dynamic>))
          .toList(),
      pagination: json['pagination'] != null
          ? PaginationDto.fromJson(json['pagination'] as Map<String, dynamic>)
          : null,
    );
  }

  PaginatedResponse<Delivery> toDomain() {
    return PaginatedResponse(
      content: content?.map((dto) => dto.toDomain()).toList() ?? [],
      pagination: pagination ??
          PaginationDto(total: 0, totalPages: 0, pageNumber: 0, pageSize: 0),
    );
  }
}

class SelectDriverRequestDto {
  final int deliveryId;
  final int driverId;

  SelectDriverRequestDto({required this.deliveryId, required this.driverId});

  Map<String, dynamic> toJson() {
    return {
      'deliveryId': deliveryId,
      'driverId': driverId,
    };
  }
}

class CancelDeliveryRequestDto {
  final int deliveryId;
  final String reason;

  CancelDeliveryRequestDto({required this.deliveryId, required this.reason});

  Map<String, dynamic> toJson() {
    return {
      'deliveryId': deliveryId,
      'reason': reason,
    };
  }
}

class CreatePaymentRequestDto {
  final int deliveryId;
  final PaymentMethod paymentMethod;
  final PaymentStatus paymentStatus;
  final String amountPaid;

  CreatePaymentRequestDto({
    required this.deliveryId,
    required this.paymentMethod,
    required this.paymentStatus,
    required this.amountPaid,
  });

  Map<String, dynamic> toJson() {
    return {
      'deliveryId': deliveryId,
      'paymentMethod': paymentMethod.toJson(),
      'paymentStatus': paymentStatus.toJson(),
      'amountPaid': amountPaid,
    };
  }
}

class PriceGeneratorRequestDto {
  final VehicleType vehicleType;
  final String currency;
  final Sensitivity sensitivity;
  final double distance;

  PriceGeneratorRequestDto({
    required this.vehicleType,
    this.currency = 'USD',
    required this.sensitivity,
    required this.distance,
  });

  Map<String, dynamic> toJson() {
    return {
      'vehicleType': vehicleType.toJson(),
      'currency': currency,
      'sensitivity': sensitivity.toJson(),
      'distance': distance,
    };
  }
}
