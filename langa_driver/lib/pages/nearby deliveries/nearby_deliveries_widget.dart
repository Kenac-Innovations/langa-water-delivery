import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:geolocator/geolocator.dart';
import 'package:langas_driver/flutter_flow/flutter_flow_theme.dart';
import 'package:langas_driver/models/firebase_delivery_model.dart';
import 'package:langas_driver/nav/nav.dart';
import 'package:langas_driver/services/geolocation.dart';
import 'package:langas_driver/utils/delivery_enums.dart';

class NearbyDeliveriesWidget extends StatefulWidget {
  const NearbyDeliveriesWidget({super.key});

  @override
  State<NearbyDeliveriesWidget> createState() => _NearbyDeliveriesWidgetState();
}

class _NearbyDeliveriesWidgetState extends State<NearbyDeliveriesWidget> {
  final scaffoldKey = GlobalKey<ScaffoldState>();
  final ScrollController _scrollController = ScrollController();

  // Static data for nearby water deliveries
  final List<FirebaseDelivery> _nearbyDeliveries = [
    FirebaseDelivery(
      id: 301,
      priceAmount: 20.00,
      currency: 'USD',
      pickupLocation: 'Aqua-Pak Bottling, Southerton',
      dropOffLocation: 'Belgravia Shopping Centre',
      pickupLatitude: -17.8639,
      pickupLongitude: 31.0274,
      dropOffLatitude: -17.8048,
      dropOffLongitude: 31.0366,
      parcelDescription: '10 cases of 500ml bottled water',
      vehicleType: VehicleType.TRUCK,
      paymentMethod: PaymentMethod.ECOCASH,
      deliveryType: 'WATER',
      client: const FirebaseCustomer(
          clientId: 10, firstname: 'Belgravia', lastname: 'Retail'),
      sensitivity: Sensitivity.BASIC,
      paymentStatus: PaymentStatus.PAID,
      geohash: 'k7g1',
      coordinates: [-17.8639, 31.0274],
      packageWeight: 120,
      deliveryStatus: DeliveryStatus.OPEN,
      commissionRequired: 2.0,
      createdAt: DateTime.now().toIso8601String(),
      numberOfSeats: 0,
      isScheduled: false,
      autoDispatch: false,
    ),
    FirebaseDelivery(
      id: 302,
      priceAmount: 12.50,
      currency: 'USD',
      pickupLocation: 'Aqua-Pak Bottling, Southerton',
      dropOffLocation: '7 Crighton Rd, Groombridge',
      pickupLatitude: -17.8639,
      pickupLongitude: 31.0274,
      dropOffLatitude: -17.7884,
      dropOffLongitude: 31.0498,
      parcelDescription: '5 x 20L water containers',
      vehicleType: VehicleType.VAN,
      paymentMethod: PaymentMethod.CASH,
      deliveryType: 'WATER',
      client: const FirebaseCustomer(
          clientId: 11, firstname: 'Tinashe', lastname: 'Murewa'),
      sensitivity: Sensitivity.BASIC,
      paymentStatus: PaymentStatus.PAID,
      geohash: 'k7g4',
      coordinates: [-17.8639, 31.0274],
      packageWeight: 100,
      deliveryStatus: DeliveryStatus.OPEN,
      commissionRequired: 1.25,
      createdAt: DateTime.now().toIso8601String(),
      numberOfSeats: 0,
      isScheduled: false,
      autoDispatch: false,
    ),
  ];

  final GeolocationService _geolocationService = GeolocationService();
  final Position _currentPosition = Position(
      latitude: -17.8252,
      longitude: 31.0335,
      timestamp: DateTime.now(),
      accuracy: 0,
      altitude: 0,
      heading: 0,
      speed: 0,
      speedAccuracy: 0,
      altitudeAccuracy: 0,
      headingAccuracy: 0);

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _showConfirmation(FirebaseDelivery delivery) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
            'You have accepted the delivery to ${delivery.dropOffLocation}.'),
        backgroundColor: Colors.green,
      ),
    );
    // Navigate to the current deliveries screen to simulate accepting an order
    context.go('/currentDeliveries');
  }

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);
    return Scaffold(
      key: scaffoldKey,
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: theme.primary,
        automaticallyImplyLeading: false,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded,
              color: Colors.white, size: 24.0),
          onPressed: () => context.pop(),
        ),
        title: const Text(
          'NEARBY WATER DELIVERIES',
          style: TextStyle(
              fontFamily: 'Poppins',
              color: Colors.white,
              fontSize: 18.0,
              fontWeight: FontWeight.w600),
        ),
        centerTitle: true,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded,
                color: Colors.white, size: 24.0),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Page refreshed.')),
              );
            },
          ),
        ],
      ),
      body: SafeArea(
        child: _nearbyDeliveries.isEmpty
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.search_off, size: 80, color: Colors.grey),
                    const SizedBox(height: 16),
                    Text('No nearby water deliveries found',
                        style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w500,
                            color: Colors.grey[700])),
                  ],
                ),
              )
            : ListView.builder(
                controller: _scrollController,
                padding:
                    const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                itemCount: _nearbyDeliveries.length,
                itemBuilder: (context, index) {
                  return _buildDeliveryCard(_nearbyDeliveries[index], theme);
                },
              ),
      ),
    );
  }

  Widget _buildDeliveryCard(FirebaseDelivery delivery, FlutterFlowTheme theme) {
    return FutureBuilder<List<double>>(
      future: Future.wait([
        _geolocationService.calculateDistance(
            _currentPosition.latitude,
            _currentPosition.longitude,
            delivery.pickupLatitude,
            delivery.pickupLongitude),
        _geolocationService.calculateDistance(
            delivery.pickupLatitude,
            delivery.pickupLongitude,
            delivery.dropOffLatitude,
            delivery.dropOffLongitude),
      ]),
      builder: (context, snapshot) {
        String distanceToPickupKm = "...";
        String totalDeliveryDistanceKm = "...";

        if (snapshot.connectionState == ConnectionState.done &&
            snapshot.hasData) {
          distanceToPickupKm = (snapshot.data![0] / 1000).toStringAsFixed(1);
          totalDeliveryDistanceKm =
              (snapshot.data![1] / 1000).toStringAsFixed(1);
        }

        return Card(
          margin: const EdgeInsets.only(bottom: 16.0),
          elevation: 3,
          color: Colors.white,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildUserProfileSection(delivery, theme, distanceToPickupKm),
              const Divider(height: 1, thickness: 1, color: Color(0xFFE0E0E0)),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildLocationSection(delivery, theme),
                    _buildDetailsSection(
                        delivery, totalDeliveryDistanceKm, theme),
                    const SizedBox(height: 16),
                    _buildActionButtons(delivery, theme),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDetailsSection(FirebaseDelivery delivery,
      String totalDeliveryDistanceKm, FlutterFlowTheme theme) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF8F9FF),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFEEF3FF)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _buildDetailItem(
              theme,
              "Earnings",
              '\$${delivery.priceAmount.toStringAsFixed(2)}',
              Icons.attach_money),
          _buildDetailItem(theme, "Vehicle", "Truck", Icons.local_shipping,
              capitalize: true),
          _buildDetailItem(theme, "Distance", '$totalDeliveryDistanceKm km',
              Icons.map_outlined),
          _buildDetailItem(
              theme, "Payment", delivery.paymentMethod.name, Icons.credit_card,
              capitalize: true),
        ],
      ),
    );
  }

  Widget _buildDetailItem(
      FlutterFlowTheme theme, String label, String value, IconData icon,
      {bool capitalize = false}) {
    String displayValue = capitalize
        ? value.characters.first.toUpperCase() +
            value.substring(1).toLowerCase()
        : value;

    return Expanded(
      child: Column(
        children: [
          Icon(icon, color: theme.primary, size: 24),
          const SizedBox(height: 4),
          Text(
            label,
            style: theme.bodySmall
                .override(fontFamily: 'Poppins', color: Colors.grey[700]),
          ),
          Text(
            displayValue,
            style: theme.bodyMedium
                .override(fontFamily: 'Poppins', fontWeight: FontWeight.w600),
            textAlign: TextAlign.center,
          )
        ],
      ),
    );
  }

  Widget _buildUserProfileSection(FirebaseDelivery delivery,
      FlutterFlowTheme theme, String distanceToPickupKm) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: const BoxDecoration(
        color: Color(0xFFEEF3FF),
        borderRadius: BorderRadius.only(
            topLeft: Radius.circular(12.0), topRight: Radius.circular(12.0)),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.store_outlined,
              color: Colors.grey[600],
              size: 30,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${delivery.client?.firstname} ${delivery.client?.lastname}'
                      .trim(),
                  style: theme.bodyLarge.override(
                      fontFamily: 'Poppins', fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Text(
                  '$distanceToPickupKm km away',
                  style: theme.bodyMedium
                      .override(fontFamily: 'Poppins', color: Colors.grey[700]),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
                color: theme.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20.0)),
            child: Row(
              children: [
                Icon(Icons.opacity, color: theme.primary, size: 16),
                const SizedBox(width: 4),
                Text(
                  "WATER",
                  style: theme.bodySmall.override(
                      fontFamily: 'Poppins',
                      color: theme.primary,
                      fontWeight: FontWeight.bold),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildLocationSection(
      FirebaseDelivery delivery, FlutterFlowTheme theme) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
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
                  height: 40,
                  color: Colors.grey.shade300,
                  margin: const EdgeInsets.symmetric(vertical: 4)),
              Container(
                  width: 28,
                  height: 28,
                  decoration: const BoxDecoration(
                      color: Colors.blue, shape: BoxShape.circle),
                  child: const Icon(Icons.flag, color: Colors.white, size: 16)),
            ],
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Pickup Location',
                    style: theme.bodyMedium.override(
                        fontFamily: 'Poppins',
                        color: Colors.red,
                        fontWeight: FontWeight.w500)),
                Text(delivery.pickupLocation,
                    style: theme.bodySmall.override(
                        fontFamily: 'Poppins', color: Colors.grey[800]),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis),
                const SizedBox(height: 16),
                Text('Drop-off Location',
                    style: theme.bodyMedium.override(
                        fontFamily: 'Poppins',
                        color: Colors.blue,
                        fontWeight: FontWeight.w500)),
                Text(delivery.dropOffLocation,
                    style: theme.bodySmall.override(
                        fontFamily: 'Poppins', color: Colors.grey[800]),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(
      FirebaseDelivery delivery, FlutterFlowTheme theme) {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton.icon(
            icon: Icon(Icons.map_outlined, size: 18, color: theme.primary),
            label: Text('VIEW ROUTE',
                style: TextStyle(
                    color: theme.primary,
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.w600,
                    fontSize: 14)),
            style: OutlinedButton.styleFrom(
                foregroundColor: theme.primary,
                side: BorderSide(color: theme.primary),
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12))),
            onPressed: () {
              context.push('/deliveryRoute', extra: delivery.id.toString());
            },
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: ElevatedButton(
            onPressed: () => _showConfirmation(delivery),
            style: ElevatedButton.styleFrom(
                backgroundColor: theme.primary,
                foregroundColor: Colors.white,
                elevation: 2,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                padding: const EdgeInsets.symmetric(vertical: 12)),
            child: const Text('ACCEPT',
                style: TextStyle(
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.w600,
                    fontSize: 14)),
          ),
        ),
      ],
    );
  }
}
