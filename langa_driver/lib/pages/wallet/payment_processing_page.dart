import 'dart:async';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:langas_driver/bloc/deposit/deposit_bloc_bloc.dart';
import 'package:langas_driver/bloc/deposit/deposit_bloc_event.dart';
import 'package:langas_driver/bloc/deposit/deposit_bloc_state.dart';
import 'package:langas_driver/flutter_flow/flutter_flow_theme.dart';
import 'package:webview_flutter/webview_flutter.dart';

class PaymentProcessingPage extends StatefulWidget {
  final String transactionId;
  final String? paymentLink;
  final String? initialMessage;

  const PaymentProcessingPage({
    super.key,
    required this.transactionId,
    this.paymentLink,
    this.initialMessage,
  });

  @override
  State<PaymentProcessingPage> createState() => _PaymentProcessingPageState();
}

class _PaymentProcessingPageState extends State<PaymentProcessingPage> {
  WebViewController? _webViewController;
  StreamSubscription? _firebaseSubscription;
  bool _webViewLoading = true;
  bool _isPaymentCompletedOrFailed = false;
  bool _isWaitingForFirebaseAfterRedirect = false;
  Uri? _initialWebViewUri;

  @override
  void initState() {
    super.initState();

    if (widget.paymentLink != null && widget.paymentLink!.isNotEmpty) {
      _initialWebViewUri = Uri.tryParse(widget.paymentLink!);
      _webViewController = WebViewController()
        ..setJavaScriptMode(JavaScriptMode.unrestricted)
        ..setBackgroundColor(const Color(0x00000000))
        ..setNavigationDelegate(
          NavigationDelegate(
            onPageStarted: (String url) {
              if (mounted) setState(() => _webViewLoading = true);
            },
            onPageFinished: (String url) {
              if (mounted) setState(() => _webViewLoading = false);
            },
            onWebResourceError: (WebResourceError error) {
              if (mounted) setState(() => _webViewLoading = false);
            },
            onNavigationRequest: (NavigationRequest request) {
              final Uri requestedUri = Uri.parse(request.url);
              if (_initialWebViewUri != null &&
                  (requestedUri.scheme != _initialWebViewUri!.scheme ||
                      requestedUri.host != _initialWebViewUri!.host)) {
                if (mounted) {
                  setState(() {
                    _isWaitingForFirebaseAfterRedirect = true;
                  });
                }
                return NavigationDecision.prevent;
              }
              return NavigationDecision.navigate;
            },
          ),
        )
        ..loadRequest(Uri.parse(widget.paymentLink!));
    } else {
      _webViewLoading = false;
    }
    _startFirebaseListener();
  }

  void _startFirebaseListener() {
    _firebaseSubscription = FirebaseDatabase.instance
        .ref('transactions/${widget.transactionId}')
        .onValue
        .listen((DatabaseEvent event) {
      if (event.snapshot.exists && event.snapshot.value != null) {
        final data = Map<String, dynamic>.from(event.snapshot.value as Map);
        final status = data['status'] as String?;
        final narration = data['narration'] as String?;

        if (status != null && mounted && !_isPaymentCompletedOrFailed) {
          context.read<DepositBloc>().add(FirebaseTransactionUpdateReceived(
                transactionId: widget.transactionId,
                status: status,
                narration: narration,
              ));
        }
      }
    }, onError: (error) {
      if (mounted && !_isPaymentCompletedOrFailed) {
        context.read<DepositBloc>().add(FirebaseTransactionUpdateReceived(
              transactionId: widget.transactionId,
              status: "FAILED",
              narration: "Error listening to transaction status: $error",
            ));
      }
    });
  }

  @override
  void dispose() {
    _firebaseSubscription?.cancel();
    super.dispose();
  }

  void _handleClose(BuildContext ctx) {
    ctx.read<DepositBloc>().add(const ResetDepositBloc());
    if (GoRouter.of(ctx).canPop()) {
      GoRouter.of(ctx).pop();
    } else {
      GoRouter.of(ctx).go('/wallet');
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);

    return WillPopScope(
      onWillPop: () async {
        _handleClose(context);
        return false;
      },
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: theme.primary,
          title: Text(
            'Processing Payment',
            style: theme.headlineMedium.override(
              fontFamily: 'Poppins',
              color: Colors.white,
              fontSize: 18.0,
            ),
          ),
          automaticallyImplyLeading: false,
          actions: [
            IconButton(
              icon: const Icon(Icons.close, color: Colors.white),
              onPressed: () => _handleClose(context),
            )
          ],
        ),
        backgroundColor: theme.secondaryBackground,
        body: BlocListener<DepositBloc, DepositState>(
          listener: (context, state) {
            if (state is DepositProcessingSuccess) {
              _isPaymentCompletedOrFailed = true;
              _firebaseSubscription?.cancel();
              context.go('/paymentSuccess', extra: {
                'message': state.message,
                'transactionId': state.transactionId
              });
            } else if (state is DepositProcessingFailure) {
              _isPaymentCompletedOrFailed = true;
              _firebaseSubscription?.cancel();
              context.go('/paymentFailure', extra: {
                'error': state.error,
                'transactionId': state.transactionId
              });
            }
          },
          child: BlocBuilder<DepositBloc, DepositState>(
            builder: (context, state) {
              if (state is DepositInitiationLoading) {
                return _buildLoadingIndicator(theme, "Initializing...");
              }

              if (_isWaitingForFirebaseAfterRedirect) {
                return _buildAwaitingCompletionUI(
                    theme, "Waiting for payment confirmation...",
                    isAfterRedirect: true);
              }

              if (widget.paymentLink != null &&
                  widget.paymentLink!.isNotEmpty) {
                if (_webViewController == null) {
                  return _buildLoadingIndicator(
                      theme, "Setting up payment page...");
                }
                return Stack(
                  children: [
                    WebViewWidget(controller: _webViewController!),
                    if (_webViewLoading)
                      _buildLoadingIndicator(theme, "Loading payment page..."),
                  ],
                );
              } else if (state is DepositAwaitingCompletion) {
                return _buildAwaitingCompletionUI(theme, state.message);
              }
              return _buildAwaitingCompletionUI(
                  theme,
                  widget.initialMessage ??
                      "Processing your payment. Please follow any prompts on your device.");
            },
          ),
        ),
      ),
    );
  }

  Widget _buildLoadingIndicator(FlutterFlowTheme theme, String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(color: theme.primary),
          const SizedBox(height: 20),
          Text(message, style: theme.bodyLarge, textAlign: TextAlign.center),
        ],
      ),
    );
  }

  Widget _buildAwaitingCompletionUI(FlutterFlowTheme theme, String message,
      {bool isAfterRedirect = false}) {
    String displayMessage = message;
    if (isAfterRedirect) {
      displayMessage = "Verifying your payment. Please wait...";
    }

    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            CircularProgressIndicator(color: theme.primary),
            const SizedBox(height: 25),
            Text(
                isAfterRedirect
                    ? 'Finalizing Payment'
                    : 'Awaiting Payment Confirmation',
                style: theme.headlineSmall,
                textAlign: TextAlign.center),
            const SizedBox(height: 15),
            Text(
              displayMessage,
              style: theme.bodyLarge,
              textAlign: TextAlign.center,
            ),
            if (!isAfterRedirect)
              Padding(
                padding: const EdgeInsets.only(top: 10.0),
                child: Text(
                  "We are listening for updates. Please complete the payment if prompted (e.g., on your phone for EcoCash).",
                  style: theme.bodySmall.copyWith(color: theme.secondaryText),
                  textAlign: TextAlign.center,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
