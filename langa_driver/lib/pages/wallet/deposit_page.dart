import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:intl_phone_field/phone_number.dart' as intl_phone;
import 'package:langas_driver/bloc/auth/auth_bloc/auth_bloc_bloc.dart';
import 'package:langas_driver/bloc/auth/auth_bloc/auth_bloc_state.dart';
import 'package:langas_driver/bloc/deposit/deposit_bloc_bloc.dart';
import 'package:langas_driver/bloc/deposit/deposit_bloc_event.dart';
import 'package:langas_driver/bloc/deposit/deposit_bloc_state.dart';
import 'package:langas_driver/dto/wallet_dto.dart';
import 'package:langas_driver/flutter_flow/flutter_flow_icon_button.dart';
import 'package:langas_driver/flutter_flow/flutter_flow_theme.dart';
import 'package:langas_driver/utils/delivery_enums.dart';

class DepositPageWidget extends StatefulWidget {
  const DepositPageWidget({super.key});

  @override
  State<DepositPageWidget> createState() => _DepositPageWidgetState();
}

class _DepositPageWidgetState extends State<DepositPageWidget> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _phoneController = TextEditingController();
  final _unfocusNode = FocusNode();

  bool _isLoading = false;
  PaymentMethod? _selectedPaymentMethod;
  String? _fullMobileNumber;
  String? _driverId;
  String _driverRegisteredPhoneNumber = "";

  final List<Map<String, dynamic>> _paymentOptions = [
    {
      'name': 'EcoCash',
      'icon': Icons.phone_android_rounded,
      'color': Colors.green.shade700,
      'method': PaymentMethod.ECOCASH,
      'requiresPhone': true,
    },
    {
      'name': 'Visa/Mastercard',
      'icon': Icons.credit_card_rounded,
      'color': Colors.blue.shade700,
      'method': PaymentMethod.VISA,
      'requiresPhone': false,
    },
  ];

  @override
  void initState() {
    super.initState();
    final authState = context.read<AuthBloc>().state;
    if (authState is AuthDriverAuthenticated) {
      _driverId = authState.authData.driverProfile?.id.toString();
      _driverRegisteredPhoneNumber =
          authState.authData.driverProfile?.mobileNumber ?? "";
      if (_driverRegisteredPhoneNumber.isNotEmpty) {
        _phoneController.text = _driverRegisteredPhoneNumber.startsWith('+')
            ? _driverRegisteredPhoneNumber
                .substring(1) // Assuming intl_phone_field handles country code
            : _driverRegisteredPhoneNumber;
        _fullMobileNumber =
            _driverRegisteredPhoneNumber; // Or format it if necessary
      }
    }
    context.read<DepositBloc>().add(const ResetDepositBloc());
  }

  @override
  void dispose() {
    _amountController.dispose();
    _phoneController.dispose();
    _unfocusNode.dispose();
    super.dispose();
  }

  void _initiateDeposit() {
    if (!mounted) return;
    FocusScope.of(context).unfocus();

    if (!_formKey.currentState!.validate()) {
      return;
    }
    if (_selectedPaymentMethod == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please select a payment method."),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final double? amount = double.tryParse(_amountController.text);
    if (amount == null || amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please enter a valid amount."),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (_driverId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Driver information not found. Please re-login."),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    String phoneNumberForRequest = _driverRegisteredPhoneNumber;

    if (_selectedPaymentMethod == PaymentMethod.ECOCASH) {
      if (_fullMobileNumber == null || _fullMobileNumber!.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Please enter a valid phone number for EcoCash."),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }
      phoneNumberForRequest = _fullMobileNumber!;
    }

    final depositRequest = DriverWalletDepositRequest(
      driverId: int.parse(_driverId!),
      amount: amount,
      currencyId: 1,
      phoneNumber: phoneNumberForRequest,
      paymentMethod: _selectedPaymentMethod!,
    );

    context
        .read<DepositBloc>()
        .add(InitiateDriverDepositRequested(request: depositRequest));
  }

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);

    return GestureDetector(
      onTap: () {
        if (_unfocusNode.canRequestFocus) {
          FocusScope.of(context).requestFocus(_unfocusNode);
        } else {
          FocusScope.of(context).unfocus();
        }
      },
      child: Scaffold(
        key: _scaffoldKey,
        backgroundColor: theme.secondaryBackground,
        appBar: AppBar(
          backgroundColor: theme.primary,
          automaticallyImplyLeading: false,
          leading: FlutterFlowIconButton(
            borderColor: Colors.transparent,
            borderRadius: 30.0,
            borderWidth: 1.0,
            buttonSize: 60.0,
            icon: const Icon(
              Icons.arrow_back_rounded,
              color: Colors.white,
              size: 24.0,
            ),
            onPressed: () => context.goNamed('Wallet'),
          ),
          title: Text(
            'DEPOSIT FUNDS',
            style: theme.headlineMedium.override(
              fontFamily: 'Poppins',
              color: Colors.white,
              fontSize: 16.0,
              fontWeight: FontWeight.w600,
            ),
          ),
          centerTitle: true,
          elevation: 0,
        ),
        body: BlocListener<DepositBloc, DepositState>(
          listener: (context, state) {
            if (mounted) {
              setState(() {
                _isLoading = state is DepositInitiationLoading;
              });
            }

            if (state is DepositInitiationSuccess) {
              context.push('/paymentProcessing', extra: {
                'transactionId': state.transactionId,
                'paymentLink': state.paymentLink,
                'initialMessage': state.initialMessage,
              });
            } else if (state is DepositInitiationFailure) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                      "Deposit Initiation Failed: ${state.failure.message}"),
                  backgroundColor: Colors.red,
                ),
              );
            }
          },
          child: SafeArea(
            top: true,
            child: Stack(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Form(
                    key: _formKey,
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 24),
                          Text(
                            "Enter Amount to Deposit",
                            style: theme.titleLarge.override(
                                fontFamily: 'Poppins',
                                fontWeight: FontWeight.w600),
                          ),
                          const SizedBox(height: 8),
                          TextFormField(
                            controller: _amountController,
                            keyboardType: const TextInputType.numberWithOptions(
                                decimal: true),
                            decoration: InputDecoration(
                              hintText: "0.00",
                              prefixText: "\$",
                              prefixStyle: TextStyle(
                                color: theme.primaryText,
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                              hintStyle: TextStyle(
                                  color: theme.secondaryText, fontSize: 24),
                              filled: true,
                              fillColor: theme.primaryBackground,
                              border: OutlineInputBorder(
                                borderSide: BorderSide.none,
                                borderRadius: BorderRadius.circular(12.0),
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 20, vertical: 20),
                              enabledBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                    color: theme.alternate, width: 1),
                                borderRadius: BorderRadius.circular(12.0),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderSide:
                                    BorderSide(color: theme.primary, width: 2),
                                borderRadius: BorderRadius.circular(12.0),
                              ),
                            ),
                            style: theme.displaySmall.override(
                                fontFamily: 'Poppins',
                                color: theme.primaryText,
                                fontWeight: FontWeight.bold),
                            textAlign: TextAlign.center,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter an amount';
                              }
                              final double? amount = double.tryParse(value);
                              if (amount == null || amount <= 0) {
                                return 'Please enter a valid amount greater than 0';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 24),
                          if (_selectedPaymentMethod == PaymentMethod.ECOCASH)
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Ecocash Phone Number",
                                  style: theme.bodyMedium
                                      .copyWith(color: theme.secondaryText),
                                ),
                                const SizedBox(height: 8),
                                IntlPhoneField(
                                  controller: _phoneController,
                                  decoration: _buildInputDecoration(
                                          theme, "Enter your EcoCash number")
                                      .copyWith(counterText: ''),
                                  initialCountryCode: 'ZW',
                                  keyboardType: TextInputType.phone,
                                  onChanged: (intl_phone.PhoneNumber phone) {
                                    setState(() {
                                      _fullMobileNumber = phone.completeNumber;
                                    });
                                  },
                                  validator: (intl_phone.PhoneNumber? phone) {
                                    if (_selectedPaymentMethod ==
                                        PaymentMethod.ECOCASH) {
                                      if (phone == null ||
                                          phone.number.isEmpty) {
                                        return 'Phone number is required for EcoCash';
                                      }
                                      if (!phone.isValidNumber()) {
                                        return 'Please enter a valid phone number';
                                      }
                                    }
                                    return null;
                                  },
                                ),
                                const SizedBox(height: 20),
                              ],
                            ),
                          Text(
                            "Select Payment Method",
                            style: theme.titleLarge.override(
                                fontFamily: 'Poppins',
                                fontWeight: FontWeight.w600),
                          ),
                          const SizedBox(height: 16),
                          ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: _paymentOptions.length,
                            itemBuilder: (context, index) {
                              final option = _paymentOptions[index];
                              final PaymentMethod method =
                                  option['method'] as PaymentMethod;

                              return Padding(
                                padding: const EdgeInsets.only(bottom: 10.0),
                                child: InkWell(
                                  onTap: () {
                                    setState(() {
                                      _selectedPaymentMethod = method;
                                      if (method != PaymentMethod.ECOCASH) {
                                        _phoneController.clear();
                                        _fullMobileNumber = null;
                                      } else {
                                        _phoneController.text =
                                            _driverRegisteredPhoneNumber
                                                    .startsWith('+')
                                                ? _driverRegisteredPhoneNumber
                                                    .substring(1)
                                                : _driverRegisteredPhoneNumber;
                                        _fullMobileNumber =
                                            _driverRegisteredPhoneNumber;
                                      }
                                    });
                                  },
                                  borderRadius: BorderRadius.circular(12),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 16, vertical: 18),
                                    decoration: BoxDecoration(
                                      color: theme.primaryBackground,
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(
                                        color: _selectedPaymentMethod == method
                                            ? theme.primary
                                            : theme.alternate,
                                        width: _selectedPaymentMethod == method
                                            ? 2
                                            : 1,
                                      ),
                                    ),
                                    child: Row(
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.all(10),
                                          decoration: BoxDecoration(
                                            color: (option['color'] as Color)
                                                .withOpacity(0.1),
                                            shape: BoxShape.circle,
                                          ),
                                          child: Icon(
                                            option['icon'] as IconData,
                                            color: option['color'] as Color,
                                            size: 24,
                                          ),
                                        ),
                                        const SizedBox(width: 16),
                                        Expanded(
                                          child: Text(
                                            option['name'] as String,
                                            style: theme.bodyLarge.override(
                                              fontFamily: 'Poppins',
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                        ),
                                        if (_selectedPaymentMethod == method)
                                          Icon(Icons.check_circle,
                                              color: theme.primary, size: 24)
                                        else
                                          Icon(Icons.arrow_forward_ios,
                                              color: theme.secondaryText,
                                              size: 18),
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                          const SizedBox(height: 32),
                          SizedBox(
                            width: double.infinity,
                            height: 55,
                            child: ElevatedButton(
                              onPressed: _isLoading ? null : _initiateDeposit,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: theme.primary,
                                foregroundColor: Colors.white,
                                disabledBackgroundColor: Colors.grey,
                                padding:
                                    const EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12)),
                              ),
                              child: _isLoading
                                  ? const SizedBox(
                                      width: 24,
                                      height: 24,
                                      child: CircularProgressIndicator(
                                        color: Colors.white,
                                        strokeWidth: 3,
                                      ),
                                    )
                                  : const Text(
                                      'Proceed to Deposit',
                                      style: TextStyle(
                                          fontFamily: 'Poppins',
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold),
                                    ),
                            ),
                          ),
                          const SizedBox(height: 24),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  InputDecoration _buildInputDecoration(
      FlutterFlowTheme theme, String hintText) {
    return InputDecoration(
      hintText: hintText,
      hintStyle: theme.bodyMedium.copyWith(color: theme.secondaryText),
      filled: true,
      fillColor: theme.primaryBackground,
      enabledBorder: OutlineInputBorder(
        borderSide: BorderSide(color: theme.alternate, width: 1),
        borderRadius: BorderRadius.circular(12.0),
      ),
      focusedBorder: OutlineInputBorder(
        borderSide: BorderSide(color: theme.primary, width: 2),
        borderRadius: BorderRadius.circular(12.0),
      ),
      errorBorder: OutlineInputBorder(
        borderSide: BorderSide(color: theme.error, width: 1),
        borderRadius: BorderRadius.circular(12.0),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderSide: BorderSide(color: theme.error, width: 2),
        borderRadius: BorderRadius.circular(12.0),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
    );
  }
}
