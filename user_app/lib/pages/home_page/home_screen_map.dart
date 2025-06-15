import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:langas_user/bloc/auth/auth_bloc/auth_bloc_bloc.dart';
import 'package:langas_user/bloc/auth/auth_bloc/auth_bloc_state.dart';
import 'package:langas_user/flutter_flow/flutter_flow_icon_button.dart';
import 'package:langas_user/flutter_flow/flutter_flow_theme.dart';
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

  // No longer need _currentUser or initState for this

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
            user?.firstName ?? 'Guest', // Use the user from the builder
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
      builder: (context, state) {
        // Determine the current user from the state
        final User? currentUser = (state is Authenticated) ? state.user : null;

        return Scaffold(
          key: scaffoldKey,
          backgroundColor: FlutterFlowTheme.of(context).primaryBackground,
          drawer: const AppDrawer(),
          appBar:
              _buildAppBar(context, currentUser), // Pass the user to the AppBar
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
                  icon: const Icon(Icons.water_drop, size: 24),
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
                  child: const Icon(Icons.water_drop, size: 28),
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

  Widget _buildPromotionsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader('Promotions'),
        const SizedBox(height: 12),
        SizedBox(
          height: 140,
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            children: [
              _buildPromoCard(
                'Summer Special',
                '20% off 20L+ orders',
                const Color(0xFF4FD8C5),
                'https://images.unsplash.com/photo-1554774853-719586f82d77?w=500&q=80',
              ),
              const SizedBox(width: 16),
              _buildPromoCard(
                'Referral Bonus',
                '\$10 credit for referring a friend',
                const Color(0xFF98D8B7),
                'https://images.unsplash.com/photo-1594705598634-f8753e5834b3?w=500&q=80',
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPromoCard(
      String title, String subtitle, Color color, String imageUrl) {
    return Container(
      width: 250,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(16),
        image: DecorationImage(
          image: NetworkImage(imageUrl),
          fit: BoxFit.cover,
          colorFilter:
              ColorFilter.mode(color.withOpacity(0.8), BlendMode.darken),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Text(title,
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold)),
            Text(subtitle,
                style: const TextStyle(color: Colors.white, fontSize: 14)),
          ],
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
