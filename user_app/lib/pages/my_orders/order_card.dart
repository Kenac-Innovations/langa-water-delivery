import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:langas_user/flutter_flow/flutter_flow_theme.dart';
import 'package:langas_user/models/water_order_model.dart';
import 'package:langas_user/pages/my_orders/delivery_list_item.dart';
import 'package:langas_user/util/apps_enums.dart';

class OrderCard extends StatefulWidget {
  final WaterOrder order;
  const OrderCard({super.key, required this.order});

  @override
  State<OrderCard> createState() => _OrderCardState();
}

class _OrderCardState extends State<OrderCard> {
  bool _isExpanded = false;

  Color _getStatusColor(WaterOrderStatus status, FlutterFlowTheme theme) {
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

  String _formatStatus(String status) =>
      StringExtension(status.replaceAll('_', ' ')).capitalize();

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);
    final statusColor = _getStatusColor(widget.order.orderStatus, theme);

    return Card(
      clipBehavior: Clip.antiAlias,
      elevation: 2,
      shadowColor: const Color(0x12001A7A),
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.0)),
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                        "ORD-${widget.order.orderId.toString().padLeft(3, '0')}",
                        style: theme.titleLarge
                            .override(fontWeight: FontWeight.bold)),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                          color: statusColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20)),
                      child: Text(
                          _formatStatus(widget.order.orderStatus.name),
                          style: theme.bodySmall.override(
                              color: statusColor,
                              fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
                Text(DateFormat('MMM d, yyyy').format(widget.order.orderDate),
                    style: theme.labelMedium),
                const SizedBox(height: 16),
                Row(
                  children: [
                    _buildInfoChip(theme,
                        label: 'TOTAL',
                        value:
                            '\$${widget.order.totalAmount.toStringAsFixed(2)}',
                        icon: Icons.monetization_on_outlined),
                    const Spacer(),
                     ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.asset(
                          'assets/images/water.jpg',
                          width: 60,
                          height: 60,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              width: 60,
                              height: 60,
                              color: Colors.grey.shade200,
                              child: Icon(Icons.image_not_supported_outlined,
                                  color: Colors.grey.shade400),
                            );
                          },
                        ),
                      )
                  ],
                ),
              ],
            ),
          ),
          Theme(
            data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
            child: ExpansionTile(
              onExpansionChanged: (expanded) =>
                  setState(() => _isExpanded = expanded),
              title: Text('${widget.order.deliveries.length} Deliveries',
                  style: theme.bodyMedium),
              trailing: Icon(
                  _isExpanded
                      ? Icons.keyboard_arrow_up
                      : Icons.keyboard_arrow_down,
                  color: theme.secondaryText),
              children: [
                const Divider(
                    height: 1,
                    indent: 16,
                    endIndent: 16,
                    color: Color(0xFFF1F4F8)),
                ...widget.order.deliveries
                    .map((delivery) => DeliveryListItem(delivery: delivery)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoChip(FlutterFlowTheme theme,
      {required String label,
      required String value,
      required IconData icon}) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
          color: const Color(0xFFF7F8FA),
          borderRadius: BorderRadius.circular(12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: theme.secondaryText, size: 16),
              const SizedBox(width: 4),
              Text(label, style: theme.labelSmall),
            ],
          ),
          const SizedBox(height: 4),
          Text(value,
              style: theme.titleMedium
                  .override(fontWeight: FontWeight.bold, color: theme.primaryText)),
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