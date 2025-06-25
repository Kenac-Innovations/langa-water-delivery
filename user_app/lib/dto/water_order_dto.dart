import 'package:langas_user/dto/delivery_dto.dart';
import 'package:langas_user/dto/pagination_dto.dart';
import 'package:langas_user/models/water_order_model.dart';
import 'package:langas_user/util/api_pagenated_model.dart';
import 'package:langas_user/util/apps_enums.dart';

class CreateWaterOrderRequestDto {
  final int clientId;
  final WaterPaymentType paymentType;
  final String? promoCode;
  final List<WaterDeliveryRequestDto> deliveries;
  final WaterPaymentStatus paymentStatus;
  final double totalAmount;

  CreateWaterOrderRequestDto({
    required this.clientId,
    required this.paymentType,
    this.promoCode,
    required this.deliveries,
    required this.paymentStatus,
    required this.totalAmount,
  });

  Map<String, dynamic> toJson() {
    return {
      'clientId': clientId,
      'paymentType': paymentType.toJson(),
      'promoCode': promoCode,
      'deliveries': deliveries.map((d) => d.toJson()).toList(),
      'paymentStatus': paymentStatus.toJson(),
      'totalAmount': totalAmount,
    };
  }
}

class WaterDeliveryRequestDto {
  final double priceAmount;
  final bool autoAssignDriver;
  final DropOffLocationRequestDto dropOffLocation;
  final bool isScheduled;
  final int quantity;
  final String? deliveryInstructions;
  final ScheduledDetailsRequestDto? scheduledDetails;

  WaterDeliveryRequestDto({
    required this.priceAmount,
    this.autoAssignDriver = true,
    required this.dropOffLocation,
    required this.isScheduled,
    required this.quantity,
    this.deliveryInstructions,
    this.scheduledDetails,
  });

  Map<String, dynamic> toJson() {
    return {
      'priceAmount': priceAmount,
      'autoAssignDriver': autoAssignDriver,
      'dropOffLocation': dropOffLocation.toJson(),
      'isScheduled': isScheduled,
      'quantity': quantity,
      'deliveryInstructions': deliveryInstructions,
      'scheduledDetails': scheduledDetails?.toJson(),
    };
  }
}

class DropOffLocationRequestDto {
  final bool useMyContact;
  final int? addressId;
  final double dropOffLatitude;
  final double dropOffLongitude;
  final String dropOffLocation;
  final String? dropOffAddressTyped;
  final String dropOffContactName;
  final String dropOffContactPhone;

  DropOffLocationRequestDto({
    required this.useMyContact,
    this.addressId,
    required this.dropOffLatitude,
    required this.dropOffLongitude,
    required this.dropOffLocation,
    this.dropOffAddressTyped,
    required this.dropOffContactName,
    required this.dropOffContactPhone,
  });

  Map<String, dynamic> toJson() {
    return {
      'useMyContact': useMyContact,
      'addressId': addressId,
      'dropOffLatitude': dropOffLatitude,
      'dropOffLongitude': dropOffLongitude,
      'dropOffLocation': dropOffLocation,
      'dropOffAddressTyped': dropOffAddressTyped,
      'dropOffContactName': dropOffContactName,
      'dropOffContactPhone': dropOffContactPhone,
    };
  }
}

class ScheduledDetailsRequestDto {
  final String scheduledDate;
  final String scheduledTime;

  ScheduledDetailsRequestDto({
    required this.scheduledDate,
    required this.scheduledTime,
  });

  Map<String, dynamic> toJson() {
    return {
      'scheduledDate': scheduledDate,
      'scheduledTime': scheduledTime,
    };
  }
}

class WaterOrderResponseDto {
  final int orderId;
  final int clientId;
  final String clientName;
  final String? deliveryAddress;
  final String? specialInstructions;
  final WaterOrderStatus orderStatus;
  final WaterPaymentStatus paymentStatus;
  final double totalAmount;
  final DateTime orderDate;
  final List<WaterDeliveryResponseDto> deliveries;

  WaterOrderResponseDto({
    required this.orderId,
    required this.clientId,
    required this.clientName,
    this.deliveryAddress,
    this.specialInstructions,
    required this.orderStatus,
    required this.paymentStatus,
    required this.totalAmount,
    required this.orderDate,
    required this.deliveries,
  });

  factory WaterOrderResponseDto.fromJson(Map<String, dynamic> json) {
    return WaterOrderResponseDto(
      orderId: json['orderId'],
      clientId: json['clientId'],
      clientName: json['clientName'],
      deliveryAddress: json['deliveryAddress'],
      specialInstructions: json['specialInstructions'],
      orderStatus: WaterOrderStatus.fromJson(json['orderStatus']),
      paymentStatus: WaterPaymentStatus.fromJson(json['paymentStatus']),
      totalAmount: (json['totalAmount'] as num).toDouble(),
      orderDate: DateTime.parse(json['orderDate']),
      deliveries: (json['deliveries'] as List)
          .map((d) => WaterDeliveryResponseDto.fromJson(d))
          .toList(),
    );
  }

  WaterOrder toDomain() {
    return WaterOrder(
      orderId: orderId,
      clientId: clientId,
      clientName: clientName,
      deliveryAddress: deliveryAddress,
      specialInstructions: specialInstructions,
      orderStatus: orderStatus,
      paymentStatus: paymentStatus,
      totalAmount: totalAmount,
      orderDate: orderDate,
      deliveries: deliveries.map((d) => d.toDomain()).toList(),
    );
  }
}

class WaterDeliveryResponseDto {
  final int deliveryId;
  final double priceAmount;
  final bool? autoAssignDriver;
  final DropOffLocationResponseDto dropOffLocation;
  final bool? isScheduled;
  final int quantity;
  final String? deliveryInstructions;
  final ScheduledDetailsResponseDto? scheduledDetails;
  final WaterDeliveryStatus status;

  WaterDeliveryResponseDto({
    required this.deliveryId,
    required this.priceAmount,
    this.autoAssignDriver,
    required this.dropOffLocation,
    this.isScheduled,
    required this.quantity,
    this.deliveryInstructions,
    this.scheduledDetails,
    required this.status,
  });

  factory WaterDeliveryResponseDto.fromJson(Map<String, dynamic> json) {
    return WaterDeliveryResponseDto(
      deliveryId: json['deliveryId'],
      priceAmount: (json['priceAmount'] as num).toDouble(),
      autoAssignDriver: json['autoAssignDriver'],
      dropOffLocation:
          DropOffLocationResponseDto.fromJson(json['dropOffLocation']),
      isScheduled: json['isScheduled'],
      quantity: json['quantity'] ?? 0,
      deliveryInstructions: json['deliveryInstructions'],
      scheduledDetails: json['scheduledDetails'] != null
          ? ScheduledDetailsResponseDto.fromJson(json['scheduledDetails'])
          : null,
      status: WaterDeliveryStatus.fromJson(json['status']),
    );
  }

  WaterDelivery toDomain() {
    return WaterDelivery(
      deliveryId: deliveryId,
      priceAmount: priceAmount,
      autoAssignDriver: autoAssignDriver,
      dropOffLocation: dropOffLocation.toDomain(),
      isScheduled: isScheduled,
      quantity: quantity,
      deliveryInstructions: deliveryInstructions,
      scheduledDetails: scheduledDetails?.toDomain(),
      status: status,
    );
  }
}

class DropOffLocationResponseDto {
  final double dropOffLatitude;
  final double dropOffLongitude;
  final String dropOffLocation;
  final String? dropOffAddressType;
  final String dropOffContactName;
  final String dropOffContactPhone;

  DropOffLocationResponseDto({
    required this.dropOffLatitude,
    required this.dropOffLongitude,
    required this.dropOffLocation,
    this.dropOffAddressType,
    required this.dropOffContactName,
    required this.dropOffContactPhone,
  });

  factory DropOffLocationResponseDto.fromJson(Map<String, dynamic> json) {
    return DropOffLocationResponseDto(
      dropOffLatitude: (json['dropOffLatitude'] as num).toDouble(),
      dropOffLongitude: (json['dropOffLongitude'] as num).toDouble(),
      dropOffLocation: json['dropOffLocation'],
      dropOffAddressType: json['dropOffAddressType'],
      dropOffContactName: json['dropOffContactName'],
      dropOffContactPhone: json['dropOffContactPhone'],
    );
  }

  WaterDropOffLocation toDomain() {
    return WaterDropOffLocation(
      dropOffLatitude: dropOffLatitude,
      dropOffLongitude: dropOffLongitude,
      dropOffLocation: dropOffLocation,
      dropOffAddressType: dropOffAddressType,
      dropOffContactName: dropOffContactName,
      dropOffContactPhone: dropOffContactPhone,
    );
  }
}

class ScheduledDetailsResponseDto {
  final String scheduledDate;
  final String? scheduledTime;

  ScheduledDetailsResponseDto({
    required this.scheduledDate,
    this.scheduledTime,
  });

  factory ScheduledDetailsResponseDto.fromJson(Map<String, dynamic> json) {
    return ScheduledDetailsResponseDto(
      scheduledDate: json['scheduledDate'],
      scheduledTime: json['scheduledTime'],
    );
  }

  ScheduledDetails toDomain() {
    return ScheduledDetails(
      scheduledDate: scheduledDate,
      scheduledTime: scheduledTime,
    );
  }
}

class PaginatedWaterOrderResponseDto {
  final List<WaterOrderResponseDto> content;
  final PaginationDto pagination;

  PaginatedWaterOrderResponseDto(
      {required this.content, required this.pagination});

  factory PaginatedWaterOrderResponseDto.fromJson(Map<String, dynamic> json) {
    return PaginatedWaterOrderResponseDto(
      content: (json['content'] as List)
          .map((i) => WaterOrderResponseDto.fromJson(i))
          .toList(),
      pagination: PaginationDto.fromJson(json['pagination']),
    );
  }

  PaginatedResponse<WaterOrder> toDomain() {
    return PaginatedResponse<WaterOrder>(
      content: content.map((e) => e.toDomain()).toList(),
      pagination: pagination,
    );
  }
}
