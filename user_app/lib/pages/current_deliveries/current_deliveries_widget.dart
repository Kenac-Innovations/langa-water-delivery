import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:go_router/go_router.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:flutter/services.dart';
import 'package:langas_user/bloc/auth/auth_bloc/auth_bloc_bloc.dart';
import 'package:langas_user/bloc/auth/auth_bloc/auth_bloc_state.dart';
import 'package:langas_user/bloc/deliveries/cancel_delivery_bloc/cancel_delivery_bloc_bloc.dart';
import 'package:langas_user/bloc/deliveries/cancel_delivery_bloc/cancel_delivery_bloc_event.dart';
import 'package:langas_user/bloc/deliveries/cancel_delivery_bloc/cancel_delivery_bloc_state.dart';
import 'package:langas_user/bloc/deliveries/deliveries_bloc/deliveries_bloc_bloc.dart';
import 'package:langas_user/bloc/deliveries/deliveries_bloc/deliveries_bloc_event.dart';
import 'package:langas_user/bloc/deliveries/deliveries_bloc/deliveries_bloc_state.dart';
import 'package:langas_user/bloc/deliveries/select_driver_bloc/select_driver_bloc_bloc.dart';
import 'package:langas_user/bloc/deliveries/select_driver_bloc/select_driver_bloc_state.dart';
import 'package:langas_user/dto/delivery_dto.dart';
import 'package:langas_user/flutter_flow/flutter_flow_icon_button.dart';
import 'package:langas_user/flutter_flow/flutter_flow_theme.dart';
import 'package:langas_user/models/delivery_model.dart';
import 'package:langas_user/models/driver_model.dart';
import 'package:langas_user/util/apps_enums.dart';
import 'package:url_launcher/url_launcher.dart';

class CurrentDeliveriesWidget extends StatefulWidget {
  const CurrentDeliveriesWidget({super.key});

  @override
  State<CurrentDeliveriesWidget> createState() =>
      _CurrentDeliveriesWidgetState();
}

class _CurrentDeliveriesWidgetState extends State<CurrentDeliveriesWidget> {
  final unfocusNode = FocusNode();
  final scaffoldKey = GlobalKey<ScaffoldState>();
  String? _clientId;

  @override
  void initState() {
    super.initState();
    final authState = context.read<AuthBloc>().state;
    if (authState is Authenticated) {
      _clientId = authState.user.userId.toString();
      _fetchDeliveries();
    } else {
      print("Error: User not authenticated in CurrentDeliveriesWidget");
    }
  }

  void _fetchDeliveries() {
    if (_clientId != null) {
      context.read<DeliveriesBloc>().add(
            FetchDeliveriesRequested(
              clientId: _clientId!,
              isHistory: false,
            ),
          );
    }
  }

  @override
  void dispose() {
    unfocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (Theme.of(context).platform == TargetPlatform.iOS) {
      SystemChrome.setSystemUIOverlayStyle(
        SystemUiOverlayStyle(
          statusBarBrightness: Theme.of(context).brightness,
          systemStatusBarContrastEnforced: true,
        ),
      );
    }

    return GestureDetector(
      onTap: () => unfocusNode.canRequestFocus
          ? FocusScope.of(context).requestFocus(unfocusNode)
          : FocusScope.of(context).unfocus(),
      child: Scaffold(
        key: scaffoldKey,
        backgroundColor: FlutterFlowTheme.of(context).primaryBackground,
        appBar: _buildAppBar(),
        body: SafeArea(
          top: true,
          child: MultiBlocListener(
            listeners: [
              BlocListener<CancelDeliveryBloc, CancelDeliveryState>(
                listener: (context, cancelState) {
                  if (cancelState is CancelDeliverySuccess) {
                    _showToast(cancelState.message, success: true);
                    _fetchDeliveries();
                  } else if (cancelState is CancelDeliveryFailure) {
                    _showToast(
                        "Cancellation failed: ${cancelState.failure.message}",
                        success: false);
                  }
                },
              ),
              BlocListener<SelectDriverBloc, SelectDriverState>(
                listener: (context, selectState) {
                  if (selectState is SelectDriverSuccess) {
                    _showToast(selectState.message, success: true);
                    _fetchDeliveries();
                  } else if (selectState is SelectDriverFailure) {
                    _showToast(
                        "Failed to assign driver: ${selectState.failure.message}",
                        success: false);
                  }
                },
              ),
            ],
            child: BlocBuilder<DeliveriesBloc, DeliveriesState>(
              builder: (context, state) {
                if (state is DeliveriesLoading && state is! DeliveriesSuccess) {
                  return _buildLoadingIndicator();
                } else if (state is DeliveriesSuccess) {
                  List<Delivery> deliveries = state.response.content
                      .where((d) =>
                          d.deliveryStatus != DeliveryStatus.COMPLETED &&
                          d.deliveryStatus != DeliveryStatus.CANCELLED)
                      .toList();

                  deliveries
                      .sort((a, b) => b.deliveryId.compareTo(a.deliveryId));

                  return deliveries.isEmpty
                      ? _buildEmptyState()
                      : _buildDeliveriesList(deliveries);
                } else if (state is DeliveriesFailure) {
                  return _buildErrorState(state.failure.message);
                } else {
                  return _buildLoadingIndicator();
                }
              },
            ),
          ),
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: FlutterFlowTheme.of(context).primary,
      automaticallyImplyLeading: false,
      leading: FlutterFlowIconButton(
        borderColor: Colors.transparent,
        borderRadius: 30.0,
        borderWidth: 1.0,
        buttonSize: 60.0,
        icon: const Icon(
          Icons.arrow_back_rounded,
          color: Colors.white,
          size: 24.0,
        ),
        onPressed: () async {
          context.goNamed('HomePage');
        },
      ),
      title: Text(
        "CURRENT DELIVERIES",
        style: FlutterFlowTheme.of(context).headlineMedium.override(
              fontFamily: FlutterFlowTheme.of(context).headlineMediumFamily,
              color: Colors.white,
              fontSize: 18.0,
              fontWeight: FontWeight.w600,
            ),
      ),
      actions: [
        FlutterFlowIconButton(
          borderColor: Colors.transparent,
          borderRadius: 30.0,
          borderWidth: 1.0,
          buttonSize: 60.0,
          icon: const Icon(
            Icons.refresh_rounded,
            color: Colors.white,
            size: 24.0,
          ),
          onPressed: _fetchDeliveries,
        ),
      ],
      centerTitle: true,
      elevation: 0,
    );
  }

  Widget _buildLoadingIndicator() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SpinKitSpinningLines(
            color: FlutterFlowTheme.of(context).primary,
            size: 50.0,
            lineWidth: 2,
          ),
          Padding(
            padding: const EdgeInsets.only(top: 16),
            child: Text(
              'Loading your deliveries...',
              style: FlutterFlowTheme.of(context).bodyMedium.override(
                    fontFamily: FlutterFlowTheme.of(context).bodyMediumFamily,
                    color: FlutterFlowTheme.of(context).secondaryText,
                  ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(String message) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, color: Colors.red.shade300, size: 60),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              'Error loading deliveries: $message',
              textAlign: TextAlign.center,
              style: FlutterFlowTheme.of(context).bodyMedium.override(
                    fontFamily: FlutterFlowTheme.of(context).bodyMediumFamily,
                    color: FlutterFlowTheme.of(context).secondaryText,
                  ),
            ),
          ),
          ElevatedButton.icon(
            icon: const Icon(Icons.refresh),
            label: const Text('Retry'),
            onPressed: _fetchDeliveries,
            style: ElevatedButton.styleFrom(
              backgroundColor: FlutterFlowTheme.of(context).primary,
              foregroundColor: Colors.white,
            ),
          )
        ],
      ),
    );
  }

  Widget _buildDeliveriesList(List<Delivery> deliveries) {
    return RefreshIndicator(
      onRefresh: () async => _fetchDeliveries(),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 0.0),
        child: ListView.builder(
          padding: EdgeInsets.zero,
          scrollDirection: Axis.vertical,
          itemCount: deliveries.length,
          itemBuilder: (context, index) =>
              _buildDeliveryCard(deliveries[index]),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.local_shipping_outlined,
            color: FlutterFlowTheme.of(context).secondaryText.withOpacity(0.6),
            size: 80,
          ),
          Padding(
            padding: const EdgeInsets.only(top: 16, bottom: 8),
            child: Text(
              'No Active Deliveries',
              style: FlutterFlowTheme.of(context).titleLarge.override(
                    fontFamily: FlutterFlowTheme.of(context).titleLargeFamily,
                    color: FlutterFlowTheme.of(context).primaryText,
                    fontWeight: FontWeight.w600,
                  ),
            ),
          ),
          Text(
            'You don\'t have any active deliveries at the moment',
            style: FlutterFlowTheme.of(context).bodyMedium.override(
                  fontFamily: FlutterFlowTheme.of(context).bodyMediumFamily,
                  color: FlutterFlowTheme.of(context).secondaryText,
                ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildDeliveryCard(Delivery delivery) {
    String statusText = delivery.deliveryStatus.name.replaceAll('_', ' ');
    statusText =
        statusText[0].toUpperCase() + statusText.substring(1).toLowerCase();

    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Card(
        clipBehavior: Clip.antiAliasWithSaveLayer,
        color: FlutterFlowTheme.of(context).secondaryBackground,
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.0),
        ),
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
                    "Order ID: TK${delivery.deliveryId}",
                    style: FlutterFlowTheme.of(context).titleMedium.override(
                          fontFamily:
                              FlutterFlowTheme.of(context).titleMediumFamily,
                          fontWeight: FontWeight.w600,
                          color: FlutterFlowTheme.of(context).primaryText,
                        ),
                  ),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: _getStatusColor(delivery.deliveryStatus)
                          .withOpacity(0.1),
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: Text(
                      statusText,
                      style: FlutterFlowTheme.of(context).bodyMedium.override(
                            fontFamily:
                                FlutterFlowTheme.of(context).bodyMediumFamily,
                            fontSize: 14.0,
                            fontWeight: FontWeight.w500,
                            color: _getStatusColor(delivery.deliveryStatus),
                          ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  _buildInfoChip(
                      Icons.shield_outlined, delivery.sensitivity.name),
                  const SizedBox(width: 8),
                  _buildInfoChip(
                      Icons.credit_card,
                      delivery.paymentMethod.name == 'E_MONEY'
                          ? 'E-Money'
                          : 'Cash'),
                ],
              ),
              Divider(
                height: 24,
                thickness: 1,
                color: FlutterFlowTheme.of(context).alternate,
              ),
              _buildLocationRow(Icons.location_on, Colors.red, "Pickup",
                  delivery.pickupLocation),
              _buildLocationRow(Icons.location_on, Colors.blue, "Drop-off",
                  delivery.dropOffLocation),
              const SizedBox(height: 16),
              if (delivery.driver != null &&
                  (delivery.deliveryStatus == DeliveryStatus.ASSIGNED ||
                      delivery.deliveryStatus == DeliveryStatus.PICKED_UP))
                Padding(
                  padding: const EdgeInsets.only(top: 0, bottom: 16),
                  child: _buildDriverInfo(delivery.driver!),
                ),
              _buildActionButtons(delivery),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoChip(IconData icon, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
          color: FlutterFlowTheme.of(context).secondaryBackground,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: FlutterFlowTheme.of(context).alternate)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon,
              size: 14, color: FlutterFlowTheme.of(context).secondaryText),
          const SizedBox(width: 4),
          Text(
            text,
            style: FlutterFlowTheme.of(context).bodySmall.override(
                  fontFamily: FlutterFlowTheme.of(context).bodySmallFamily,
                  color: FlutterFlowTheme.of(context).secondaryText,
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildLocationRow(
      IconData icon, Color iconColor, String label, String address) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: iconColor, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: FlutterFlowTheme.of(context).labelMedium.override(
                      fontFamily:
                          FlutterFlowTheme.of(context).labelMediumFamily,
                      color: FlutterFlowTheme.of(context).secondaryText),
                ),
                const SizedBox(height: 2),
                Text(
                  address,
                  style: FlutterFlowTheme.of(context).bodyMedium,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDriverInfo(Driver driver) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: FlutterFlowTheme.of(context).alternate.withOpacity(0.2),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: FlutterFlowTheme.of(context).alternate),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          CircleAvatar(
            radius: 25,
            backgroundColor: FlutterFlowTheme.of(context).alternate,
            backgroundImage: driver.profilePhotoUrl != null &&
                    driver.profilePhotoUrl!.isNotEmpty
                ? NetworkImage(driver.profilePhotoUrl!)
                : null,
            child: driver.profilePhotoUrl == null ||
                    driver.profilePhotoUrl!.isEmpty
                ? Icon(Icons.person,
                    size: 25, color: FlutterFlowTheme.of(context).secondaryText)
                : null,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${driver.firstname ?? ''} ${driver.lastname ?? ''}'.trim(),
                  style: FlutterFlowTheme.of(context).titleSmall.override(
                        fontFamily:
                            FlutterFlowTheme.of(context).titleSmallFamily,
                        fontWeight: FontWeight.w600,
                        color: FlutterFlowTheme.of(context).primaryText,
                      ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                iconSize: 20,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                icon: Icon(Icons.call,
                    color: FlutterFlowTheme.of(context).success),
                onPressed: driver.phoneNumber != null
                    ? () => _callDriver(driver.phoneNumber!)
                    : null,
              ),
              const SizedBox(width: 12),
              IconButton(
                iconSize: 20,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                icon: Icon(Icons.message,
                    color: FlutterFlowTheme.of(context).primary),
                onPressed: driver.phoneNumber != null
                    ? () => _messageDriver(driver.phoneNumber!)
                    : null,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(Delivery delivery) {
    switch (delivery.deliveryStatus) {
      case DeliveryStatus.OPEN:
        if (delivery.autoAssign) {
          return Row(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  alignment: Alignment.center,
                  child: Text(
                    "Finding driver...",
                    style: FlutterFlowTheme.of(context).bodyMedium.override(
                          fontFamily:
                              FlutterFlowTheme.of(context).bodyMediumFamily,
                          color: FlutterFlowTheme.of(context).secondaryText,
                          fontStyle: FontStyle.italic,
                        ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: OutlinedButton.icon(
                  icon: Icon(Icons.cancel_outlined,
                      size: 18, color: FlutterFlowTheme.of(context).error),
                  label: Text('Cancel',
                      style:
                          TextStyle(color: FlutterFlowTheme.of(context).error)),
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: FlutterFlowTheme.of(context).error),
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    textStyle: const TextStyle(
                        fontSize: 14, fontWeight: FontWeight.w500),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8)),
                  ),
                  onPressed: () => _showCancelConfirmation(delivery),
                ),
              ),
            ],
          );
        } else {
          return Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.people, size: 18),
                  label: const Text('Find Drivers'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: FlutterFlowTheme.of(context).primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    textStyle: const TextStyle(
                        fontSize: 14, fontWeight: FontWeight.w500),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8)),
                  ),
                  onPressed: () => _navigateToActiveDrivers(delivery),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: OutlinedButton.icon(
                  icon: Icon(Icons.cancel_outlined,
                      size: 18, color: FlutterFlowTheme.of(context).error),
                  label: Text('Cancel',
                      style:
                          TextStyle(color: FlutterFlowTheme.of(context).error)),
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: FlutterFlowTheme.of(context).error),
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    textStyle: const TextStyle(
                        fontSize: 14, fontWeight: FontWeight.w500),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8)),
                  ),
                  onPressed: () => _showCancelConfirmation(delivery),
                ),
              ),
            ],
          );
        }

      case DeliveryStatus.ASSIGNED:
        return Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 12),
          alignment: Alignment.center,
          child: Text(
            delivery.driver != null
                ? "Driver is on the way to pickup"
                : "Driver assigned, pending pickup",
            style: FlutterFlowTheme.of(context).bodyMedium.override(
                fontFamily: FlutterFlowTheme.of(context).bodyMediumFamily,
                color: FlutterFlowTheme.of(context).primary,
                fontWeight: FontWeight.w500),
            textAlign: TextAlign.center,
          ),
        );

      case DeliveryStatus.PICKED_UP:
        return ElevatedButton.icon(
          icon: const Icon(Icons.track_changes, size: 18),
          label: const Text('Track Delivery'),
          style: ElevatedButton.styleFrom(
            backgroundColor: FlutterFlowTheme.of(context).primary,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 12),
            minimumSize: const Size(double.infinity, 45),
            textStyle:
                const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
          onPressed: () => _navigateToTrackDelivery(delivery),
        );
      default:
        return const SizedBox.shrink();
    }
  }

  Color _getStatusColor(DeliveryStatus status) {
    switch (status) {
      case DeliveryStatus.ASSIGNED:
      case DeliveryStatus.PICKED_UP:
        return FlutterFlowTheme.of(context).primary;
      case DeliveryStatus.OPEN:
        return FlutterFlowTheme.of(context).warning;
      case DeliveryStatus.COMPLETED:
        return FlutterFlowTheme.of(context).success;
      case DeliveryStatus.CANCELLED:
        return FlutterFlowTheme.of(context).error;
      default:
        return FlutterFlowTheme.of(context).secondaryText;
    }
  }

  void _navigateToActiveDrivers(Delivery delivery) async {
    final result = await context.pushNamed<bool>(
      'ActiveDriversWidget',
      extra: delivery.deliveryId,
    );
    if (result == true && mounted) {
      _fetchDeliveries();
    }
  }

  void _navigateToTrackDelivery(Delivery delivery) {
    if (_clientId != null) {
      context.pushNamed('TrackDeliveryPage', extra: {
        'deliveryId': delivery.deliveryId,
        'clientId': _clientId!,
      });
    } else {
      _showToast("Cannot track delivery: Client ID missing.", success: false);
    }
  }

  void _showCancelConfirmation(Delivery delivery) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: Text('Cancel Delivery',
              style: FlutterFlowTheme.of(context).titleMedium),
          content: Text(
              'Are you sure you want to cancel delivery TK${delivery.deliveryId}?',
              style: FlutterFlowTheme.of(context).bodyMedium),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: Text('No',
                  style: TextStyle(
                      color: FlutterFlowTheme.of(context).secondaryText)),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext);
                _dispatchCancelDelivery(delivery);
              },
              child: Text('Yes, Cancel',
                  style: TextStyle(color: FlutterFlowTheme.of(context).error)),
            ),
          ],
          backgroundColor: FlutterFlowTheme.of(context).secondaryBackground,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        );
      },
    );
  }

  void _dispatchCancelDelivery(Delivery delivery) {
    if (_clientId != null) {
      final cancelDto = CancelDeliveryRequestDto(
          deliveryId: delivery.deliveryId, reason: "Cancelled by user");
      context.read<CancelDeliveryBloc>().add(
          CancelDeliverySubmitted(clientId: _clientId!, requestDto: cancelDto));
    }
  }

  void _callDriver(String phone) async {
    final Uri phoneUri = Uri(scheme: 'tel', path: phone);
    try {
      if (await canLaunchUrl(phoneUri)) {
        await launchUrl(phoneUri);
      } else {
        _showToast('Could not launch phone dialer.', success: false);
      }
    } catch (e) {
      print('Could not launch $phoneUri: $e');
      _showToast('Could not make a call to $phone', success: false);
    }
  }

  void _messageDriver(String phone) async {
    final formattedPhone = phone.replaceAll(RegExp(r'\D'), '');
    final Uri whatsappUri = Uri.parse("https://wa.me/$formattedPhone");

    try {
      if (await canLaunchUrl(whatsappUri)) {
        await launchUrl(whatsappUri, mode: LaunchMode.externalApplication);
      } else {
        _showToast('Could not open WhatsApp. Is it installed?', success: false);
      }
    } catch (e) {
      print('Could not launch WhatsApp: $e');
      _showToast('Could not open WhatsApp.', success: false);
    }
  }

  void _showToast(String message, {required bool success}) {
    Fluttertoast.showToast(
        msg: message,
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: success ? Colors.green : Colors.red,
        textColor: Colors.white,
        fontSize: 16.0);
  }
}
