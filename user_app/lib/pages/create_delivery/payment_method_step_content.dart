import 'package:flutter/material.dart';
import 'package:langas_user/flutter_flow/flutter_flow_theme.dart';
import 'package:langas_user/pages/create_delivery/form_widgets.dart';
import 'package:langas_user/util/apps_enums.dart';

class PaymentMethodStepContent extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final PaymentMethod selectedPaymentMethod;
  final bool autoAssignDriver;
  final Function(PaymentMethod?) onPaymentChanged;
  final Function(bool) onAssignmentChanged;

  const PaymentMethodStepContent({
    Key? key,
    required this.formKey,
    required this.selectedPaymentMethod,
    required this.autoAssignDriver,
    required this.onPaymentChanged,
    required this.onAssignmentChanged,
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
              "Select payment and driver assignment",
              style: FlutterFlowTheme.of(context).bodyMedium.override(
                    fontFamily: 'Poppins',
                    color: Colors.black54,
                    fontSize: 14.0,
                  ),
            ),
            const SizedBox(height: 20),
            FormWidgets.buildPaymentOption(
              context: context,
              title: "Cash",
              subtitle: "Pay when package is delivered",
              icon: Icons.payments_outlined,
              value: PaymentMethod.CASH,
              groupValue: selectedPaymentMethod,
              onChanged: (value) => onPaymentChanged(value as PaymentMethod?),
            ),
            FormWidgets.buildPaymentOption(
              context: context,
              title: "E-Money",
              subtitle: "Pay online using your digital wallets",
              icon: Icons.account_balance_wallet_outlined,
              value: PaymentMethod.E_MONEY,
              groupValue: selectedPaymentMethod,
              onChanged: (value) => onPaymentChanged(value as PaymentMethod?),
            ),
            const SizedBox(height: 24),
            Divider(color: Colors.grey.shade300),
            const SizedBox(height: 16),
            Text(
              "Driver Assignment",
              style: FlutterFlowTheme.of(context).titleSmall.override(
                    fontFamily: 'Poppins',
                    color: Colors.black87,
                    fontSize: 16.0,
                    fontWeight: FontWeight.w600,
                  ),
            ),
            const SizedBox(height: 8),
            FormWidgets.buildToggleSwitch(
              context: context,
              title: "Auto Assign Driver",
              value: autoAssignDriver,
              onChanged: onAssignmentChanged,
            ),
            Padding(
              padding: const EdgeInsets.only(top: 4.0, left: 16.0, right: 16.0),
              child: Text(
                autoAssignDriver
                    ? "The system will automatically find the nearest available driver."
                    : "You will need to select a driver manually later.",
                style: FlutterFlowTheme.of(context).bodySmall.override(
                      fontFamily: 'Poppins',
                      color: Colors.grey.shade600,
                    ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
