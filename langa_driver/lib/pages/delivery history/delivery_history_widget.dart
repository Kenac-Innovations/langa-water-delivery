import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:langas_driver/flutter_flow/flutter_flow_icon_button.dart';
import 'package:langas_driver/flutter_flow/flutter_flow_theme.dart';
import 'package:langas_driver/models/delivery_models.dart';
import 'package:langas_driver/nav/nav.dart';
import 'package:langas_driver/utils/delivery_enums.dart';

class DeliveryHistoryWidget extends StatefulWidget {
  const DeliveryHistoryWidget({super.key});

  @override
  State<DeliveryHistoryWidget> createState() => _DeliveryHistoryWidgetState();
}

class _DeliveryHistoryWidgetState extends State<DeliveryHistoryWidget> {
  final scaffoldKey = GlobalKey<ScaffoldState>();
  final unfocusNode = FocusNode();

  final List<Delivery> _deliveryHistory = [
    Delivery(
      deliverId: 201,
      priceAmount: 18.00,
      currency: 'USD',
      sensitivity: Sensitivity.BASIC,
      paymentStatus: PaymentStatus.PAID,
      pickupLatitude: -17.8252,
      pickupLongitude: 31.0335,
      pickupLocation: 'Main Water Depot, Harare',
      pickupContactName: 'Aqua Pure',
      pickupContactPhone: '0777111222',
      dropOffLatitude: -17.8452,
      dropOffLongitude: 31.0535,
      dropOffLocation: '88 Masasa Ave, Eastlea',
      dropOffContactName: 'Tariro Moyo',
      dropOffContactPhone: '0777333444',
      parcelDescription: '15 x 5L Purified Water',
      vehicleType: VehicleType.TRUCK,
      paymentMethod: PaymentMethod.E_MONEY,
      packageWeight: 75,
      deliveryStatus: DeliveryStatus.COMPLETED,
      isProposed: false,
      commissionRequired: 1.80,
      numberOfSeats: 0,
      deliveryType: 'WATER',
      isScheduled: false,
      customer: const Customer(
        clientId: 3,
        firstname: 'Tariro',
        lastname: 'Moyo',
        mobileNumber: '0777333444',
        emailAddress: 'tariro.m@example.com',
      ),
    ),
    Delivery(
      deliverId: 202,
      priceAmount: 12.50,
      currency: 'USD',
      sensitivity: Sensitivity.BASIC,
      paymentStatus: PaymentStatus.PAID,
      pickupLatitude: -17.8252,
      pickupLongitude: 31.0335,
      pickupLocation: 'Main Water Depot, Harare',
      pickupContactName: 'Aqua Pure',
      pickupContactPhone: '0777111222',
      dropOffLatitude: -17.8052,
      dropOffLongitude: 31.0135,
      dropOffLocation: '15 Ridge Road, Avondale West',
      dropOffContactName: 'Ben Banda',
      dropOffContactPhone: '0712555666',
      parcelDescription: '10 x 5L Purified Water',
      vehicleType: VehicleType.VAN,
      paymentMethod: PaymentMethod.CASH,
      packageWeight: 50,
      deliveryStatus: DeliveryStatus.CANCELLED,
      isProposed: false,
      commissionRequired: 1.25,
      numberOfSeats: 0,
      deliveryType: 'WATER',
      isScheduled: false,
      customer: const Customer(
        clientId: 4,
        firstname: 'Ben',
        lastname: 'Banda',
        mobileNumber: '0712555666',
        emailAddress: 'ben.b@example.com',
      ),
    ),
  ];

  @override
  void dispose() {
    unfocusNode.dispose();
    super.dispose();
  }

  Color _getStatusColor(BuildContext context, DeliveryStatus status) {
    final theme = FlutterFlowTheme.of(context);
    switch (status) {
      case DeliveryStatus.COMPLETED:
        return theme.success;
      case DeliveryStatus.CANCELLED:
        return theme.error;
      default:
        return theme.secondaryText;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);

    return GestureDetector(
      onTap: () => unfocusNode.canRequestFocus
          ? FocusScope.of(context).requestFocus(unfocusNode)
          : FocusScope.of(context).unfocus(),
      child: Scaffold(
        key: scaffoldKey,
        backgroundColor: theme.primaryBackground,
        appBar: AppBar(
          backgroundColor: theme.primary,
          automaticallyImplyLeading: false,
          leading: FlutterFlowIconButton(
            borderColor: Colors.transparent,
            borderRadius: 30.0,
            borderWidth: 1.0,
            buttonSize: 60.0,
            icon:
                const Icon(Icons.chevron_left, color: Colors.white, size: 30.0),
            onPressed: () async => context.pop(),
          ),
          title: Text(
            "Water Delivery History",
            style: theme.headlineMedium.override(
              fontFamily: theme.headlineMediumFamily,
              color: Colors.white,
              fontSize: 18.0,
              fontWeight: FontWeight.w600,
            ),
          ),
          centerTitle: true,
          elevation: 2.0,
        ),
        body: SafeArea(
          top: true,
          child: Padding(
            padding: const EdgeInsetsDirectional.fromSTEB(16.0, 0.0, 16.0, 0.0),
            child: _deliveryHistory.isEmpty
                ? Center(
                    child:
                        Text("NO DELIVERY HISTORY", style: theme.titleMedium))
                : ListView.builder(
                    padding: const EdgeInsets.only(top: 16.0, bottom: 16.0),
                    itemCount: _deliveryHistory.length,
                    itemBuilder: (context, index) {
                      final delivery = _deliveryHistory[index];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 16.0),
                        child: _buildDeliveryCard(context, theme, delivery),
                      );
                    },
                  ),
          ),
        ),
      ),
    );
  }

  Widget _buildDeliveryCard(
      BuildContext context, FlutterFlowTheme theme, Delivery delivery) {
    String formattedDate = "Date unavailable";
    // Using a static date for demonstration as it's not in the provided model
    formattedDate = DateFormat('yyyy-MM-dd HH:mm').format(
        DateTime.now().subtract(Duration(days: delivery.deliverId - 200)));

    return Card(
      clipBehavior: Clip.antiAliasWithSaveLayer,
      color: theme.secondaryBackground,
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.max,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "ID: ${delivery.deliverId}",
                  style: theme.bodyMedium.override(
                    fontFamily: theme.bodyMediumFamily,
                    fontWeight: FontWeight.w500,
                    color: theme.secondaryText,
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: _getStatusColor(context, delivery.deliveryStatus)
                        .withOpacity(0.1),
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: Text(
                    delivery.deliveryStatus.name,
                    style: theme.bodyMedium.override(
                      fontFamily: theme.bodyMediumFamily,
                      fontSize: 14.0,
                      fontWeight: FontWeight.w500,
                      color: _getStatusColor(context, delivery.deliveryStatus),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: Row(
                    children: [
                      Icon(Icons.calendar_today,
                          size: 16, color: theme.secondaryText),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          formattedDate,
                          style: theme.bodyMedium,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: theme.alternate.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    "\$${delivery.priceAmount.toStringAsFixed(2)}",
                    style: theme.titleMedium.override(
                      fontFamily: theme.titleMediumFamily,
                      color: theme.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            Divider(height: 24, thickness: 1, color: theme.alternate),
            Padding(
              padding: const EdgeInsets.only(left: 8.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Column(
                    children: [
                      Container(
                          width: 28,
                          height: 28,
                          decoration: const BoxDecoration(
                              color: Colors.red, shape: BoxShape.circle),
                          child: const Icon(Icons.location_on,
                              color: Colors.white, size: 16)),
                      Container(
                          width: 2,
                          height: 60,
                          margin: const EdgeInsets.symmetric(vertical: 4),
                          decoration: const BoxDecoration(
                              border: Border(
                                  left: BorderSide(
                                      color: Colors.grey,
                                      width: 2,
                                      style: BorderStyle.solid)))),
                      Container(
                          width: 28,
                          height: 28,
                          decoration: const BoxDecoration(
                              color: Colors.blue, shape: BoxShape.circle),
                          child: const Icon(Icons.flag,
                              color: Colors.white, size: 16)),
                    ],
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Pickup Location",
                            style: theme.titleSmall.override(
                                fontFamily: theme.titleMediumFamily,
                                fontWeight: FontWeight.w600,
                                fontSize: 16,
                                color: Colors.black)),
                        Text(delivery.pickupLocation,
                            style: theme.bodyMedium, maxLines: 3),
                        const SizedBox(height: 20),
                        Text("Drop-Off Location",
                            style: theme.titleMedium.override(
                                fontFamily: theme.titleMediumFamily,
                                fontWeight: FontWeight.w600,
                                fontSize: 16,
                                color: Colors.black)),
                        const SizedBox(height: 4),
                        Text(delivery.dropOffLocation,
                            style: theme.bodyMedium, maxLines: 3),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
