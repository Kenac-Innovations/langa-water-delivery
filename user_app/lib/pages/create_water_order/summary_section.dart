import 'package:flutter/material.dart';
import 'package:langas_user/flutter_flow/flutter_flow_theme.dart';
import 'package:langas_user/pages/create_water_order/create_water_order_page.dart';

class SummarySection extends StatelessWidget {
  final List<DeliveryModel> deliveries;
  final double totalAmount;

  const SummarySection({
    super.key,
    required this.deliveries,
    required this.totalAmount,
  });

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(16.0),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.grey.shade200, width: 1),
          ),
          child: Column(
            children: [
              ...deliveries.asMap().entries.map((entry) {
                int idx = entry.key;
                DeliveryModel delivery = entry.value;
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Delivery #${idx + 1} (${delivery.quantityController.text}L)',
                        style: theme.bodyMedium,
                      ),
                      Text(
                        '\$${delivery.price.toStringAsFixed(2)}',
                        style: theme.bodyMedium,
                      ),
                    ],
                  ),
                );
              }).toList(),
              const Divider(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Total Amount',
                      style: theme.titleMedium.override(
                          fontFamily: 'Poppins',
                          fontWeight: FontWeight.bold,
                          fontSize: 15)),
                  Text('\$${totalAmount.toStringAsFixed(2)}',
                      style: theme.titleMedium.override(
                          fontFamily: 'Poppins',
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                          color: theme.primaryText)),
                ],
              ),
            ],
          ),
        )
      ],
    );
  }
}
