import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:langas_user/flutter_flow/flutter_flow_theme.dart';
import 'package:langas_user/pages/payments/add_payment_card_page.dart';
import 'package:fluttertoast/fluttertoast.dart';

class CardInfo {
  final int id;
  final String cardHolderName;
  final String cardNumber;
  final String expiryDate;
  final String cardType;
  bool isPreferred;

  CardInfo({
    required this.id,
    required this.cardHolderName,
    required this.cardNumber,
    required this.expiryDate,
    required this.cardType,
    this.isPreferred = false,
  });
}

class PaymentMethodPage extends StatefulWidget {
  const PaymentMethodPage({super.key});

  @override
  State<PaymentMethodPage> createState() => _PaymentMethodPageState();
}

class _PaymentMethodPageState extends State<PaymentMethodPage> {
  final List<CardInfo> _savedCards = [
    CardInfo(
        id: 1,
        cardHolderName: 'John Doe',
        cardNumber: '**** **** **** 1234',
        expiryDate: '12/26',
        cardType: 'VISA',
        isPreferred: true),
    CardInfo(
        id: 2,
        cardHolderName: 'John Doe',
        cardNumber: '**** **** **** 5678',
        expiryDate: '08/25',
        cardType: 'MASTERCARD'),
    CardInfo(
        id: 3,
        cardHolderName: 'John Doe',
        cardNumber: '**** **** **** 9876',
        expiryDate: '01/28',
        cardType: 'ZIMSWITCH'),
  ];

  void _setAsPreferred(int cardId) {
    setState(() {
      for (var card in _savedCards) {
        card.isPreferred = card.id == cardId;
      }
    });
    Fluttertoast.showToast(msg: "Preferred card updated.");
  }

  void _deleteCard(int cardId) {
    setState(() {
      _savedCards.removeWhere((card) => card.id == cardId);
    });
    Fluttertoast.showToast(
        msg: "Card removed successfully.", backgroundColor: Colors.green);
  }

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);
    final preferredCard = _savedCards.firstWhere((card) => card.isPreferred,
        orElse: () => _savedCards.first);
    final otherCards = _savedCards.where((card) => !card.isPreferred).toList();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Payment Methods'),
        backgroundColor: theme.primary,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Primary Card',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            CreditCardWidget(
              cardInfo: preferredCard,
              onSetAsPreferred: () => _setAsPreferred(preferredCard.id),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Other Cards',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    )),
                TextButton.icon(
                  icon: Icon(Icons.add,
                      color: FlutterFlowTheme.of(context).primary),
                  label: Text(
                    'Add New',
                    style:
                        TextStyle(color: FlutterFlowTheme.of(context).primary),
                  ),
                  onPressed: () {
                    Navigator.of(context).push(MaterialPageRoute(
                        builder: (context) => const AddPaymentCardPage()));
                  },
                )
              ],
            ),
            const SizedBox(height: 8),
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
                        Text('Delete', style: TextStyle(color: Colors.white)),
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
      ),
    );
  }
}

class CreditCardWidget extends StatelessWidget {
  final CardInfo cardInfo;
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
        return const SizedBox(height: 30);
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
                if (cardInfo.isPreferred)
                  const Chip(
                      label: Text('Primary'), backgroundColor: Colors.white)
                else
                  const SizedBox(height: 32),
                _getLogo(cardInfo.cardType),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              cardInfo.cardNumber,
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
            if (!cardInfo.isPreferred) ...[
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
