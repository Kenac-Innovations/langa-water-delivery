import 'package:flutter/material.dart';
import 'package:langas_user/pages/create_water_order/form_widgets.dart';
import 'package:langas_user/util/apps_enums.dart';

class PaymentSection extends StatelessWidget {
  final WaterPaymentType selectedPaymentMethod;
  final TextEditingController promoCodeController;
  final Function(WaterPaymentType?) onPaymentChanged;

  const PaymentSection({
    super.key,
    required this.selectedPaymentMethod,
    required this.promoCodeController,
    required this.onPaymentChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("Payment Method",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        FormWidgets.buildPaymentOption(
            context: context,
            title: "On Delivery",
            subtitle: "Pay upon receiving your order",
            icon: Icons.delivery_dining,
            value: WaterPaymentType.ON_DELIVERY,
            groupValue: selectedPaymentMethod,
            onChanged: onPaymentChanged),
        FormWidgets.buildPaymentOption(
            context: context,
            title: "Instant Pay",
            subtitle: "Pay now using your wallet or card",
            icon: Icons.credit_card,
            value: WaterPaymentType.INSTANT,
            groupValue: selectedPaymentMethod,
            onChanged: onPaymentChanged),
        // FormWidgets.buildPaymentOption(
        //     context: context,
        //     title: "Credit",
        //     subtitle: "Pay later (for approved clients)",
        //     icon: Icons.timelapse,
        //     value: WaterPaymentType.CREDIT,
        //     groupValue: selectedPaymentMethod,
        //     onChanged: onPaymentChanged),
        // const SizedBox(height: 16),
        FormWidgets.buildTextField(
          context: context,
          controller: promoCodeController,
          labelText: 'Promo Code (Optional)',
          hintText: 'Enter promo code',
        )
      ],
    );
  }
}
