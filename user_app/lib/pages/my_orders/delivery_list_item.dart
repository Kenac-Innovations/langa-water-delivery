import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:langas_user/flutter_flow/flutter_flow_theme.dart';
import 'package:langas_user/models/water_order_model.dart';
import 'package:langas_user/util/apps_enums.dart';

class DeliveryListItem extends StatefulWidget {
  final WaterDelivery delivery;
  const DeliveryListItem({super.key, required this.delivery});

  @override
  State<DeliveryListItem> createState() => _DeliveryListItemState();
}

class _DeliveryListItemState extends State<DeliveryListItem> {
  bool _isExpanded = false;

  ({Color color, IconData icon, String text}) _getStatusProperties(
      FlutterFlowTheme theme) {
    if (widget.delivery.isScheduled == true &&
        (widget.delivery.status == WaterDeliveryStatus.CREATED ||
            widget.delivery.status == WaterDeliveryStatus.OPEN)) {
      return (
        color: const Color(0xFF6f42c1),
        icon: Icons.calendar_today_outlined,
        text: 'Scheduled'
      );
    }

    switch (widget.delivery.status) {
      case WaterDeliveryStatus.COMPLETED:
        return (
          color: theme.success,
          icon: Icons.check_circle_outline,
          text: 'Delivered'
        );
      case WaterDeliveryStatus.CANCELLED:
        return (
          color: theme.error,
          icon: Icons.cancel_outlined,
          text: 'Cancelled'
        );
      case WaterDeliveryStatus.ASSIGNED:
      case WaterDeliveryStatus.PICKED_UP:
      case WaterDeliveryStatus.ON_ROUTE:
        return (
          color: theme.primary,
          icon: Icons.local_shipping_outlined,
          text: 'On Route'
        );
      case WaterDeliveryStatus.CREATED:
      case WaterDeliveryStatus.OPEN:
        return (
          color: theme.warning,
          icon: Icons.hourglass_top_outlined,
          text: 'Pending'
        );
      default:
        return (
          color: theme.secondaryText,
          icon: Icons.help_outline,
          text: 'Unknown'
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);
    final status = _getStatusProperties(theme);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade200, width: 1)),
      child: ExpansionTile(
        tilePadding: EdgeInsets.zero,
        onExpansionChanged: (expanded) =>
            setState(() => _isExpanded = expanded),
        trailing: Icon(
            _isExpanded ? Icons.keyboard_arrow_down : Icons.arrow_forward_ios,
            size: 18,
            color: theme.secondaryText),
        title: Row(
          children: [
            CircleAvatar(
              radius: 20,
              backgroundColor: status.color.withOpacity(0.1),
              child: Icon(status.icon, color: status.color, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                      "DEL-${widget.delivery.deliveryId.toString().padLeft(3, '0')}",
                      style: theme.bodyLarge
                          .override(fontWeight: FontWeight.bold)),
                  Text(
                    widget.delivery.dropOffLocation.dropOffLocation,
                    style: theme.bodySmall,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
        children: [
          const SizedBox(height: 12),
          _buildExpandedDetails(theme),
        ],
      ),
    );
  }

  Widget _buildExpandedDetails(FlutterFlowTheme theme) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
          color: const Color(0xFFF7F8FA),
          borderRadius: BorderRadius.circular(12)),
      child: Column(
        children: [
          Row(
            children: [
              _buildInfoChip(theme,
                  label: 'LITRES',
                  value: '${widget.delivery.quantity}',
                  icon: Icons.opacity_outlined),
              const SizedBox(width: 12),
              _buildInfoChip(theme,
                  label: 'AMOUNT',
                  value: '\$${widget.delivery.priceAmount.toStringAsFixed(2)}',
                  icon: Icons.monetization_on_outlined),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {
                    // TODO: Implement Contact logic
                  },
                  icon: const Icon(Icons.phone_outlined, size: 18),
                  label: const Text('Contact'),
                  style: OutlinedButton.styleFrom(
                      foregroundColor: theme.primaryText,
                      side: BorderSide(color: Colors.grey.shade300),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8))),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {
                    // TODO: Implement Cancellation
                  },
                  icon: const Icon(Icons.cancel_outlined, size: 18),
                  label: const Text('Cancel'),
                  style: OutlinedButton.styleFrom(
                      foregroundColor: theme.error,
                      side: BorderSide(color: theme.error.withOpacity(0.4)),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8))),
                ),
              ),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildInfoChip(FlutterFlowTheme theme,
      {required String label, required String value, required IconData icon}) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: theme.secondaryText, size: 14),
              const SizedBox(width: 4),
              Text(label, style: theme.labelSmall),
            ],
          ),
          const SizedBox(height: 4),
          Text(value,
              style: theme.bodyMedium.override(fontWeight: FontWeight.bold)),
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
