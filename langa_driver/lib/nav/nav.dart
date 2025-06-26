import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:page_transition/page_transition.dart';
import 'package:provider/provider.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:langas_driver/pages/change%20password/change_password_widget.dart';
import 'package:langas_driver/pages/chat/chat_screen.dart';
import 'package:langas_driver/pages/current%20deliveries/current_deliveries_widget.dart';
import 'package:langas_driver/pages/current%20deliveries/tracking_page.dart';
import 'package:langas_driver/pages/delivery%20history/delivery_history_widget.dart';
import 'package:langas_driver/pages/delivery%20route/delivery_route_widget.dart';
import 'package:langas_driver/pages/earnings/my_earning_widget.dart';
import 'package:langas_driver/pages/forgot%20password/forgot_password_page.dart';
import 'package:langas_driver/pages/home/home_screen_map.dart';
import 'package:langas_driver/pages/log%20in/login_screen.dart';
import 'package:langas_driver/pages/nearby%20deliveries/nearby_deliveries_widget.dart';
import 'package:langas_driver/pages/notifications/notification_page_widget.dart';
import 'package:langas_driver/pages/onboarding/onboarding_screen.dart';
import 'package:langas_driver/pages/otp%20screen/otp_verification_page.dart';
import 'package:langas_driver/pages/password_reset/reset_password_page.dart';
import 'package:langas_driver/pages/profile/profile_page_widget.dart';
import 'package:langas_driver/pages/registration/registration_page.dart';
import 'package:langas_driver/pages/splash%20screen/splash_screen_page.dart';
import 'package:langas_driver/pages/vehicles%20management/add_vehicle_screen.dart';
import 'package:langas_driver/pages/vehicles%20management/vehicle_management.dart';
import 'package:langas_driver/pages/wallet/deposit_page.dart';
import 'package:langas_driver/pages/wallet/payment_failure_page.dart';
import 'package:langas_driver/pages/wallet/payment_processing_page.dart';
import 'package:langas_driver/pages/wallet/payment_success_page.dart';
import 'package:langas_driver/pages/wallet/wallet_page_widget.dart';

export 'package:go_router/go_router.dart';

const kTransitionInfoKey = '__transition_info__';

class AppStateNotifier extends ChangeNotifier {
  AppStateNotifier._();

  static AppStateNotifier? _instance;
  static AppStateNotifier get instance => _instance ??= AppStateNotifier._();

  bool showSplashImage = true;
}

GoRouter createRouter(AppStateNotifier appStateNotifier) {
  return GoRouter(
    initialLocation: '/',
    debugLogDiagnostics: true,
    refreshListenable: appStateNotifier,
    errorBuilder: (context, state) => const LoginScreen(),
    routes: [
      GoRoute(
        name: 'SplashRoute',
        path: '/',
        pageBuilder: (context, state) => _pageBuilder(
          state,
          const SplashScreenWidget(),
        ),
      ),
      GoRoute(
        name: 'HomePage',
        path: '/homePage',
        pageBuilder: (context, state) => _pageBuilder(
          state,
          const DriverHomePage(),
        ),
      ),
      GoRoute(
        name: 'LoginPage',
        path: '/loginPage',
        pageBuilder: (context, state) => _pageBuilder(
          state,
          const LoginScreen(),
        ),
      ),
      GoRoute(
        name: 'OnboardingPage',
        path: '/onboardingPage',
        pageBuilder: (context, state) => _pageBuilder(
          state,
          const OnboardingScreen(),
        ),
      ),
      GoRoute(
        name: 'RegistrationPage',
        path: '/registrationPage',
        pageBuilder: (context, state) => _pageBuilder(
          state,
          const DriverRegistrationScreen(),
        ),
      ),
      GoRoute(
        name: 'DeliveryRoute',
        path: '/deliveryRoute',
        pageBuilder: (context, state) {
          final String? deliveryId = state.extra as String?;
          if (deliveryId != null) {
            return _pageBuilder(
              state,
              DeliveryRouteScreen(deliveryId: deliveryId),
            );
          } else {
            print(
                "Error: Delivery ID (String) not passed correctly to /deliveryRoute. Extra was: ${state.extra}");
            return _pageBuilder(
              state,
              const DriverHomePage(),
            );
          }
        },
      ),
      GoRoute(
        name: 'ChatScreen',
        path: '/chat',
        pageBuilder: (context, state) {
          final args = state.extra as Map<String, dynamic>? ?? {};
          final deliveryId = args['deliveryId'] as String?;
          final customerId = args['customerId'] as String?;
          final customerName = args['customerName'] as String?;

          if (deliveryId != null &&
              customerId != null &&
              customerName != null) {
            return _pageBuilder(
              state,
              ChatScreen(
                deliveryId: deliveryId,
                customerId: customerId,
                customerName: customerName,
              ),
            );
          } else {
            // Fallback to current deliveries if data is missing
            return _pageBuilder(state, const CurrentDeliveriesWidget());
          }
        },
      ),
      GoRoute(
        name: 'Wallet',
        path: '/wallet',
        pageBuilder: (context, state) => _pageBuilder(
          state,
          const DriverWalletWidget(),
        ),
      ),
      GoRoute(
        name: 'DepositPage',
        path: '/depositPage',
        pageBuilder: (context, state) => _pageBuilder(
          state,
          const DepositPageWidget(),
        ),
      ),
      GoRoute(
        name: 'PaymentProcessingPage',
        path: '/paymentProcessing',
        pageBuilder: (context, state) {
          final Map<String, dynamic>? args =
              state.extra as Map<String, dynamic>?;
          if (args != null && args.containsKey('transactionId')) {
            return _pageBuilder(
              state,
              PaymentProcessingPage(
                transactionId: args['transactionId'] as String,
                paymentLink: args['paymentLink'] as String?,
                initialMessage: args['initialMessage'] as String?,
              ),
            );
          } else {
            return _pageBuilder(
              state,
              const DepositPageWidget(),
            );
          }
        },
      ),
      GoRoute(
        name: 'PaymentSuccessPage',
        path: '/paymentSuccess',
        pageBuilder: (context, state) {
          final Map<String, dynamic>? args =
              state.extra as Map<String, dynamic>?;
          return _pageBuilder(
            state,
            PaymentSuccessPage(
              message: args?['message'] as String?,
              transactionId: args?['transactionId'] as String?,
            ),
          );
        },
      ),
      GoRoute(
        name: 'PaymentFailurePage',
        path: '/paymentFailure',
        pageBuilder: (context, state) {
          final Map<String, dynamic>? args =
              state.extra as Map<String, dynamic>?;
          return _pageBuilder(
            state,
            PaymentFailurePage(
              error: args?['error'] as String?,
              transactionId: args?['transactionId'] as String?,
            ),
          );
        },
      ),
      GoRoute(
        name: 'Current_Deliveries',
        path: '/currentDeliveries',
        pageBuilder: (context, state) => _pageBuilder(
          state,
          const CurrentDeliveriesWidget(),
        ),
      ),
      GoRoute(
        name: 'liveTracking',
        path: '/delivery/:deliveryId/live-tracking',
        builder: (BuildContext context, GoRouterState state) {
          final deliveryId = state.pathParameters['deliveryId']!;
          // Retrieve other parameters from the 'extra' object
          final params = state.extra as Map<String, dynamic>;
          final driverId = params['driverId'] as String;
          final destinationCoordinates =
              params['destinationCoordinates'] as LatLng;
          final destinationAddressForMaps =
              params['destinationAddressForMaps'] as String;

          return LiveDeliveryTrackingScreen(
            deliveryId: deliveryId,
            driverId: driverId,
            destinationCoordinates: destinationCoordinates,
            destinationAddressForMaps: destinationAddressForMaps,
          );
        },
      ),
      GoRoute(
        name: 'Delivery_History',
        path: '/deliveryHistory',
        pageBuilder: (context, state) => _pageBuilder(
          state,
          const DeliveryHistoryWidget(),
        ),
      ),
      GoRoute(
        name: 'Driver_Earnings',
        path: '/driverEarnings',
        pageBuilder: (context, state) => _pageBuilder(
          state,
          const DriverEarningsWidget(),
        ),
      ),
      GoRoute(
        name: 'OTPScreen',
        path: '/otpScreen',
        pageBuilder: (context, state) {
          final args = state.extra as Map<String, String>? ?? {};
          final email = args['email'];
          final phone = args['phone'];
          final loginId = args['loginId'];
          final identifier = loginId ?? email ?? phone ?? '';

          return _pageBuilder(
            state,
            OtpVerificationScreen(loginId: identifier),
          );
        },
      ),
      GoRoute(
        name: 'Forgot_password',
        path: '/forgotPassword',
        pageBuilder: (context, state) => _pageBuilder(
          state,
          const ForgotPasswordWidget(),
        ),
      ),
      GoRoute(
          name: 'ResetPassword',
          path: '/resetPassword',
          pageBuilder: (context, state) {
            final args = state.extra as Map<String, String>? ?? {};
            final loginId = args['loginId'] ?? '';
            return _pageBuilder(
              state,
              ResetPasswordScreen(loginId: loginId),
            );
          }),
      GoRoute(
        name: 'ProfileScreen',
        path: '/profile',
        pageBuilder: (context, state) => _pageBuilder(
          state,
          const DriverProfileScreen(),
        ),
      ),
      GoRoute(
        name: 'VehicleManagement',
        path: '/vehicles',
        pageBuilder: (context, state) => _pageBuilder(
          state,
          const VehicleManagementScreen(),
        ),
      ),
      GoRoute(
        name: 'AddVehicle',
        path: '/addVehicle',
        pageBuilder: (context, state) => _pageBuilder(
          state,
          const AddVehicleScreen(),
        ),
      ),
      GoRoute(
        name: 'Nearby_deliveries',
        path: '/nearbyDeliveries',
        pageBuilder: (context, state) => _pageBuilder(
          state,
          const NearbyDeliveriesWidget(),
        ),
      ),
      GoRoute(
        name: 'Change_Password',
        path: '/changePassword',
        pageBuilder: (context, state) => _pageBuilder(
          state,
          const ChangePasswordWidget(),
        ),
      ),
      GoRoute(
        name: 'NotificationPage',
        path: '/notificationPage',
        pageBuilder: (context, state) => _pageBuilder(
          state,
          const NotificationWidget(),
        ),
      ),
    ],
  );
}

Page<dynamic> _pageBuilder(GoRouterState state, Widget child) {
  TransitionInfo transitionInfo;
  if (state.extra is Map<String, dynamic>) {
    final Map<String, dynamic> extraMap = state.extra as Map<String, dynamic>;
    transitionInfo = extraMap.containsKey(kTransitionInfoKey) &&
            extraMap[kTransitionInfoKey] is TransitionInfo
        ? extraMap[kTransitionInfoKey] as TransitionInfo
        : TransitionInfo.appDefault();
  } else {
    transitionInfo = TransitionInfo.appDefault();
  }

  return transitionInfo.hasTransition
      ? CustomTransitionPage(
          key: state.pageKey,
          child: child,
          transitionDuration: transitionInfo.duration,
          transitionsBuilder: (context, animation, secondaryAnimation, child) =>
              PageTransition(
            type: transitionInfo.transitionType,
            duration: transitionInfo.duration,
            reverseDuration: transitionInfo.duration,
            alignment: transitionInfo.alignment,
            child: child,
          ).buildTransitions(
            context,
            animation,
            secondaryAnimation,
            child,
          ),
        )
      : MaterialPage(key: state.pageKey, child: child);
}

extension NavigationExtensions on BuildContext {
  void safePop() {
    if (canPop()) {
      pop();
    } else {
      go('/');
    }
  }
}

class TransitionInfo {
  const TransitionInfo({
    required this.hasTransition,
    this.transitionType = PageTransitionType.fade,
    this.duration = const Duration(milliseconds: 300),
    this.alignment,
  });

  final bool hasTransition;
  final PageTransitionType transitionType;
  final Duration duration;
  final Alignment? alignment;

  static TransitionInfo appDefault() =>
      const TransitionInfo(hasTransition: false);
}

class RootPageContext {
  const RootPageContext(this.isRootPage, [this.errorRoute]);
  final bool isRootPage;
  final String? errorRoute;

  static bool isInactiveRootPage(BuildContext context) {
    final rootPageContext = context.read<RootPageContext?>();
    final isRootPage = rootPageContext?.isRootPage ?? false;
    final location = GoRouterState.of(context).uri.toString();
    return isRootPage &&
        location != '/' &&
        location != rootPageContext?.errorRoute;
  }

  static Widget wrap(Widget child, {String? errorRoute}) => Provider.value(
        value: RootPageContext(true, errorRoute),
        child: child,
      );
}
