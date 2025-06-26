import 'dart:math' show min, max; // Only min, max needed here
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:langas_driver/bloc/delivery/delivery_details/delivery_details_bloc_bloc.dart';
import 'package:langas_driver/bloc/delivery/delivery_details/delivery_details_bloc_event.dart';
import 'package:langas_driver/bloc/delivery/delivery_details/delivery_details_bloc_state.dart';
import 'package:langas_driver/flutter_flow/flutter_flow_theme.dart';
import 'package:langas_driver/models/delivery_models.dart';

class DeliveryRouteScreen extends StatefulWidget {
  final String deliveryId;

  const DeliveryRouteScreen({
    super.key,
    required this.deliveryId,
  });

  @override
  State<DeliveryRouteScreen> createState() => _DeliveryRouteScreenState();
}

class _DeliveryRouteScreenState extends State<DeliveryRouteScreen> {
  GoogleMapController? _mapController;
  BitmapDescriptor? _pickupIcon;
  BitmapDescriptor? _dropoffIcon;

  @override
  void initState() {
    super.initState();
    context
        .read<DeliveryDetailsBloc>()
        .add(FetchDeliveryRouteDetails(deliveryId: widget.deliveryId));
    _setCustomMapPins();
    print(widget.deliveryId);
  }

  void _setCustomMapPins() async {
    _pickupIcon =
        BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed);
    _dropoffIcon =
        BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue);
    if (mounted) {
      setState(() {});
    }
  }

  void _zoomToFitRoute(List<LatLng> routeCoordinates) {
    if (routeCoordinates.isEmpty || _mapController == null) return;

    double minLat = routeCoordinates.first.latitude;
    double maxLat = routeCoordinates.first.latitude;
    double minLng = routeCoordinates.first.longitude;
    double maxLng = routeCoordinates.first.longitude;

    for (LatLng point in routeCoordinates) {
      minLat = min(minLat, point.latitude);
      maxLat = max(maxLat, point.latitude);
      minLng = min(minLng, point.longitude);
      maxLng = max(maxLng, point.longitude);
    }

    const double padding = 0.02;
    minLat -= padding;
    maxLat += padding;
    minLng -= padding;
    maxLng += padding;

    _mapController!.animateCamera(
      CameraUpdate.newLatLngBounds(
        LatLngBounds(
          southwest: LatLng(minLat, minLng),
          northeast: LatLng(maxLat, maxLng),
        ),
        50,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);

    return Scaffold(
        appBar: AppBar(
          backgroundColor: theme.primary,
          automaticallyImplyLeading: false,
          leading: IconButton(
            icon: const Icon(
              Icons.chevron_left_rounded,
              color: Colors.white,
              size: 30.0,
            ),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
          title: const Text(
            "Delivery Route",
            style: TextStyle(
              fontFamily: 'Poppins',
              color: Colors.white,
              fontSize: 16.0,
              fontWeight: FontWeight.w600,
            ),
          ),
          centerTitle: true,
          elevation: 2.0,
        ),
        body: BlocBuilder<DeliveryDetailsBloc, DeliveryDetailsState>(
          builder: (context, state) {
            if (state is DeliveryDetailsLoading ||
                state is DeliveryDetailsInitial) {
              return Center(
                child: CircularProgressIndicator(color: theme.primary),
              );
            }
            if (state is DeliveryDetailsLoadFailure) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text('Failed to load route: ${state.failure.message}',
                      textAlign: TextAlign.center),
                ),
              );
            }
            if (state is DeliveryDetailsLoadSuccess) {
              final delivery = state.delivery;
              final routeCoordinates = state.routeCoordinates;

              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (_mapController != null && routeCoordinates.isNotEmpty) {
                  _zoomToFitRoute(routeCoordinates);
                }
              });

              return Stack(
                children: [
                  SizedBox(
                    height: MediaQuery.of(context).size.height,
                    child: GoogleMap(
                      onMapCreated: (controller) {
                        _mapController = controller;
                        if (routeCoordinates.isNotEmpty) {
                          Future.delayed(const Duration(milliseconds: 300), () {
                            // Short delay for map to initialize fully
                            _zoomToFitRoute(routeCoordinates);
                          });
                        }
                      },
                      markers: {
                        Marker(
                          markerId: const MarkerId('pickup'),
                          position: LatLng(delivery.pickupLatitude,
                              delivery.pickupLongitude),
                          icon: _pickupIcon ??
                              BitmapDescriptor.defaultMarkerWithHue(
                                  BitmapDescriptor.hueRed),
                          infoWindow: InfoWindow(
                              title: 'Pickup',
                              snippet: delivery.pickupLocation),
                        ),
                        Marker(
                          markerId: const MarkerId('dropoff'),
                          position: LatLng(delivery.dropOffLatitude,
                              delivery.dropOffLongitude),
                          icon: _dropoffIcon ??
                              BitmapDescriptor.defaultMarkerWithHue(
                                  BitmapDescriptor.hueBlue),
                          infoWindow: InfoWindow(
                              title: 'Dropoff',
                              snippet: delivery.dropOffLocation),
                        ),
                      },
                      polylines: {
                        Polyline(
                          polylineId: const PolylineId('route'),
                          color: theme.primary,
                          points: routeCoordinates,
                          width: 5,
                          patterns: [PatternItem.dash(20), PatternItem.gap(10)],
                        ),
                      },
                      initialCameraPosition: CameraPosition(
                        target: LatLng(
                          (delivery.pickupLatitude + delivery.dropOffLatitude) /
                              2,
                          (delivery.pickupLongitude +
                                  delivery.dropOffLongitude) /
                              2,
                        ),
                        zoom: 12,
                      ),
                      mapType: MapType.normal,
                      myLocationEnabled: true,
                      myLocationButtonEnabled: true,
                      compassEnabled: true,
                      zoomControlsEnabled: true,
                    ),
                  ),
                  Align(
                    alignment: const AlignmentDirectional(-1.0, 1.0),
                    child: Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(30.0),
                          topRight: Radius.circular(30.0),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 10,
                            offset: const Offset(0, -5),
                          ),
                        ],
                      ),
                      child: Padding(
                        padding:
                            const EdgeInsets.fromLTRB(16.0, 20.0, 16.0, 20.0),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                _buildInfoItem(
                                  context: context,
                                  icon: Icons.map,
                                  label: 'Distance',
                                  value:
                                      '${state.estimatedDistance?.toStringAsFixed(1) ?? "..."} km',
                                  iconColor: theme.primary,
                                ),
                                _buildInfoItem(
                                  context: context,
                                  icon: Icons.access_time,
                                  label: 'Est. Time',
                                  value: state.estimatedTime ?? '...',
                                  iconColor: theme.primary,
                                ),
                                _buildInfoItem(
                                  context: context,
                                  icon: Icons.attach_money,
                                  label: 'Price',
                                  value:
                                      '\$${delivery.priceAmount.toStringAsFixed(2)}',
                                  iconColor: theme.primary,
                                ),
                              ],
                            ),
                            const Divider(
                              height: 30,
                              thickness: 1,
                              color: Color(0xFFE5E3E3),
                            ),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Column(
                                  children: [
                                    Container(
                                      width: 12,
                                      height: 12,
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFF11616),
                                        shape: BoxShape.circle,
                                        border: Border.all(
                                          color: Colors.white,
                                          width: 2,
                                        ),
                                        boxShadow: const [
                                          BoxShadow(
                                            color: Colors.black12,
                                            blurRadius: 4,
                                            offset: Offset(0, 2),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Container(
                                      width: 2,
                                      height: 60,
                                      decoration: const BoxDecoration(
                                        gradient: LinearGradient(
                                          colors: [
                                            Color(0xFFF11616),
                                            Color(0xFF099AF6)
                                          ],
                                          begin: Alignment.topCenter,
                                          end: Alignment.bottomCenter,
                                        ),
                                      ),
                                    ),
                                    Container(
                                      width: 12,
                                      height: 12,
                                      decoration: BoxDecoration(
                                        color: const Color(0xFF099AF6),
                                        shape: BoxShape.circle,
                                        border: Border.all(
                                          color: Colors.white,
                                          width: 2,
                                        ),
                                        boxShadow: const [
                                          BoxShadow(
                                            color: Colors.black12,
                                            blurRadius: 4,
                                            offset: Offset(0, 2),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const Text(
                                        'Pickup Location',
                                        style: TextStyle(
                                          fontFamily: 'Poppins',
                                          color: Color(0xFFF11616),
                                          fontSize: 15.0,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                      Text(
                                        delivery.pickupLocation,
                                        style: TextStyle(
                                          fontFamily: 'Poppins',
                                          fontSize: 13.0,
                                          color: Colors.grey[800],
                                          fontWeight: FontWeight.w500,
                                        ),
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      const SizedBox(height: 20),
                                      const Text(
                                        'Drop-off Location',
                                        style: TextStyle(
                                          fontFamily: 'Poppins',
                                          color: Color(0xFF099AF6),
                                          fontSize: 15.0,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                      Text(
                                        delivery.dropOffLocation,
                                        style: TextStyle(
                                          fontFamily: 'Poppins',
                                          fontSize: 13.0,
                                          color: Colors.grey[800],
                                          fontWeight: FontWeight.w500,
                                        ),
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 15),
                            Container(
                              padding: const EdgeInsets.only(bottom: 15),
                              width: double.infinity,
                              child: ElevatedButton(
                                onPressed: () {
                                  Navigator.pop(context);
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: theme.primary,
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 14),
                                  elevation: 3,
                                ),
                                child: const Text(
                                  'CLOSE ROUTE VIEW',
                                  style: TextStyle(
                                    fontFamily: 'Poppins',
                                    fontSize: 16.0,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              );
            }
            return const Center(child: Text("Something went wrong."));
          },
        ));
  }

  Widget _buildInfoItem({
    required BuildContext context,
    required IconData icon,
    required String label,
    required String value,
    required Color iconColor,
  }) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: iconColor.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(
            icon,
            color: iconColor,
            size: 24,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: TextStyle(
            fontFamily: 'Poppins',
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            fontFamily: 'Poppins',
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}
