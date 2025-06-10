import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '/flutter_flow/flutter_flow_icon_button.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';

class MyWalletWidget extends StatefulWidget {
  const MyWalletWidget({super.key});

  @override
  State<MyWalletWidget> createState() => _MyWalletWidgetState();
}

class _MyWalletWidgetState extends State<MyWalletWidget> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  final _amountController = TextEditingController();
  bool _isLoading = false;

  // Dummy data for wallet balance
  final double _walletBalance = 234.56;

  // Dummy data for transaction history
  final List<Map<String, dynamic>> _transactions = [
    {
      'status': 'Money Added',
      'createdAt': '12 Feb 2025, 10:30 AM',
      'amount': 50.00,
    },
    {
      'status': 'Payment Received',
      'createdAt': '08 Feb 2025, 2:15 PM',
      'amount': 120.50,
    },
    {
      'status': 'Money Withdrawn',
      'createdAt': '01 Feb 2025, 4:45 PM',
      'amount': 75.25,
    },
    {
      'status': 'Payment Received',
      'createdAt': '25 Jan 2025, 9:20 AM',
      'amount': 89.00,
    },
    {
      'status': 'Money Added',
      'createdAt': '15 Jan 2025, 11:05 AM',
      'amount': 50.00,
    },
  ];

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  // Simulates adding money to wallet
  void _addMoneyToWallet() {
    if (_amountController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please enter an amount"),
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    // Simulate API call delay
    Future.delayed(const Duration(seconds: 1), () {
      setState(() {
        _isLoading = false;
      });

      // Show success dialog
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(
            'Payment Successful',
            style: FlutterFlowTheme.of(context).titleMedium.override(
                  fontFamily: 'Readex Pro',
                  color: FlutterFlowTheme.of(context).primaryText,
                ),
          ),
          content: Text(
            'You have successfully added \$${_amountController.text} to your wallet.',
            style: FlutterFlowTheme.of(context).bodyMedium,
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                _amountController.clear();
              },
              child: Text(
                'OK',
                style: TextStyle(color: FlutterFlowTheme.of(context).primary),
              ),
            ),
          ],
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    if (isiOS) {
      SystemChrome.setSystemUIOverlayStyle(
        SystemUiOverlayStyle(
          statusBarBrightness: Theme.of(context).brightness,
          systemStatusBarContrastEnforced: true,
        ),
      );
    }

    return GestureDetector(
      child: Scaffold(
        key: _scaffoldKey,
        backgroundColor: FlutterFlowTheme.of(context).primaryBackground,
        appBar: _buildAppBar(),
        body: SafeArea(
          top: true,
          child: Stack(
            children: [
              _buildMainContent(),
              if (_isLoading) _buildLoadingIndicator(),
            ],
          ),
        ),
      ),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      backgroundColor: FlutterFlowTheme.of(context).primary,
      automaticallyImplyLeading: false,
      leading: FlutterFlowIconButton(
        borderColor: Colors.transparent,
        borderRadius: 30.0,
        borderWidth: 1.0,
        buttonSize: 60.0,
        icon: const Icon(
          Icons.chevron_left,
          color: Colors.white,
          size: 32.0,
        ),
        onPressed: () => context.pop(),
      ),
      title: Text(
        'MY WALLET',
        style: FlutterFlowTheme.of(context).headlineMedium.override(
              fontFamily: 'Poppins',
              color: Colors.white,
              fontSize: 16.0,
              fontWeight: FontWeight.w600,
            ),
      ),
      centerTitle: true,
      elevation: 2.0,
    );
  }

  Widget _buildMainContent() {
    return SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.max,
        children: [
          const SizedBox(height: 28.0),
          _buildWalletBalanceSection(),
          _buildTransactionHistorySection(),
        ],
      ),
    );
  }

  Widget _buildWalletBalanceSection() {
    return Padding(
      padding: const EdgeInsetsDirectional.fromSTEB(16.0, 0.0, 16.0, 0.0),
      child: Column(
        mainAxisSize: MainAxisSize.max,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Column(
                mainAxisSize: MainAxisSize.max,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Hello Gift",
                    style: FlutterFlowTheme.of(context).bodyMedium.override(
                          fontFamily: 'Poppins',
                          fontSize: 20.0,
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                  Align(
                    alignment: const AlignmentDirectional(-1.0, -1.0),
                    child: Text(
                      "Your Available Balance",
                      style: FlutterFlowTheme.of(context).bodyMedium.override(
                            fontFamily: 'Poppins',
                          ),
                    ),
                  ),
                ],
              ),
              Text(
                "\$${_walletBalance.toStringAsFixed(2)}",
                textAlign: TextAlign.start,
                style: FlutterFlowTheme.of(context).bodyMedium.override(
                      fontFamily: 'Poppins',
                      fontSize: 28.0,
                      fontWeight: FontWeight.w600,
                    ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Text(
            "Enter Amount",
            style: FlutterFlowTheme.of(context).bodyMedium.override(
                  fontFamily: 'Poppins',
                  fontSize: 16.0,
                  fontWeight: FontWeight.w600,
                ),
          ),
          const SizedBox(height: 10),
          TextFormField(
            controller: _amountController,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              hintText: "Enter Amount",
              hintStyle: const TextStyle(color: Colors.grey),
              filled: true,
              fillColor: Colors.grey[200],
              border: InputBorder.none,
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              enabledBorder: OutlineInputBorder(
                borderSide: BorderSide.none,
                borderRadius: BorderRadius.circular(8.0),
              ),
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(
                    color: FlutterFlowTheme.of(context).primary, width: 1),
                borderRadius: BorderRadius.circular(8.0),
              ),
            ),
            style: const TextStyle(
              fontSize: 16,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 20),
          _buildAddMoneyButton(),
        ],
      ),
    );
  }

  Widget _buildAddMoneyButton() {
    return InkWell(
      onTap: _addMoneyToWallet,
      child: Container(
        width: double.infinity,
        height: 56.0,
        decoration: BoxDecoration(
          color: FlutterFlowTheme.of(context).primary,
          borderRadius: BorderRadius.circular(16.0),
          border: Border.all(
            color: FlutterFlowTheme.of(context).primary,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.account_balance_wallet,
              color: Colors.white,
              size: 24.0,
            ),
            const SizedBox(width: 10),
            Text(
              "Add Money",
              style: FlutterFlowTheme.of(context).bodyMedium.override(
                    fontFamily: 'Poppins',
                    color: Colors.white,
                    fontSize: 18.0,
                    fontWeight: FontWeight.bold,
                  ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTransactionHistorySection() {
    return Padding(
      padding: const EdgeInsetsDirectional.fromSTEB(0.0, 30.0, 0.0, 0.0),
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: FlutterFlowTheme.of(context).secondaryBackground,
          borderRadius: const BorderRadius.only(
            bottomLeft: Radius.circular(0.0),
            bottomRight: Radius.circular(0.0),
            topLeft: Radius.circular(36.0),
            topRight: Radius.circular(36.0),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.max,
          children: [
            const SizedBox(height: 14.0),
            Container(
              width: 48.0,
              height: 6.0,
              decoration: BoxDecoration(
                color: const Color(0xFFDDDDDD),
                borderRadius: BorderRadius.circular(3.0),
                border: Border.all(
                  color: const Color(0xFFDDDDDD),
                ),
              ),
            ),
            const SizedBox(height: 10.0),
            Padding(
              padding:
                  const EdgeInsetsDirectional.fromSTEB(16.0, 10.0, 16.0, 0.0),
              child: Row(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    "Transaction History",
                    style: FlutterFlowTheme.of(context).bodyMedium.override(
                          fontFamily: 'Poppins',
                          fontSize: 16.0,
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16.0),
            Container(
              height: 400,
              child: _transactions.isEmpty
                  ? Center(
                      child: Text(
                        "No transactions available",
                        style: FlutterFlowTheme.of(context).bodyMedium,
                      ),
                    )
                  : ListView.builder(
                      padding: EdgeInsets.zero,
                      scrollDirection: Axis.vertical,
                      itemCount: _transactions.length,
                      itemBuilder: (context, index) {
                        final transaction = _transactions[index];
                        return Padding(
                          padding: const EdgeInsetsDirectional.fromSTEB(
                              16.0, 0.0, 16.0, 16.0),
                          child: Container(
                            decoration: BoxDecoration(
                              color: FlutterFlowTheme.of(context)
                                  .secondaryBackground,
                              borderRadius: BorderRadius.circular(8),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.grey.withOpacity(0.1),
                                  spreadRadius: 1,
                                  blurRadius: 2,
                                  offset: const Offset(0, 1),
                                ),
                              ],
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(12.0),
                              child: Row(
                                mainAxisSize: MainAxisSize.max,
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    mainAxisSize: MainAxisSize.max,
                                    children: [
                                      Container(
                                        width: 44.0,
                                        height: 44.0,
                                        decoration: BoxDecoration(
                                          color: FlutterFlowTheme.of(context)
                                              .primary
                                              .withOpacity(0.1),
                                          shape: BoxShape.circle,
                                        ),
                                        child: Icon(
                                          Icons.account_balance_wallet,
                                          color: FlutterFlowTheme.of(context)
                                              .primary,
                                          size: 24,
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Column(
                                        mainAxisSize: MainAxisSize.max,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            transaction['status'],
                                            style: FlutterFlowTheme.of(context)
                                                .bodyMedium
                                                .override(
                                                  fontFamily: 'Poppins',
                                                  fontSize: 15.0,
                                                  fontWeight: FontWeight.w500,
                                                ),
                                          ),
                                          Text(
                                            transaction['createdAt'],
                                            style: FlutterFlowTheme.of(context)
                                                .bodyMedium
                                                .override(
                                                  fontFamily: 'Poppins',
                                                  fontSize: 12.0,
                                                  color: Colors.grey,
                                                ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                  Text(
                                    "\$${transaction['amount'].toStringAsFixed(2)}",
                                    textAlign: TextAlign.start,
                                    style: FlutterFlowTheme.of(context)
                                        .bodyMedium
                                        .override(
                                          fontFamily: 'Poppins',
                                          color: Colors.green,
                                          fontSize: 18.0,
                                          fontWeight: FontWeight.w600,
                                        ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingIndicator() {
    return Container(
      color: Colors.black.withOpacity(0.3),
      child: Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(
              FlutterFlowTheme.of(context).primary),
        ),
      ),
    );
  }
}
