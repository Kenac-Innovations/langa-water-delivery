import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:langas_user/bloc/auth/auth_bloc/auth_bloc_bloc.dart';
import 'package:langas_user/bloc/auth/auth_bloc/auth_bloc_state.dart';
import 'package:langas_user/bloc/payment_card/payment_card_bloc_bloc.dart';
import 'package:langas_user/bloc/payment_card/payment_card_bloc_event.dart';
import 'package:langas_user/bloc/payment_card/payment_card_bloc_state.dart';
import 'package:langas_user/flutter_flow/flutter_flow_theme.dart';
import 'package:langas_user/models/payment_card_model.dart';
import 'package:langas_user/pages/payments/add_payment_card_page.dart';
import 'package:fluttertoast/fluttertoast.dart';

class PaymentMethodPage extends StatefulWidget {
  const PaymentMethodPage({super.key});

  @override
  State<PaymentMethodPage> createState() => _PaymentMethodPageState();
}

class _PaymentMethodPageState extends State<PaymentMethodPage> {
  int? get _clientId {
    final authState = context.read<AuthBloc>().state;
    if (authState is Authenticated) {
      return authState.user.userId;
    }
    return null;
  }

  @override
  void initState() {
    super.initState();
    if (_clientId != null) {
      context.read<PaymentCardBloc>().add(FetchClientCards(_clientId!));
    }
  }

  void _setAsPreferred(int cardId) {
    if (_clientId != null) {
      context
          .read<PaymentCardBloc>()
          .add(SetDefaultPaymentCard(_clientId!, cardId));
    }
  }

  void _deleteCard(int cardId) {
    context.read<PaymentCardBloc>().add(DeletePaymentCard(cardId));
  }

  void _refreshCards() {
    if (_clientId != null) {
      context.read<PaymentCardBloc>().add(FetchClientCards(_clientId!));
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Payment Cards'),
        backgroundColor: theme.primary,
        foregroundColor: Colors.white,
        actions: [
          IconButton(onPressed: _refreshCards, icon: const Icon(Icons.refresh))
        ],
      ),
      body: BlocConsumer<PaymentCardBloc, PaymentCardState>(
        listener: (context, state) {
          if (state is PaymentCardOperationSuccess) {
            Fluttertoast.showToast(msg: state.message);
            _refreshCards();
          }
          if (state is PaymentCardFailure) {
            Fluttertoast.showToast(
                msg: state.failure.message, backgroundColor: Colors.red);
          }
        },
        builder: (context, state) {
          if (state is PaymentCardLoading && state is! PaymentCardLoadSuccess) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state is PaymentCardLoadSuccess) {
            if (state.cards.isEmpty) {
              return _buildEmptyState(context);
            }
            final preferredCard = state.cards.firstWhere((c) => c.isDefault,
                orElse: () => state.cards.first);
            final otherCards = state.cards.where((c) => !c.isDefault).toList();

            return SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Primary Card',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  CreditCardWidget(
                    cardInfo: preferredCard,
                    onSetAsPreferred: () => _setAsPreferred(preferredCard.id),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Other Cards',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          )),
                      TextButton.icon(
                        icon: Icon(Icons.add,
                            color: FlutterFlowTheme.of(context).primary),
                        label: Text(
                          'Add New',
                          style: TextStyle(
                              color: FlutterFlowTheme.of(context).primary),
                        ),
                        onPressed: () async {
                          final result = await Navigator.of(context).push(
                              MaterialPageRoute(
                                  builder: (context) =>
                                      const AddPaymentCardPage()));
                          if (result == true) {
                            _refreshCards();
                          }
                        },
                      )
                    ],
                  ),
                  const SizedBox(height: 8),
                  if (otherCards.isEmpty)
                    const Center(
                        child: Padding(
                      padding: EdgeInsets.all(16.0),
                      child: Text("No other cards added yet."),
                    )),
                  ListView.builder(
                    itemCount: otherCards.length,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemBuilder: (context, index) {
                      final card = otherCards[index];
                      return Dismissible(
                        key: ValueKey(card.id),
                        direction: DismissDirection.endToStart,
                        onDismissed: (_) => _deleteCard(card.id),
                        background: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          decoration: BoxDecoration(
                            color: theme.error,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Icon(Icons.delete, color: Colors.white),
                              SizedBox(width: 8),
                              Text('Delete',
                                  style: TextStyle(color: Colors.white)),
                            ],
                          ),
                        ),
                        child: CreditCardWidget(
                          cardInfo: card,
                          onSetAsPreferred: () => _setAsPreferred(card.id),
                        ),
                      );
                    },
                  ),
                ],
              ),
            );
          }
          return _buildEmptyState(context);
        },
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.credit_card_off, size: 80, color: Colors.grey),
          const SizedBox(height: 16),
          const Text("No Payment Cards Found",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          const Text("Add a card to get started with payments."),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            icon: const Icon(Icons.add),
            label: const Text('Add New Card'),
            style: ElevatedButton.styleFrom(
              backgroundColor: FlutterFlowTheme.of(context).primary,
              foregroundColor: Colors.white,
            ),
            onPressed: () async {
              final result = await Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) => const AddPaymentCardPage()));
              if (result == true) {
                _refreshCards();
              }
            },
          )
        ],
      ),
    );
  }
}

class CreditCardWidget extends StatelessWidget {
  final PaymentCard cardInfo;
  final VoidCallback onSetAsPreferred;

  const CreditCardWidget(
      {super.key, required this.cardInfo, required this.onSetAsPreferred});

  Widget _getLogo(String cardType) {
    String logoPath;
    switch (cardType.toUpperCase()) {
      case 'VISA':
        logoPath = 'assets/images/visa_logo.svg';
        return SvgPicture.asset(logoPath, height: 30);
      case 'MASTERCARD':
        return Image.asset('assets/images/mastercard_logo.png', height: 30);
      case 'ZIMSWITCH':
        logoPath = 'assets/images/zimswitch_logo.png';
        return Image.asset(logoPath, height: 30);
      default:
        return Text(cardType,
            style: const TextStyle(fontWeight: FontWeight.bold));
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);

    return Card(
      elevation: 2,
      color: const Color(0xFFE3F2FD), // Light Blue
      shadowColor: Colors.black.withOpacity(0.1),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                if (cardInfo.isDefault)
                  const Chip(
                      label: Text('Primary'), backgroundColor: Colors.white)
                else
                  const SizedBox(height: 32),
                _getLogo(cardInfo.cardType),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              cardInfo.maskedCardNumber,
              style: TextStyle(
                  color: theme.primaryText, fontSize: 20, letterSpacing: 2),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Card Holder',
                          style: TextStyle(
                              color: theme.secondaryText, fontSize: 12)),
                      Text(cardInfo.cardHolderName,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                              color: theme.primaryText, fontSize: 16)),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Expires',
                        style: TextStyle(
                            color: theme.secondaryText, fontSize: 12)),
                    Text(cardInfo.expiryDate,
                        style:
                            TextStyle(color: theme.primaryText, fontSize: 16)),
                  ],
                ),
              ],
            ),
            if (!cardInfo.isDefault) ...[
              const Divider(height: 24),
              Align(
                alignment: Alignment.centerRight,
                child: OutlinedButton(
                  onPressed: onSetAsPreferred,
                  child: const Text('Set as Primary'),
                ),
              )
            ]
          ],
        ),
      ),
    );
  }
}
