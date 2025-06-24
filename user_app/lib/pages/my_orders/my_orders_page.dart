import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:langas_user/bloc/auth/auth_bloc/auth_bloc_bloc.dart';
import 'package:langas_user/bloc/auth/auth_bloc/auth_bloc_state.dart';
import 'package:langas_user/bloc/bloc/water_order_bloc_bloc.dart';
import 'package:langas_user/bloc/bloc/water_order_bloc_event.dart';
import 'package:langas_user/bloc/bloc/water_order_bloc_state.dart';
import 'package:langas_user/flutter_flow/flutter_flow_icon_button.dart';
import 'package:langas_user/flutter_flow/flutter_flow_theme.dart';
import 'package:langas_user/models/water_order_model.dart';
import 'package:langas_user/util/apps_enums.dart';

class MyOrdersPage extends StatefulWidget {
  const MyOrdersPage({super.key});

  @override
  State<MyOrdersPage> createState() => _MyOrdersPageState();
}

class _MyOrdersPageState extends State<MyOrdersPage> {
  final unfocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    final authState = context.read<AuthBloc>().state;
    if (authState is Authenticated) {
      context
          .read<WaterOrderBloc>()
          .add(FetchClientRecentDeliveries(clientId: authState.user.userId));
    }
  }

  @override
  void dispose() {
    unfocusNode.dispose();
    super.dispose();
  }

  Future<void> _onRefresh() async {
    final authState = context.read<AuthBloc>().state;
    if (authState is Authenticated) {
      context
          .read<WaterOrderBloc>()
          .add(FetchClientRecentDeliveries(clientId: authState.user.userId));
    }
  }

  Color _getStatusColor(WaterOrderStatus status) {
    final theme = FlutterFlowTheme.of(context);
    switch (status) {
      case WaterOrderStatus.COMPLETED:
        return theme.success;
      case WaterOrderStatus.CANCELLED:
        return theme.error;
      case WaterOrderStatus.PROCESSING:
      case WaterOrderStatus.CONFIRMED:
        return theme.primary;
      case WaterOrderStatus.CREATED:
        return theme.warning;
      default:
        return theme.secondaryText;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);
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
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: theme.primary,
          automaticallyImplyLeading: false,
          leading: FlutterFlowIconButton(
            borderColor: Colors.transparent,
            borderRadius: 30.0,
            buttonSize: 60.0,
            icon: const Icon(Icons.arrow_back_rounded,
                color: Colors.white, size: 24.0),
            onPressed: () => context.goNamed('HomePage'),
          ),
          title: Text(
            "My Orders",
            style: theme.headlineMedium.override(
              fontFamily: theme.headlineMediumFamily,
              color: Colors.white,
              fontSize: 18.0,
              fontWeight: FontWeight.w600,
            ),
          ),
          actions: [
            FlutterFlowIconButton(
              borderColor: Colors.transparent,
              borderRadius: 30.0,
              buttonSize: 60.0,
              icon: const Icon(Icons.refresh_rounded,
                  color: Colors.white, size: 24.0),
              onPressed: _onRefresh,
            ),
          ],
          centerTitle: true,
          elevation: 1,
        ),
        body: SafeArea(
          top: true,
          child: BlocBuilder<WaterOrderBloc, WaterOrderState>(
            builder: (context, state) {
              if (state is WaterOrderLoading) {
                return _buildLoadingIndicator();
              }
              if (state is WaterOrderListLoadSuccess) {
                if (state.paginatedResponse.content.isEmpty) {
                  return _buildEmptyState();
                }
                final sortedOrders =
                    List<WaterOrder>.from(state.paginatedResponse.content)
                      ..sort((a, b) => b.orderDate.compareTo(a.orderDate));
                return _buildOrdersList(sortedOrders);
              }
              if (state is WaterOrderFailure) {
                return _buildErrorState(state.failure.message);
              }
              return _buildEmptyState();
            },
          ),
        ),
      ),
    );
  }

  Widget _buildLoadingIndicator() {
    final theme = FlutterFlowTheme.of(context);
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SpinKitFadingCircle(color: theme.primary, size: 50.0),
          Padding(
            padding: const EdgeInsets.only(top: 24),
            child: Text('Loading your orders...', style: theme.bodyMedium),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(String message) {
    final theme = FlutterFlowTheme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.cloud_off_outlined,
                color: Colors.grey.shade400, size: 80),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16.0),
              child: Text(
                'Could not load orders',
                textAlign: TextAlign.center,
                style: theme.titleLarge,
              ),
            ),
            Text(
              message,
              textAlign: TextAlign.center,
              style: theme.bodyMedium
                  .override(fontFamily: 'Poppins', color: theme.secondaryText),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 24.0),
              child: ElevatedButton.icon(
                icon: const Icon(Icons.refresh),
                label: const Text('Retry'),
                onPressed: _onRefresh,
                style: ElevatedButton.styleFrom(
                  backgroundColor: theme.primary,
                  foregroundColor: Colors.white,
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildOrdersList(List<WaterOrder> orders) {
    return RefreshIndicator(
      onRefresh: _onRefresh,
      child: ListView.builder(
        padding: const EdgeInsets.all(16.0),
        itemCount: orders.length,
        itemBuilder: (context, index) => _buildOrderCard(orders[index]),
      ),
    );
  }

  Widget _buildEmptyState() {
    final theme = FlutterFlowTheme.of(context);
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.list_alt_rounded,
              color: theme.secondaryText.withOpacity(0.5), size: 90),
          Padding(
            padding: const EdgeInsets.only(top: 24, bottom: 8),
            child: Text('No Orders Found', style: theme.headlineSmall),
          ),
          Text(
            'Your placed orders will appear here.',
            style: theme.labelMedium,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildOrderCard(WaterOrder order) {
    final theme = FlutterFlowTheme.of(context);
    final statusColor = _getStatusColor(order.orderStatus);

    return Card(
      clipBehavior: Clip.antiAlias,
      elevation: 3,
      shadowColor: Colors.grey.shade100,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(width: 6, color: statusColor),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Order #${order.orderId}",
                          style: theme.titleLarge.override(
                            fontFamily: 'Poppins',
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                        Text(
                          "\$${order.totalAmount.toStringAsFixed(2)}",
                          style: theme.titleLarge.override(
                            fontFamily: 'Poppins',
                            color: theme.primary,
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(Icons.calendar_today,
                            color: theme.secondaryText, size: 14),
                        const SizedBox(width: 6),
                        Text(
                          DateFormat('d MMMM yyyy, h:mm a')
                              .format(order.orderDate),
                          style: theme.bodySmall,
                        ),
                      ],
                    ),
                    const Divider(height: 24),
                    Text(
                      'Deliveries (${order.deliveries.length})',
                      style: theme.bodyMedium.override(
                          fontFamily: 'Poppins', fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 8),
                    ...order.deliveries
                        .map((delivery) => _buildDeliveryRow(delivery, theme)),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDeliveryRow(WaterDelivery delivery, FlutterFlowTheme theme) {
    final statusText = delivery.status.name.replaceAll('_', ' ').capitalize();
    final deliveryStatus = WaterOrderStatus.values.firstWhere(
        (e) => e.name == delivery.status.name,
        orElse: () => WaterOrderStatus.UNKNOWN);
    final statusColor = _getStatusColor(deliveryStatus);

    return Padding(
      padding: const EdgeInsets.only(bottom: 6.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              delivery.dropOffLocation.dropOffLocation,
              style: theme.bodyMedium.override(color: theme.secondaryText),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(width: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: statusColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              statusText,
              style: theme.bodySmall.override(
                color: statusColor,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

extension StringExtension on String {
  String capitalize() {
    if (isEmpty) return this;
    return "${this[0].toUpperCase()}${substring(1).toLowerCase()}";
  }
}
