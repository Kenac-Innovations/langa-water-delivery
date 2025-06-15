import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_maps_flutter_platform_interface/google_maps_flutter_platform_interface.dart'
    show LatLng;
import 'package:langas_user/pages/address/address_page.dart';

import 'package:langas_user/pages/change_password/change_password_widget.dart';
import 'package:langas_user/pages/create_delivery/create_delivery_order.dart';
import 'package:langas_user/pages/current_deliveries/current_deliveries_widget.dart';
import 'package:langas_user/pages/delivery_history/delivery_history_widget.dart';
import 'package:langas_user/pages/edit_profile/edit_profile_widget.dart';
import 'package:langas_user/pages/forgot_password/forgot_password_widget.dart';
import 'package:langas_user/pages/my_wallet/my_wallet_widget.dart';
import 'package:langas_user/pages/notification/notification_widget.dart';
import 'package:langas_user/pages/payments/payment_method_page.dart';
import 'package:langas_user/pages/splash_screen/splash_screen_widget.dart';
import 'package:langas_user/pages/user_login/user_login_widget.dart';
import 'package:langas_user/pages/user_signup/user_signup_widget.dart';
import 'package:langas_user/pages/home_page/home_screen_map.dart';

export 'package:go_router/go_router.dart';

class AppStateNotifier extends ChangeNotifier {
  AppStateNotifier._();

  static AppStateNotifier? _instance;
  static AppStateNotifier get instance => _instance ??= AppStateNotifier._();

  bool showSplashImage = true;

  void stopShowingSplashImage() {
    showSplashImage = false;
    notifyListeners();
  }
}

typedef CallBackFunction = void Function(
  String p0,
  LatLng p1,
  double p2,
  LatLng p3,
  double p4,
  LatLng p5,
  double p6,
);

// Updated function signature - removed AuthChangeNotifier
GoRouter createRouter(AppStateNotifier appStateNotifier) => GoRouter(
      initialLocation: '/',
      debugLogDiagnostics: true,
      // Use original AppStateNotifier if needed for other refreshes, otherwise remove
      refreshListenable: appStateNotifier,
      errorBuilder: (context, state) => const ErrorScreen(),

      // Removed redirect logic
      // redirect: (BuildContext context, GoRouterState state) { ... },

      routes: [
        GoRoute(
          name: '_initialize',
          path: '/',
          builder: (context, state) => const SplashScreenWidget(),
        ),
        GoRoute(
          name: 'LoginScreen',
          path: '/userLogin',
          builder: (context, state) => const LoginScreen(),
        ),
        GoRoute(
          name: 'SignUpScreen',
          path: '/userSignup',
          builder: (context, state) => const SignUpScreen(),
        ),
        GoRoute(
          name: 'ForgotPasswordRequestScreen',
          path: '/forgotPassword',
          builder: (context, state) => const ForgotPasswordRequestScreen(),
        ),
        GoRoute(
            name: 'HomePage',
            path: '/homePage',
            builder: (context, state) {
              return const HomePage();
            }),
        GoRoute(
          name: 'Change_Password',
          path: '/changePassword',
          builder: (context, state) => const ChangePasswordWidget(),
        ),
        GoRoute(
          name: 'Edit_Profile',
          path: '/editProfile',
          builder: (context, state) => const EditProfileWidget(),
        ),
        GoRoute(
          name: 'Current_Deliveries',
          path: '/currentDeliveries',
          builder: (context, state) => const CurrentDeliveriesWidget(),
        ),
        GoRoute(
          name: 'Create_Delivery',
          path: '/createDelivery',
          builder: (context, state) => const MultiStepDelivery(),
        ),
        GoRoute(
          name: 'Notification',
          path: '/notification',
          builder: (context, state) => NotificationWidget(),
        ),
        GoRoute(
          name: 'Address',
          path: '/address',
          builder: (context, state) => const AddressPage(),
        ),
        GoRoute(
          name: 'Payment_Method',
          path: '/paymentMethod',
          builder: (context, state) => const PaymentMethodPage(),
        ),
        GoRoute(
          name: 'Delivery_History',
          path: '/deliveryHistory',
          builder: (context, state) => const DeliveryHistoryWidget(),
        ),
        GoRoute(
          name: 'My_Wallet',
          path: '/myWallet',
          builder: (context, state) => const MyWalletWidget(),
        ),
      ],
    );

class ErrorScreen extends StatelessWidget {
  final String? message;
  const ErrorScreen({Key? key, this.message}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Error')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(message ??
              'An unexpected error occurred navigating to this page.'),
        ),
      ),
    );
  }
}
