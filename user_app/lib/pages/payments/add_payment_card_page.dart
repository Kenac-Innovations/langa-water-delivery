import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:langas_user/flutter_flow/flutter_flow_theme.dart';
import 'package:ml_card_scanner/ml_card_scanner.dart';
import 'package:fluttertoast/fluttertoast.dart';

class AddPaymentCardPage extends StatefulWidget {
  const AddPaymentCardPage({super.key});

  @override
  State<AddPaymentCardPage> createState() => _AddPaymentCardPageState();
}

class _AddPaymentCardPageState extends State<AddPaymentCardPage> {
  final _formKey = GlobalKey<FormState>();
  final _cardHolderController = TextEditingController();
  final _cardNumberController = TextEditingController();
  final _expiryDateController = TextEditingController();
  String? _selectedCardType;
  final List<String> _cardTypes = [
    'ZIMSWITCH',
    'VISA',
    'MASTERCARD',
    'AMERICAN EXPRESS',
    'DISCOVER',
    'JCB',
    'CHINA UNION PAY'
  ];

  final ScannerWidgetController _controller = ScannerWidgetController();
  bool _isScanning = false;

  @override
  void initState() {
    super.initState();
    _controller
      ..setCardListener(_onListenCard)
      ..setErrorListener(_onError);
  }

  void _onListenCard(CardInfo? value) {
    if (value != null) {
      setState(() {
        _isScanning = false;
        _cardNumberController.text = value.numberFormatted();
        _expiryDateController.text = value.expiry ?? '';
        final type = value.type.toString().split('.').last.toUpperCase();
        if (_cardTypes.contains(type)) {
          _selectedCardType = type;
        }
      });
    }
  }

  void _onError(ScannerException exception) {
    if (kDebugMode) {
      print('Scanner Error: ${exception.message}');
    }
    Fluttertoast.showToast(msg: "Scanner error: ${exception.message}");
    setState(() {
      _isScanning = false;
    });
  }

  void _saveCard() {
    if (_formKey.currentState!.validate()) {
      Fluttertoast.showToast(msg: "Card Saved!", backgroundColor: Colors.green);
      context.pop();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _cardHolderController.dispose();
    _cardNumberController.dispose();
    _expiryDateController.dispose();
    super.dispose();
  }

  Widget _buildFormView() {
    final theme = FlutterFlowTheme.of(context);
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Form(
        key: _formKey,
        child: Column(
          children: [
            OutlinedButton.icon(
              onPressed: () => setState(() => _isScanning = true),
              icon: const Icon(Icons.credit_card),
              label: const Text('Scan Card to Fill Details'),
              style: OutlinedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
                foregroundColor: theme.primaryText,
              ),
            ),
            const SizedBox(height: 30),
            DropdownButtonFormField<String>(
              value: _selectedCardType,
              items: _cardTypes
                  .map((type) =>
                      DropdownMenuItem(value: type, child: Text(type)))
                  .toList(),
              onChanged: (value) => setState(() => _selectedCardType = value),
              decoration: _buildInputDecoration(label: 'Card Type'),
              validator: (v) => v == null ? 'Please select a card type' : null,
            ),
            const SizedBox(height: 20),
            TextFormField(
              controller: _cardHolderController,
              decoration: _buildInputDecoration(label: 'Cardholder Name'),
              validator: (v) => v!.isEmpty ? 'Enter cardholder name' : null,
            ),
            const SizedBox(height: 20),
            TextFormField(
              controller: _cardNumberController,
              decoration: _buildInputDecoration(label: 'Card Number'),
              keyboardType: TextInputType.number,
              validator: (v) =>
                  (v == null || v.isEmpty) ? 'Enter a valid card number' : null,
            ),
            const SizedBox(height: 20),
            TextFormField(
              controller: _expiryDateController,
              decoration: _buildInputDecoration(label: 'Expiry Date (MM/YY)'),
              keyboardType: TextInputType.number,
              validator: (v) =>
                  (v == null || v.isEmpty) ? 'Enter a valid expiry date' : null,
            ),
            const SizedBox(height: 40),
            ElevatedButton(
              onPressed: _saveCard,
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 55),
                backgroundColor: theme.primary,
                foregroundColor: Colors.white,
              ),
              child: const Text('Save Card', style: TextStyle(fontSize: 16)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildScannerView() {
    return Stack(
      children: [
        ScannerWidget(
          controller: _controller,
          oneShotScanning: true,
        ),
        // Positioned widget to overlay a cancel button on the scanner
        Positioned(
          top: 16,
          left: 16,
          child: IconButton(
            icon: const CircleAvatar(
              backgroundColor: Colors.black54,
              child: Icon(Icons.close, color: Colors.white),
            ),
            onPressed: () => setState(() => _isScanning = false),
          ),
        )
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(_isScanning ? 'Scan Your Card' : 'Add New Card'),
        backgroundColor: theme.primary,
        foregroundColor: Colors.white,
        // Hide the back button when in scanning mode to prevent confusion
        leading: _isScanning ? const SizedBox.shrink() : null,
        automaticallyImplyLeading: !_isScanning,
      ),
      body: _isScanning ? _buildScannerView() : _buildFormView(),
    );
  }

  InputDecoration _buildInputDecoration({required String label}) {
    return InputDecoration(
      labelText: label,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
    );
  }
}
