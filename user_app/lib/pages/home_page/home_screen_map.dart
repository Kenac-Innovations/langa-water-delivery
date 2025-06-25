import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:langas_user/bloc/auth/auth_bloc/auth_bloc_bloc.dart';
import 'package:langas_user/bloc/auth/auth_bloc/auth_bloc_state.dart';
import 'package:langas_user/bloc/water_oder/water_order_bloc_bloc.dart';
import 'package:langas_user/bloc/water_oder/water_order_bloc_event.dart';
import 'package:langas_user/bloc/water_oder/water_order_bloc_state.dart';
import 'package:langas_user/bloc/promotions/promotions_bloc_bloc.dart';
import 'package:langas_user/bloc/promotions/promotions_bloc_event.dart';
import 'package:langas_user/bloc/promotions/promotions_bloc_state.dart';
import 'package:langas_user/flutter_flow/flutter_flow_icon_button.dart';
import 'package:langas_user/flutter_flow/flutter_flow_theme.dart';
import 'package:langas_user/models/promotion_model.dart';
import 'package:langas_user/models/user_model.dart';
import 'package:langas_user/models/water_order_model.dart';
import 'package:langas_user/pages/drawer/drawer_widget.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:shimmer/shimmer.dart';

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
    final authState = context.read<AuthBloc>().state;
    if (authState is Authenticated) {
      context.read<WaterOrderBloc>().add(FetchClientRecentDeliveries(
          clientId: authState.user.userId, pageSize: 1));
    }
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
                  onPressed: () => context.pushNamed('Create_Water_Order'),
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
                  onPressed: () => context.pushNamed('Create_Water_Order'),
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
                value: DateFormat('MMMM d,<x_bin_342>')
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
          BlocBuilder<WaterOrderBloc, WaterOrderState>(
            builder: (context, state) {
              if (state is WaterOrderLoading) {
                return _buildQuickActionsLoading();
              }
              if (state is WaterOrderListLoadSuccess) {
                if (state.paginatedResponse.content.isEmpty) {
                  return _buildNoOrdersCard();
                }
                final lastOrder = state.paginatedResponse.content.first;
                return _buildRepeatOrderCard(lastOrder);
              }
              if (state is WaterOrderFailure) {
                return _buildErrorCard(state.failure.message);
              }
              return _buildNoOrdersCard();
            },
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActionsLoading() {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: Card(
        elevation: 2,
        shadowColor: Colors.black.withOpacity(0.1),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Container(
          height: 150,
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }

  Widget _buildNoOrdersCard() {
    return Card(
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
                  const Text('No recent orders',
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  const SizedBox(height: 4),
                  const Text('Place your first water delivery order today!',
                      style: TextStyle(color: Colors.black54)),
                  const SizedBox(height: 16),
                  SizedBox(
                    height: 36,
                    child: ElevatedButton(
                      onPressed: () => context.pushNamed('Create_Water_Order'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: FlutterFlowTheme.of(context).primary,
                        foregroundColor: Colors.white,
                        elevation: 0,
                      ),
                      child: const Text('Create New Order'),
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
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildRepeatOrderCard(WaterOrder lastOrder) {
    return Card(
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
                  const Text('Last Order',
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  const SizedBox(height: 4),
                  Text(
                    'Order #${lastOrder.orderId} - ${lastOrder.deliveries.length} deliveries',
                    style: const TextStyle(color: Colors.black54),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  Text('\$${lastOrder.totalAmount.toStringAsFixed(2)}',
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 16)),
                  const SizedBox(height: 16),
                  SizedBox(
                    height: 36,
                    child: ElevatedButton(
                      onPressed: () {
                        context.pushNamed('Create_Water_Order',
                            extra: lastOrder);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: FlutterFlowTheme.of(context).primary,
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
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildErrorCard(String message) {
    return Card(
      elevation: 2,
      shadowColor: Colors.black.withOpacity(0.1),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Center(
          child: Column(
            children: [
              const Icon(Icons.error_outline, color: Colors.red, size: 40),
              const SizedBox(height: 8),
              const Text('Could not load recent order'),
              Text(message, style: const TextStyle(color: Colors.grey)),
            ],
          ),
        ),
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
                  'Call Us', Icons.phone_in_talk_outlined, Colors.green),
              _buildSupportButton('Email Us', Icons.email, Colors.blue),
              _buildSupportButton(
                  'FAQ Search', Icons.quiz_outlined, Colors.blue),
              _buildSupportButton(
                  'Whatsapp', FontAwesomeIcons.whatsapp, Colors.green),
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
