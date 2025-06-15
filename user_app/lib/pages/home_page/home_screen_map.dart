import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:langas_user/bloc/auth/auth_bloc/auth_bloc_bloc.dart';
import 'package:langas_user/bloc/auth/auth_bloc/auth_bloc_state.dart';
import 'package:langas_user/bloc/promotions/promotions_bloc_bloc.dart';
import 'package:langas_user/bloc/promotions/promotions_bloc_event.dart';
import 'package:langas_user/bloc/promotions/promotions_bloc_state.dart';
import 'package:langas_user/flutter_flow/flutter_flow_icon_button.dart';
import 'package:langas_user/flutter_flow/flutter_flow_theme.dart';
import 'package:langas_user/models/promotion_model.dart';
import 'package:langas_user/models/user_model.dart';
import 'package:langas_user/pages/drawer/drawer_widget.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final scaffoldKey = GlobalKey<ScaffoldState>();
  bool _isFabExtended = true;

  @override
  void initState() {
    super.initState();
    context.read<PromotionsBloc>().add(FetchAllPromotions());
  }

  AppBar _buildAppBar(BuildContext context, User? user) {
    return AppBar(
      backgroundColor: FlutterFlowTheme.of(context).primary,
      elevation: 0,
      automaticallyImplyLeading: false,
      leading: FlutterFlowIconButton(
        borderColor: Colors.transparent,
        borderRadius: 30.0,
        borderWidth: 1.0,
        buttonSize: 50.0,
        icon: const Icon(Icons.menu, color: Colors.white, size: 28.0),
        onPressed: () => scaffoldKey.currentState?.openDrawer(),
      ),
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Welcome Back,',
            style: FlutterFlowTheme.of(context)
                .bodySmall
                .override(fontFamily: 'Poppins', color: Colors.white70),
          ),
          Text(
            user?.firstName ?? 'Guest',
            style: FlutterFlowTheme.of(context).headlineSmall.override(
                fontFamily: 'Poppins', fontSize: 20, color: Colors.white),
          ),
        ],
      ),
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: 8.0),
          child: IconButton(
            icon: const Icon(Icons.notifications_outlined,
                color: Colors.white, size: 28),
            onPressed: () => context.pushNamed('Notification'),
          ),
        ),
      ],
      centerTitle: false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, authState) {
        final User? currentUser =
            (authState is Authenticated) ? authState.user : null;

        return Scaffold(
          key: scaffoldKey,
          backgroundColor: FlutterFlowTheme.of(context).primaryBackground,
          drawer: const AppDrawer(),
          appBar: _buildAppBar(context, currentUser),
          body: NotificationListener<UserScrollNotification>(
            onNotification: (notification) {
              final Direction = notification.direction;
              if (Direction == ScrollDirection.reverse) {
                if (_isFabExtended) setState(() => _isFabExtended = false);
              } else if (Direction == ScrollDirection.forward) {
                if (!_isFabExtended) setState(() => _isFabExtended = true);
              }
              return true;
            },
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(vertical: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildDeliveryAddressCard(),
                  const SizedBox(height: 24),
                  _buildQuickActionsCard(),
                  const SizedBox(height: 24),
                  _buildPromotionsSection(),
                  const SizedBox(height: 24),
                  _buildSupportSection(),
                  const SizedBox(height: 80),
                ],
              ),
            ),
          ),
          floatingActionButtonLocation:
              FloatingActionButtonLocation.centerFloat,
          floatingActionButton: _isFabExtended
              ? FloatingActionButton.extended(
                  onPressed: () => context.pushNamed('Create_Delivery'),
                  backgroundColor: FlutterFlowTheme.of(context).primary,
                  foregroundColor: Colors.white,
                  elevation: 8,
                  icon: const Icon(Icons.add_shopping_cart, size: 24),
                  label: const Text(
                    'Create a New Order',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                )
              : FloatingActionButton(
                  onPressed: () => context.pushNamed('Create_Delivery'),
                  backgroundColor: FlutterFlowTheme.of(context).primary,
                  foregroundColor: Colors.white,
                  elevation: 8,
                  child: const Icon(Icons.add_shopping_cart, size: 28),
                ),
        );
      },
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Text(
        title,
        style: FlutterFlowTheme.of(context)
            .titleLarge
            .override(fontFamily: 'Poppins', fontSize: 22),
      ),
    );
  }

  Widget _buildPromotionsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader('Promotions'),
        const SizedBox(height: 12),
        SizedBox(
          height: 140,
          child: BlocBuilder<PromotionsBloc, PromotionsState>(
            builder: (context, state) {
              if (state is PromotionsLoading) {
                return const Center(child: CircularProgressIndicator());
              }
              if (state is PromotionsLoadSuccess) {
                if (state.promotions.isEmpty) {
                  return const Center(
                      child: Text("No promotions available right now."));
                }
                return ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: state.promotions.length,
                  itemBuilder: (context, index) {
                    final promotion = state.promotions[index];
                    final colors = [
                      const Color(0xFF4B39EF),
                      const Color(0xFFE63946),
                      const Color(0xFF1D3557)
                    ];
                    final icons = [
                      Icons.local_offer,
                      Icons.campaign,
                      Icons.card_giftcard
                    ];
                    final color = colors[index % colors.length];
                    final icon = icons[index % icons.length];

                    return Padding(
                      padding: const EdgeInsets.only(right: 16.0),
                      child: _buildPromoCard(
                        promotion: promotion,
                        color: color,
                        iconData: icon,
                      ),
                    );
                  },
                );
              }
              if (state is PromotionsFailure) {
                return Center(child: Text("Error: ${state.failure.message}"));
              }
              return const Center(child: Text("Check out our latest offers!"));
            },
          ),
        ),
      ],
    );
  }

  Widget _buildPromoCard(
      {required Promotion promotion,
      required Color color,
      required IconData iconData}) {
    return InkWell(
      onTap: () => _showPromotionDetailsSheet(context, promotion),
      borderRadius: BorderRadius.circular(16),
      child: Container(
        width: 250,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Container(
          decoration: BoxDecoration(
            // Add a dark overlay for better text visibility
            color: Colors.black.withOpacity(0.25),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(iconData, color: Colors.white, size: 28),
                ),
                const Spacer(),
                Text(
                  promotion.title,
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      shadows: [Shadow(blurRadius: 2, color: Colors.black38)]),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  promotion.description,
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      shadows: [Shadow(blurRadius: 1, color: Colors.black38)]),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showPromotionDetailsSheet(BuildContext context, Promotion promotion) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.5,
        minChildSize: 0.3,
        maxChildSize: 0.8,
        builder: (_, scrollController) => Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: ListView(
            controller: scrollController,
            padding: const EdgeInsets.all(20),
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(2)),
                ),
              ),
              Text(
                promotion.title,
                style: FlutterFlowTheme.of(context).headlineMedium,
              ),
              const SizedBox(height: 16),
              Text(
                promotion.description,
                style: FlutterFlowTheme.of(context).bodyLarge,
              ),
              const SizedBox(height: 24),
              const Divider(),
              _buildDetailRow(
                context,
                icon: Icons.qr_code,
                title: 'Promo Code',
                value: promotion.promoCode,
              ),
              _buildDetailRow(
                context,
                icon: Icons.calendar_today,
                title: 'Valid Until',
                value: DateFormat('MMMM d, yyyy')
                    .format(DateTime.parse(promotion.endDate)),
              ),
              _buildDetailRow(
                context,
                icon: Icons.percent,
                title: 'Discount',
                value: '${promotion.discountPercentage}% OFF',
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(BuildContext context,
      {required IconData icon, required String title, required String value}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Icon(icon, color: Colors.grey.shade600, size: 20),
          const SizedBox(width: 12),
          Text(title, style: FlutterFlowTheme.of(context).bodyMedium),
          const Spacer(),
          Text(value,
              style: FlutterFlowTheme.of(context).bodyMedium.override(
                  fontFamily: 'Poppins', fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildDeliveryAddressCard() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Card(
        elevation: 2,
        shadowColor: Colors.black.withOpacity(0.1),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Current Location',
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      '789 Hydration Ave, San Francisco',
                      style: TextStyle(fontSize: 14, color: Colors.black54),
                    ),
                    const SizedBox(height: 8),
                    Card(
                      color:
                          FlutterFlowTheme.of(context).success.withOpacity(0.1),
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8)),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8.0, vertical: 4.0),
                        child: Text(
                          'Service Available',
                          style: TextStyle(
                              fontSize: 12,
                              color: FlutterFlowTheme.of(context).success,
                              fontWeight: FontWeight.w600),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: Icon(Icons.location_pin,
                    size: 32, color: FlutterFlowTheme.of(context).primary),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQuickActionsCard() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader('Quick Actions'),
          const SizedBox(height: 12),
          Card(
            elevation: 2,
            shadowColor: Colors.black.withOpacity(0.1),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('5L Mineral Water',
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 16)),
                        const SizedBox(height: 4),
                        const Text('789 Hydration Ave',
                            style: TextStyle(color: Colors.black54)),
                        const SizedBox(height: 8),
                        const Text('\$12',
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 16)),
                        const SizedBox(height: 16),
                        SizedBox(
                          height: 36,
                          child: ElevatedButton(
                            onPressed: () {},
                            style: ElevatedButton.styleFrom(
                              backgroundColor:
                                  FlutterFlowTheme.of(context).primary,
                              foregroundColor: Colors.white,
                              elevation: 0,
                            ),
                            child: const Text('Repeat Order'),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.asset(
                      'assets/images/water.jpg',
                      width: 100,
                      height: 100,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          width: 100,
                          height: 100,
                          color: Colors.grey.shade200,
                          child: Icon(Icons.image_not_supported_outlined,
                              color: Colors.grey.shade400),
                        );
                      },
                    ),
                  )
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSupportSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader('Support'),
          const SizedBox(height: 12),
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 2.5,
            children: [
              _buildSupportButton(
                  'Live Chat', Icons.chat_bubble_outline, Colors.green),
              _buildSupportButton('Callback Request',
                  Icons.phone_in_talk_outlined, Colors.orange),
              _buildSupportButton(
                  'FAQ Search', Icons.quiz_outlined, Colors.blue),
              _buildSupportButton('Emergency Contact',
                  Icons.contact_phone_outlined, Colors.red),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildSupportButton(String label, IconData icon, Color color) {
    return OutlinedButton.icon(
      icon: Icon(icon, size: 20, color: color),
      label: Text(label,
          textAlign: TextAlign.center,
          style: TextStyle(color: FlutterFlowTheme.of(context).primaryText)),
      onPressed: () {},
      style: OutlinedButton.styleFrom(
        foregroundColor: color,
        backgroundColor: color.withOpacity(0.05),
        side: BorderSide(color: color.withOpacity(0.3)),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 0,
      ),
    );
  }
}
