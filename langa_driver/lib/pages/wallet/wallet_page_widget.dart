import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:langas_driver/bloc/auth/auth_bloc/auth_bloc_bloc.dart';
import 'package:langas_driver/bloc/auth/auth_bloc/auth_bloc_state.dart';
import 'package:langas_driver/bloc/wallet/wallet_float/wallet_float_bloc_bloc.dart';
import 'package:langas_driver/bloc/wallet/wallet_float/wallet_float_bloc_event.dart';
import 'package:langas_driver/bloc/wallet/wallet_float/wallet_float_bloc_state.dart';
import 'package:langas_driver/bloc/wallet/wallet_transactions/wallet_transactions_bloc_bloc.dart';
import 'package:langas_driver/bloc/wallet/wallet_transactions/wallet_transactions_bloc_event.dart';
import 'package:langas_driver/bloc/wallet/wallet_transactions/wallet_transactions_bloc_state.dart';
import 'package:langas_driver/flutter_flow/flutter_flow_icon_button.dart';
import 'package:langas_driver/flutter_flow/flutter_flow_theme.dart';
import 'package:go_router/go_router.dart';
import 'package:langas_driver/models/wallet_model.dart';
import 'package:langas_driver/utils/app_enums.dart' as app_enums;
import 'package:langas_driver/utils/app_enums.dart';
import 'package:langas_driver/utils/failure_models.dart';

class DriverWalletWidget extends StatefulWidget {
  const DriverWalletWidget({super.key});

  @override
  State<DriverWalletWidget> createState() => _DriverWalletWidgetState();
}

class _DriverWalletWidgetState extends State<DriverWalletWidget> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  final _unfocusNode = FocusNode();
  final ScrollController _scrollController = ScrollController();
  String? _driverId;
  String? _walletId;

  @override
  void initState() {
    super.initState();
    final authState = context.read<AuthBloc>().state;
    if (authState is AuthDriverAuthenticated) {
      _driverId = authState.authData.driverProfile?.id.toString();
      if (_driverId != null && _driverId!.isNotEmpty) {
        context
            .read<WalletFloatBloc>()
            .add(FetchWalletFloat(driverId: _driverId!));
        context
            .read<WalletTransactionsBloc>()
            .add(FetchWalletTransactions(driverId: _driverId!));
      } else {
        _showError("Driver ID not found. Cannot load wallet data.");
      }
    } else {
      _showError("User not authenticated. Cannot load wallet data.");
    }
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (_isBottom && _driverId != null) {
      final transactionsBloc = context.read<WalletTransactionsBloc>();
      final currentState = transactionsBloc.state;
      if (currentState is WalletTransactionsLoadSuccess &&
          !currentState.hasReachedMax) {
        transactionsBloc.add(FetchMoreWalletTransactions(driverId: _driverId!));
      }
    }
  }

  bool get _isBottom {
    if (!_scrollController.hasClients) return false;
    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.offset;
    return currentScroll >= (maxScroll * 0.9);
  }

  void _showError(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message), backgroundColor: Colors.red),
      );
    }
  }

  @override
  void dispose() {
    _unfocusNode.dispose();
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (Theme.of(context).platform == TargetPlatform.iOS) {
      SystemChrome.setSystemUIOverlayStyle(
        SystemUiOverlayStyle(
          statusBarBrightness: Theme.of(context).brightness,
          systemStatusBarContrastEnforced: true,
        ),
      );
    }

    return GestureDetector(
      onTap: () => _unfocusNode.canRequestFocus
          ? FocusScope.of(context).requestFocus(_unfocusNode)
          : FocusScope.of(context).unfocus(),
      child: Scaffold(
        key: _scaffoldKey,
        backgroundColor: FlutterFlowTheme.of(context).primaryBackground,
        appBar: _buildAppBar(),
        body: SafeArea(
          top: true,
          child: RefreshIndicator(
            onRefresh: () async {
              if (_driverId != null && _driverId!.isNotEmpty) {
                context
                    .read<WalletFloatBloc>()
                    .add(FetchWalletFloat(driverId: _driverId!));
                context.read<WalletTransactionsBloc>().add(
                    FetchWalletTransactions(
                        driverId: _driverId!, isRefresh: true));
              }
            },
            child: _buildMainContent(),
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
          Icons.arrow_back_rounded,
          color: Colors.white,
          size: 24.0,
        ),
        onPressed: () => context.goNamed('HomePage'),
      ),
      title: Text(
        'My Wallet',
        style: FlutterFlowTheme.of(context).headlineMedium.override(
              fontFamily: 'Poppins',
              color: Colors.white,
              fontSize: 16.0,
              fontWeight: FontWeight.w600,
            ),
      ),
      centerTitle: true,
      elevation: 0,
    );
  }

  Widget _buildMainContent() {
    return ListView(
      controller: _scrollController,
      children: [
        const SizedBox(height: 28.0),
        _buildWalletBalanceSection(),
        _buildTransactionHistorySection(),
        const SizedBox(height: 20),
      ],
    );
  }

  Widget _buildWalletBalanceSection() {
    return Padding(
      padding: const EdgeInsetsDirectional.fromSTEB(16.0, 0.0, 16.0, 0.0),
      child: BlocConsumer<WalletFloatBloc, WalletFloatState>(
        listener: (context, state) {
          if (state is WalletFloatLoadSuccess) {
            _walletId = state.walletFloat.walletId.toString();
          } else if (state is WalletFloatLoadFailure) {
            final failure = state.failure;
            if (failure is ServerFailure && failure.statusCode == 400) {
            } else {
              _showError("Error fetching wallet: ${state.failure.message}");
            }
          }
        },
        builder: (context, state) {
          if (state is WalletFloatLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state is WalletFloatLoadFailure) {
            final failure = state.failure;
            if (failure is ServerFailure && failure.statusCode == 400) {
              return _buildPendingApprovalCard();
            }
            return Center(child: Text("Error: ${state.failure.message}"));
          }
          if (state is WalletFloatLoadSuccess) {
            final walletFloat = state.walletFloat;
            return Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: FlutterFlowTheme.of(context).primary,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Available Balance",
                          style:
                              FlutterFlowTheme.of(context).bodyMedium.override(
                                    fontFamily: 'Poppins',
                                    color: Colors.white.withOpacity(0.8),
                                    fontSize: 14.0,
                                  ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 5),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.account_balance_wallet,
                                color: Colors.white,
                                size: 16,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                walletFloat.currencyCode.isNotEmpty
                                    ? walletFloat.currencyCode
                                    : "Wallet",
                                style: FlutterFlowTheme.of(context)
                                    .bodyMedium
                                    .override(
                                      fontFamily: 'Poppins',
                                      color: Colors.white,
                                      fontSize: 12.0,
                                    ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Text(
                      "${walletFloat.currencyCode} ${walletFloat.runningBalance.toStringAsFixed(2)}",
                      style: FlutterFlowTheme.of(context).bodyMedium.override(
                            fontFamily: 'Poppins',
                            color: Colors.white,
                            fontSize: 32.0,
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      child: _buildActionButton(
                        icon: Icons.add,
                        label: "Deposit",
                        onTap: () {
                          context.push('/depositPage');
                        },
                      ),
                    ),
                  ],
                ),
              ),
            );
          }
          return const Center(child: Text("Loading wallet details..."));
        },
      ),
    );
  }

  Widget _buildPendingApprovalCard() {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
          color: Colors.orange.shade100,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.orange.shade300)),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.hourglass_empty_rounded,
              color: Colors.orange.shade700, size: 40),
          const SizedBox(height: 16),
          Text(
            "Wallet Pending Approval",
            style: FlutterFlowTheme.of(context).titleMedium.override(
                fontFamily: 'Poppins',
                color: Colors.orange.shade800,
                fontWeight: FontWeight.w600),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            "Your wallet is currently awaiting approval. Please check back later. You will be notified once it's active.",
            style: FlutterFlowTheme.of(context).bodyMedium.override(
                  fontFamily: 'Poppins',
                  color: Colors.orange.shade700,
                ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: FlutterFlowTheme.of(context).primary,
              size: 20,
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: FlutterFlowTheme.of(context).bodyMedium.override(
                    fontFamily: 'Poppins',
                    color: FlutterFlowTheme.of(context).primary,
                    fontSize: 14.0,
                    fontWeight: FontWeight.w600,
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
            topLeft: Radius.circular(36.0),
            topRight: Radius.circular(36.0),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 14.0),
            Container(
              width: 48.0,
              height: 6.0,
              decoration: BoxDecoration(
                color: const Color(0xFFDDDDDD),
                borderRadius: BorderRadius.circular(3.0),
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
                          fontSize: 18.0,
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16.0),
            BlocBuilder<WalletTransactionsBloc, WalletTransactionsState>(
              builder: (context, state) {
                if (state is WalletTransactionsLoading &&
                    !(state is WalletTransactionsLoadingNextPage)) {
                  return const Padding(
                    padding: EdgeInsets.symmetric(vertical: 50.0),
                    child: Center(child: CircularProgressIndicator()),
                  );
                }
                if (state is WalletTransactionsLoadFailure) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 50.0),
                    child:
                        Center(child: Text("Error: ${state.failure.message}")),
                  );
                }
                if (state is WalletTransactionsLoadSuccess) {
                  if (state.transactions.isEmpty) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 50.0),
                      child: Center(
                        child: Text(
                          "No transactions available",
                          style: FlutterFlowTheme.of(context).bodyMedium,
                        ),
                      ),
                    );
                  }
                  return ConstrainedBox(
                    constraints: BoxConstraints(
                      maxHeight: MediaQuery.of(context).size.height * 0.5,
                    ),
                    child: ListView.builder(
                      shrinkWrap: true,
                      padding: EdgeInsets.zero,
                      itemCount: state.hasReachedMax
                          ? state.transactions.length
                          : state.transactions.length + 1,
                      itemBuilder: (context, index) {
                        if (index >= state.transactions.length) {
                          if (state is WalletTransactionsLoadingNextPage) {
                            return const Center(
                                child: Padding(
                                    padding: EdgeInsets.all(16.0),
                                    child: CircularProgressIndicator()));
                          } else if (state is WalletTransactionsNextPageError) {
                            return Center(
                                child: Padding(
                                    padding: const EdgeInsets.all(16.0),
                                    child: Text(
                                        'Error loading more: ${state.failure.message}')));
                          }
                          return const SizedBox.shrink();
                        }
                        final transaction = state.transactions[index];
                        return _buildTransactionItem(
                            transaction, FlutterFlowTheme.of(context));
                      },
                    ),
                  );
                }
                return const Padding(
                  padding: EdgeInsets.symmetric(vertical: 50.0),
                  child: Center(child: Text("Loading transactions...")),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTransactionItem(
      WalletTransaction transaction, FlutterFlowTheme theme) {
    IconData iconData;
    Color itemColor;
    String title;
    String amountText;
    String subtitle;
    double amountToDisplay = transaction.principalAmount;
    String sign = "";

    bool isSuccessful =
        transaction.status == app_enums.TransactionStatus.COMPLETED ||
            transaction.status == app_enums.TransactionStatus.PAID ||
            transaction.status == app_enums.TransactionStatus.DELIVERED;

    bool isFailedOrCancelled =
        transaction.status == app_enums.TransactionStatus.FAILED ||
            transaction.status == app_enums.TransactionStatus.CANCELED ||
            transaction.status == app_enums.TransactionStatus.CANCELED ||
            transaction.status == app_enums.TransactionStatus.REVERSED;

    switch (transaction.type) {
      case TransactionType.DEPOSIT:
        title = transaction.narration.isNotEmpty
            ? transaction.narration
            : "Deposit";
        subtitle =
            "${transaction.paymentMethod.name} (${transaction.status.name})";
        iconData = Icons.arrow_downward;
        amountToDisplay = transaction.principalAmount;
        if (isSuccessful) {
          itemColor = Colors.green;
          sign = "+ ";
        } else if (isFailedOrCancelled) {
          itemColor = Colors.red;
          iconData = Icons.error_outline;
        } else {
          itemColor = Colors.orange;
        }
        break;
      case TransactionType.COMMISSION:
        title = transaction.narration.isNotEmpty
            ? transaction.narration
            : "Langa's Charges";
        subtitle = "Platform commission";
        iconData = Icons.arrow_upward;
        amountToDisplay = transaction.commissionAmount ?? 0.0;
        itemColor = Colors.red;
        sign = "- ";
        break;
      case TransactionType.WITHDRAWAL:
        title = transaction.narration.isNotEmpty
            ? transaction.narration
            : "Withdrawal";
        subtitle = "Ref: ${transaction.reference}";
        iconData = Icons.arrow_upward;
        amountToDisplay = transaction.principalAmount;
        if (isSuccessful) {
          itemColor = Colors.red; // Successful withdrawal is a debit
          sign = "- ";
        } else if (isFailedOrCancelled) {
          itemColor = Colors.red;
          iconData = Icons.error_outline;
        } else {
          itemColor = Colors.orange;
        }
        break;
      case TransactionType.PAYMENT:
        title = transaction.narration.isNotEmpty
            ? transaction.narration
            : "Payment Made";
        subtitle = "Ref: ${transaction.reference}";
        iconData = Icons.arrow_upward;
        amountToDisplay = transaction.principalAmount;
        if (isSuccessful) {
          itemColor = Colors.red; // Successful payment is a debit
          sign = "- ";
        } else if (isFailedOrCancelled) {
          itemColor = Colors.red;
          iconData = Icons.error_outline;
        } else {
          itemColor = Colors.orange;
        }
        break;
      default:
        title = transaction.narration.isNotEmpty
            ? transaction.narration
            : transaction.type.name;
        subtitle = "Ref: ${transaction.reference}";
        iconData = Icons.swap_horiz;
        amountToDisplay = transaction.principalAmount;
        if (isFailedOrCancelled) {
          itemColor = Colors.red;
          iconData = Icons.error_outline;
        } else {
          itemColor = theme.secondaryText;
        }
        break;
    }
    amountText = "$sign${amountToDisplay.toStringAsFixed(2)}";

    return Padding(
      padding: const EdgeInsetsDirectional.fromSTEB(16.0, 0.0, 16.0, 16.0),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
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
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                mainAxisSize: MainAxisSize.max,
                children: [
                  Container(
                    width: 44.0,
                    height: 44.0,
                    decoration: BoxDecoration(
                      color: itemColor.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      iconData,
                      color: itemColor,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    mainAxisSize: MainAxisSize.max,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title.length > 18
                            ? '${title.substring(0, 15)}…'
                            : title,
                        style: theme.bodyMedium.override(
                          fontFamily: 'Poppins',
                          fontSize: 15.0,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        subtitle,
                        style: theme.bodyMedium.override(
                          fontFamily: 'Poppins',
                          fontSize: 12.0,
                          fontWeight: FontWeight.w500,
                          color: Colors.grey[600],
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        transaction.createdDate != null
                            ? DateFormat('dd MMM yy, hh:mm a')
                                .format(transaction.createdDate!)
                            : 'Date N/A',
                        style: theme.bodyMedium.override(
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
                amountText,
                textAlign: TextAlign.start,
                style: theme.bodyMedium.override(
                  fontFamily: 'Poppins',
                  color: itemColor,
                  fontSize: 16.0,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
