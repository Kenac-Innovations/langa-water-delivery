import 'package:equatable/equatable.dart';
import 'package:langas_user/util/apps_enums.dart';

class WaterOrder extends Equatable {
  final int orderId;
  final int clientId;
  final String clientName;
  final String? deliveryAddress;
  final String? specialInstructions;
  final WaterOrderStatus orderStatus;
  final WaterPaymentStatus paymentStatus;
  final double totalAmount;
  final DateTime orderDate;
  final List<WaterDelivery> deliveries;

  const WaterOrder({
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

  @override
  List<Object?> get props => [
        orderId,
        clientId,
        clientName,
        deliveryAddress,
        specialInstructions,
        orderStatus,
        paymentStatus,
        totalAmount,
        orderDate,
        deliveries,
      ];
}

class WaterDelivery extends Equatable {
  final int deliveryId;
  final double priceAmount;
  final bool? autoAssignDriver;
  final WaterDropOffLocation dropOffLocation;
  final bool? isScheduled;
  final int quantity;
  final String? deliveryInstructions;
  final ScheduledDetails? scheduledDetails;
  final WaterDeliveryStatus status;

  const WaterDelivery({
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

  @override
  List<Object?> get props => [
        deliveryId,
        priceAmount,
        autoAssignDriver,
        dropOffLocation,
        isScheduled,
        quantity,
        deliveryInstructions,
        scheduledDetails,
        status,
      ];
}

class WaterDropOffLocation extends Equatable {
  final double dropOffLatitude;
  final double dropOffLongitude;
  final String dropOffLocation;
  final String? dropOffAddressType;
  final String dropOffContactName;
  final String dropOffContactPhone;

  const WaterDropOffLocation({
    required this.dropOffLatitude,
    required this.dropOffLongitude,
    required this.dropOffLocation,
    this.dropOffAddressType,
    required this.dropOffContactName,
    required this.dropOffContactPhone,
  });

  @override
  List<Object?> get props => [
        dropOffLatitude,
        dropOffLongitude,
        dropOffLocation,
        dropOffAddressType,
        dropOffContactName,
        dropOffContactPhone,
      ];
}

class ScheduledDetails extends Equatable {
  final String scheduledDate;
  final String? scheduledTime;

  const ScheduledDetails({
    required this.scheduledDate,
    this.scheduledTime,
  });

  @override
  List<Object?> get props => [
        scheduledDate,
        scheduledTime,
      ];
}
