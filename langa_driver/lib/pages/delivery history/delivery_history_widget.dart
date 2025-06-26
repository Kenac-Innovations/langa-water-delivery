import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:intl/intl.dart';
import 'package:langas_driver/bloc/auth/auth_bloc/auth_bloc_bloc.dart';
import 'package:langas_driver/bloc/auth/auth_bloc/auth_bloc_state.dart';
import 'package:langas_driver/bloc/delivery/delivery_history_bloc/delivery_history_bloc_bloc.dart';
import 'package:langas_driver/bloc/delivery/delivery_history_bloc/delivery_history_bloc_event.dart';
import 'package:langas_driver/bloc/delivery/delivery_history_bloc/delivery_history_bloc_state.dart';
import 'package:langas_driver/flutter_flow/flutter_flow_icon_button.dart';
import 'package:langas_driver/flutter_flow/flutter_flow_theme.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
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
  final ScrollController _scrollController = ScrollController();
  String? _driverId;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    _loadInitialHistory();
  }

  void _loadInitialHistory() {
    final authState = context.read<AuthBloc>().state;
    if (authState is AuthDriverAuthenticated) {
      _driverId = authState.authData.driverProfile?.id.toString();
      if (_driverId != null && _driverId!.isNotEmpty) {
        context.read<DeliveryHistoryBloc>().add(LoadDeliveryHistory(
              driverId: _driverId!,
              statuses: const [
                DeliveryStatus.COMPLETED,
                DeliveryStatus.CANCELLED
              ],
              isRefresh: true,
            ));
      } else {
        _showError('Driver ID not available.');
      }
    } else {
      _showError('User not authenticated.');
    }
  }

  void _onScroll() {
    if (_isBottom) {
      final currentState = context.read<DeliveryHistoryBloc>().state;
      if (currentState is DeliveryHistoryLoadSuccess &&
          !currentState.hasReachedMax &&
          _driverId != null) {
        context.read<DeliveryHistoryBloc>().add(LoadMoreDeliveryHistory(
            driverId: _driverId!, statuses: currentState.currentStatuses));
      }
    }
  }

  bool get _isBottom {
    if (!_scrollController.hasClients) return false;
    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.offset;
    return currentScroll >= (maxScroll * 0.9);
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

  String _getVehicleImage(VehicleType? vehicleType) {
    switch (vehicleType) {
      case VehicleType.BIKE:
        return 'assets/images/bike_latest.png';
      case VehicleType.CAR:
        return 'assets/images/car_latest.png';
      case VehicleType.TRUCK:
        return 'assets/images/truck_latest.png';
      case VehicleType.VAN:
        return 'assets/images/van_latest.png';
      default:
        return 'assets/images/van_latest.png';
    }
  }

  void _showError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  @override
  void dispose() {
    unfocusNode.dispose();
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
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
            "Delivery History",
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
              padding:
                  const EdgeInsetsDirectional.fromSTEB(16.0, 0.0, 16.0, 0.0),
              child: BlocConsumer<DeliveryHistoryBloc, DeliveryHistoryState>(
                listener: (context, state) {
                  if (state is DeliveryHistoryLoadFailure) {
                    _showError(
                        'Failed to load history: ${state.failure.message}');
                  } else if (state is DeliveryHistoryNextPageError) {
                    _showError(
                        'Failed to load more history: ${state.failure.message}');
                  }
                },
                builder: (context, state) {
                  if (state is DeliveryHistoryLoading &&
                      state is! DeliveryHistoryLoadingNextPage) {
                    return Center(
                        child: SpinKitSpinningLines(
                            size: 60.0, color: theme.primary, lineWidth: 3.0));
                  }
                  if (state is DeliveryHistoryLoadFailure) {
                    return Center(
                        child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text('Error: ${state.failure.message}'),
                        const SizedBox(height: 10),
                        ElevatedButton(
                            onPressed: _loadInitialHistory,
                            child: const Text('Retry'))
                      ],
                    ));
                  }
                  if (state is DeliveryHistoryLoadSuccess) {
                    if (state.deliveries.isEmpty) {
                      return Center(
                          child: Text("NO DELIVERY HISTORY",
                              style: theme.titleMedium));
                    }
                    return ListView.builder(
                      controller: _scrollController,
                      padding: const EdgeInsets.only(top: 16.0, bottom: 16.0),
                      itemCount: state.hasReachedMax
                          ? state.deliveries.length
                          : state.deliveries.length + 1,
                      itemBuilder: (context, index) {
                        if (index >= state.deliveries.length) {
                          if (state is DeliveryHistoryLoadingNextPage) {
                            return const Center(
                                child: Padding(
                                    padding: EdgeInsets.all(16.0),
                                    child: CircularProgressIndicator()));
                          } else if (state is DeliveryHistoryNextPageError) {
                            return Center(
                                child: Padding(
                                    padding: const EdgeInsets.all(16.0),
                                    child: Text(
                                        'Error loading more: ${state.failure.message}')));
                          } else {
                            if (!state.hasReachedMax && _driverId != null) {
                              WidgetsBinding.instance.addPostFrameCallback((_) {
                                if (mounted) {
                                  context.read<DeliveryHistoryBloc>().add(
                                      LoadMoreDeliveryHistory(
                                          driverId: _driverId!,
                                          statuses: state.currentStatuses));
                                }
                              });
                            }
                            return const SizedBox.shrink();
                          }
                        }
                        final delivery = state.deliveries[index];
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 16.0),
                          child: _buildDeliveryCard(context, theme, delivery),
                        );
                      },
                    );
                  }
                  return const Center(child: Text("Loading history..."));
                },
              )),
        ),
      ),
    );
  }

  Widget _buildDeliveryCard(
      BuildContext context, FlutterFlowTheme theme, Delivery delivery) {
    String formattedDate = "Date unavailable";
    final dateString =
        delivery.currency; // Assuming date is in currency field temporarily
    final parsedDate = DateTime.tryParse(dateString);
    if (parsedDate != null) {
      formattedDate = DateFormat('yyyy-MM-dd HH:mm').format(parsedDate);
    }

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
