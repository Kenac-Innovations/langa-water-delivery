import 'package:flutter/material.dart';
import 'package:langas_user/flutter_flow/flutter_flow_theme.dart';
import 'package:langas_user/pages/create_delivery/form_widgets.dart';
import 'package:langas_user/util/apps_enums.dart';

class DeliverySummaryStepContent extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final num deliveryCost;
  final num taxAmount;
  final num totalCost;
  final PaymentMethod selectedPaymentMethod;
  final bool isLoading;

  const DeliverySummaryStepContent({
    Key? key,
    required this.formKey,
    required this.deliveryCost,
    required this.taxAmount,
    required this.totalCost,
    required this.selectedPaymentMethod,
    required this.isLoading,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Form(
      key: formKey,
      child: Padding(
        padding: const EdgeInsets.all(5.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Review Your Delivery Cost",
              style: FlutterFlowTheme.of(context).titleMedium.override(
                    fontFamily: 'Poppins',
                    color: Colors.black87,
                    fontWeight: FontWeight.w600,
                  ),
            ),
            const SizedBox(height: 16),
            isLoading
                ? const Center(child: CircularProgressIndicator())
                : Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade50,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey.shade200),
                    ),
                    child: Column(
                      children: [
                        FormWidgets.buildCostItem(
                          context: context,
                          label: "Delivery Cost",
                          value: "\$${deliveryCost.toStringAsFixed(2)}",
                          isTotal: true,
                        ),
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              "Payment Method: ",
                              style: FlutterFlowTheme.of(context)
                                  .bodyMedium
                                  .override(
                                    fontFamily: 'Poppins',
                                    color: Colors.black54,
                                  ),
                            ),
                            Text(
                              selectedPaymentMethod == PaymentMethod.CASH
                                  ? "Cash"
                                  : "E-Money/Wallet",
                              style: FlutterFlowTheme.of(context)
                                  .bodyMedium
                                  .override(
                                    fontFamily: 'Poppins',
                                    fontWeight: FontWeight.w500,
                                    color: Colors.black87,
                                  ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
            const SizedBox(height: 10),
            if (!isLoading && totalCost <= 0)
              Center(
                child: Text(
                  "Please complete previous steps to calculate the price.",
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.orange.shade800),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
