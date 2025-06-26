import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:langas_driver/flutter_flow/flutter_flow_theme.dart';
import 'package:langas_driver/flutter_flow/flutter_flow_widgets.dart';

class PaymentFailurePage extends StatelessWidget {
  final String? error;
  final String? transactionId;

  const PaymentFailurePage({
    super.key,
    this.error,
    this.transactionId,
  });

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);

    return Scaffold(
      backgroundColor: theme.secondaryBackground,
      appBar: AppBar(
        backgroundColor: theme.error,
        automaticallyImplyLeading: false,
        title: Text(
          'Payment Failed',
          style: theme.headlineMedium.override(
            fontFamily: 'Poppins',
            color: Colors.white,
            fontSize: 18.0,
          ),
        ),
        centerTitle: true,
        elevation: 0,
      ),
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Icon(
                  Icons.error_outline_rounded,
                  color: theme.error,
                  size: 100,
                ),
                const SizedBox(height: 24),
                Text(
                  'Payment Unsuccessful',
                  style: theme.headlineSmall.override(
                    fontFamily: 'Poppins',
                    color: theme.error,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                Text(
                  error ?? 'An unexpected error occurred during payment.',
                  style: theme.bodyLarge.override(fontFamily: 'Poppins'),
                  textAlign: TextAlign.center,
                ),
                if (transactionId != null && transactionId!.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Text(
                      'Transaction ID: $transactionId',
                      style: theme.bodyMedium.override(
                          fontFamily: 'Poppins', color: theme.secondaryText),
                      textAlign: TextAlign.center,
                    ),
                  ),
                const SizedBox(height: 40),
                FFButtonWidget(
                  onPressed: () {
                    if (GoRouter.of(context).canPop()) {
                      GoRouter.of(context).pop();
                    } else {
                      GoRouter.of(context).go('/depositPage');
                    }
                  },
                  text: 'TRY AGAIN',
                  options: FFButtonOptions(
                    width: 250,
                    height: 50,
                    color: theme.primary,
                    textStyle: theme.titleSmall.override(
                      fontFamily: 'Poppins',
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                    elevation: 2,
                    borderSide: const BorderSide(
                      color: Colors.transparent,
                      width: 1,
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                const SizedBox(height: 16),
                FFButtonWidget(
                  onPressed: () {
                    context.go('/wallet');
                  },
                  text: 'BACK TO WALLET',
                  options: FFButtonOptions(
                    width: 250,
                    height: 50,
                    color: theme.secondaryText,
                    textStyle: theme.titleSmall.override(
                      fontFamily: 'Poppins',
                      color: Colors.white,
                    ),
                    elevation: 2,
                    borderSide: const BorderSide(
                      color: Colors.transparent,
                      width: 1,
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
