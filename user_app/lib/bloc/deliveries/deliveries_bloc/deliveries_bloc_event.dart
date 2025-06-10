import 'package:equatable/equatable.dart';
import 'package:langas_user/util/apps_enums.dart';

abstract class DeliveriesEvent extends Equatable {
  const DeliveriesEvent();
  @override
  List<Object?> get props => [];
}

class FetchDeliveriesRequested extends DeliveriesEvent {
  final String clientId;
  final int pageNumber;
  final int pageSize;
  final DeliveryStatus? status;
  final bool isHistory;
  const FetchDeliveriesRequested({
    required this.clientId,
    this.pageNumber = 1,
    this.pageSize = 25,
    this.status,
    required this.isHistory,
  });
  @override
  List<Object?> get props =>
      [clientId, pageNumber, pageSize, status, isHistory];
}
