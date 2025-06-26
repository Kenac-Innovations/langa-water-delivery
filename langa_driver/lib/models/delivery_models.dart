import 'package:flutter/foundation.dart' show immutable, required;
import 'package:langas_driver/utils/delivery_enums.dart';

@immutable
class Customer {
  static int _parseInt(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    if (value is String) {
      return int.tryParse(value) ?? 0;
    }
    if (value is double) return value.toInt();
    return 0;
  }

  final int clientId;
  final String firstname;
  final String lastname;
  final String mobileNumber;
  final String emailAddress;

  const Customer({
    required this.clientId,
    required this.firstname,
    required this.lastname,
    required this.mobileNumber,
    required this.emailAddress,
  });

  factory Customer.fromJson(Map<String, dynamic> json) {
    return Customer(
      clientId: json['clientId'] as int? ?? 0,
      firstname: json['firstname'] as String? ?? '',
      lastname: json['lastname'] as String? ?? '',
      mobileNumber: json['mobileNumber'] as String? ?? '',
      emailAddress: json['emailAddress'] as String? ?? '',
    );
  }

  factory Customer.fromFirebase(Map<String, dynamic> json) {
    return Customer(
      clientId: Customer._parseInt(json['id']),
      firstname: json['firstname'] as String? ?? '',
      lastname: json['lastname'] as String? ?? '',
      mobileNumber: json['mobileNumber'] as String? ?? '',
      emailAddress: json['emailAddress'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'clientId': clientId,
      'firstname': firstname,
      'lastname': lastname,
      'mobileNumber': mobileNumber,
      'emailAddress': emailAddress,
    };
  }
}

@immutable
class DeliveryVehicleInfo {
  final int vehicleId;
  final String vehicleModel;
  final String vehicleColor;
  final String vehicleMake;
  final String licensePlateNo;
  final VehicleType vehicleType;

  const DeliveryVehicleInfo({
    required this.vehicleId,
    required this.vehicleModel,
    required this.vehicleColor,
    required this.vehicleMake,
    required this.licensePlateNo,
    required this.vehicleType,
  });

  factory DeliveryVehicleInfo.fromJson(Map<String, dynamic> json) {
    return DeliveryVehicleInfo(
      vehicleId: json['vehicleId'] as int? ?? 0,
      vehicleModel: json['vehicleModel'] as String? ?? '',
      vehicleColor: json['vehicleColor'] as String? ?? '',
      vehicleMake: json['vehicleMake'] as String? ?? '',
      licensePlateNo: json['licensePlateNo'] as String? ?? '',
      vehicleType: VehicleType.fromJson(json['vehicleType'] as String?),
    );
  }

  factory DeliveryVehicleInfo.fromFirebase(Map<String, dynamic> json) {
    return DeliveryVehicleInfo(
      vehicleId: Customer._parseInt(json['id']),
      vehicleModel: json['vehicleModel'] as String? ?? '',
      vehicleColor: json['vehicleColor'] as String? ?? '',
      vehicleMake: json['vehicleMake'] as String? ?? '',
      licensePlateNo: json['licensePlateNo'] as String? ?? '',
      vehicleType: VehicleType.fromJson(json['vehicleType'] as String?),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'vehicleId': vehicleId,
      'vehicleModel': vehicleModel,
      'vehicleColor': vehicleColor,
      'vehicleMake': vehicleMake,
      'licensePlateNo': licensePlateNo,
      'vehicleType': vehicleType.toJson(),
    };
  }
}

@immutable
class Pagination {
  final int total;
  final int totalPages;
  final int pageNumber;
  final int pageSize;

  const Pagination({
    required this.total,
    required this.totalPages,
    required this.pageNumber,
    required this.pageSize,
  });

  factory Pagination.fromJson(Map<String, dynamic> json) {
    return Pagination(
      total: json['total'] as int? ?? 0,
      totalPages: json['totalPages'] as int? ?? 0,
      pageNumber: json['pageNumber'] as int? ?? 0,
      pageSize: json['pageSize'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'total': total,
      'totalPages': totalPages,
      'pageNumber': pageNumber,
      'pageSize': pageSize,
    };
  }
}

@immutable
class Delivery {
  final int deliverId;
  final double priceAmount;
  final String currency;
  final Sensitivity sensitivity;
  final PaymentStatus paymentStatus;
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
  final String? deliveryImageUrl;
  final double packageWeight;
  final DeliveryStatus deliveryStatus;
  final Customer customer;
  final DeliveryVehicleInfo? vehicle;
  final bool isProposed;
  final double commissionRequired;
  final int numberOfSeats;
  final String deliveryType;
  final bool isScheduled;

  const Delivery({
    required this.deliverId,
    required this.priceAmount,
    required this.currency,
    required this.sensitivity,
    required this.paymentStatus,
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
    this.deliveryImageUrl,
    required this.packageWeight,
    required this.deliveryStatus,
    required this.customer,
    this.vehicle,
    required this.isProposed,
    required this.commissionRequired,
    required this.numberOfSeats,
    required this.deliveryType,
    required this.isScheduled,
  });

  factory Delivery.fromJson(Map<String, dynamic> json) {
    return Delivery(
      deliverId: (json['deliverId'] ?? json['deliveryId']) as int? ?? 0,
      priceAmount: (json['priceAmount'] as num?)?.toDouble() ?? 0.0,
      currency: json['currency'] as String? ?? '',
      sensitivity: Sensitivity.fromJson(json['sensitivity'] as String?),
      paymentStatus: PaymentStatus.fromJson(json['paymentStatus'] as String?),
      pickupLatitude: (json['pickupLatitude'] as num?)?.toDouble() ?? 0.0,
      pickupLongitude: (json['pickupLongitude'] as num?)?.toDouble() ?? 0.0,
      pickupLocation: json['pickupLocation'] as String? ?? '',
      pickupContactName: json['pickupContactName'] as String? ?? '',
      pickupContactPhone: json['pickupContactPhone'] as String? ?? '',
      dropOffLatitude: (json['dropOffLatitude'] as num?)?.toDouble() ?? 0.0,
      dropOffLongitude: (json['dropOffLongitude'] as num?)?.toDouble() ?? 0.0,
      dropOffLocation: json['dropOffLocation'] as String? ?? '',
      dropOffContactName: json['dropOffContactName'] as String? ?? '',
      dropOffContactPhone: json['dropOffContactPhone'] as String? ?? '',
      deliveryInstructions: json['deliveryInstructions'] as String?,
      parcelDescription: json['parcelDescription'] as String? ?? '',
      vehicleType: VehicleType.fromJson(json['vehicleType'] as String?),
      paymentMethod: PaymentMethod.fromJson(json['paymentMethod'] as String?),
      deliveryImageUrl: json['deliveryImageUrl'] as String?,
      packageWeight: (json['packageWeight'] as num?)?.toDouble() ?? 0.0,
      isProposed: json['isProposed'] as bool? ?? false,
      commissionRequired:
          (json['commissionRequired'] as num?)?.toDouble() ?? 0.0,
      deliveryStatus:
          DeliveryStatus.fromJson(json['deliveryStatus'] as String?),
      customer:
          Customer.fromJson(json['customer'] as Map<String, dynamic>? ?? {}),
      vehicle: json['vehicle'] != null
          ? DeliveryVehicleInfo.fromJson(
              json['vehicle'] as Map<String, dynamic>)
          : null,
      numberOfSeats: json['numberOfSeats'] as int? ?? 0,
      deliveryType: json['deliveryType'] as String? ?? 'PARCEL',
      isScheduled: json['isScheduled'] as bool? ?? false,
    );
  }

  factory Delivery.fromFirebase(Map<String, dynamic> json) {
    return Delivery(
      deliverId: _parseInt(json['id']),
      priceAmount: _parseDouble(json['priceAmount']),
      currency: json['currency'] as String? ?? '',
      sensitivity: Sensitivity.fromJson(json['sensitivity'] as String?),
      paymentStatus: PaymentStatus.fromJson(json['paymentStatus'] as String?),
      pickupLatitude: (json['pickupLatitude'] as num?)?.toDouble() ?? 0.0,
      pickupLongitude: (json['pickupLongitude'] as num?)?.toDouble() ?? 0.0,
      pickupLocation: json['pickupLocation'] as String? ?? '',
      pickupContactName: json['pickupContactName'] as String? ?? '',
      pickupContactPhone: json['pickupContactPhone'] as String? ?? '',
      dropOffLatitude: (json['dropOffLatitude'] as num?)?.toDouble() ?? 0.0,
      dropOffLongitude: (json['dropOffLongitude'] as num?)?.toDouble() ?? 0.0,
      dropOffLocation: json['dropOffLocation'] as String? ?? '',
      dropOffContactName: json['dropOffContactName'] as String? ?? '',
      dropOffContactPhone: json['dropOffContactPhone'] as String? ?? '',
      deliveryInstructions: json['deliveryInstructions'] as String?,
      parcelDescription: json['parcelDescription'] as String? ?? '',
      vehicleType: VehicleType.fromJson(json['vehicleType'] as String?),
      paymentMethod: PaymentMethod.fromJson(json['paymentMethod'] as String?),
      deliveryImageUrl: json['deliveryImageUrl'] as String?,
      packageWeight: (json['packageWeight'] as num?)?.toDouble() ?? 0.0,
      isProposed: json['isProposed'] as bool? ?? false,
      deliveryStatus:
          DeliveryStatus.fromJson(json['deliveryStatus'] as String?),
      commissionRequired: _parseDouble(json['commissionRequired']),
      customer: json['client'] != null
          ? Customer.fromFirebase(json['client'] as Map<String, dynamic>)
          : const Customer(
              clientId: 0,
              firstname: '',
              lastname: '',
              mobileNumber: '',
              emailAddress: '',
            ),
      vehicle: json['vehicle'] != null
          ? DeliveryVehicleInfo.fromFirebase(
              json['vehicle'] as Map<String, dynamic>)
          : null,
      numberOfSeats: _parseInt(json['numberOfSeats']),
      deliveryType: json['deliveryType'] as String? ?? 'PARCEL',
      isScheduled: json['isScheduled'] as bool? ?? false,
    );
  }

  static int _parseInt(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    if (value is String) {
      return int.tryParse(value) ?? 0;
    }
    if (value is double) return value.toInt();
    return 0;
  }

  static double _parseDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) {
      return double.tryParse(value) ?? 0.0;
    }
    return 0.0;
  }

  Map<String, dynamic> toJson() {
    return {
      'deliveryId': deliverId,
      'priceAmount': priceAmount,
      'currency': currency,
      'sensitivity': sensitivity.toJson(),
      'paymentStatus': paymentStatus.toJson(),
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
      'deliveryImageUrl': deliveryImageUrl,
      'packageWeight': packageWeight,
      'deliveryStatus': deliveryStatus.toJson(),
      'customer': customer.toJson(),
      'vehicle': vehicle?.toJson(),
      'isProposed': isProposed,
      'commissionRequired': commissionRequired,
      'numberOfSeats': numberOfSeats,
      'deliveryType': deliveryType,
      'isScheduled': isScheduled,
    };
  }
}

@immutable
class PaginatedDeliveryResponse {
  final List<Delivery> content;
  final Pagination pagination;

  const PaginatedDeliveryResponse({
    required this.content,
    required this.pagination,
  });

  factory PaginatedDeliveryResponse.fromJson(Map<String, dynamic> json) {
    var contentList = <Delivery>[];
    if (json['content'] is List) {
      contentList = (json['content'] as List)
          .map((item) => Delivery.fromJson(item as Map<String, dynamic>))
          .toList();
    }
    return PaginatedDeliveryResponse(
      content: contentList,
      pagination: Pagination.fromJson(
          json['pagination'] as Map<String, dynamic>? ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'content': content.map((delivery) => delivery.toJson()).toList(),
      'pagination': pagination.toJson(),
    };
  }
}
