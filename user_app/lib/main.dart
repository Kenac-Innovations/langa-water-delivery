import 'dart:convert';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_web_plugins/url_strategy.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:langas_user/bloc/auth/auth_bloc/auth_bloc_bloc.dart';
import 'package:langas_user/bloc/auth/auth_bloc/auth_bloc_event.dart';
import 'package:langas_user/bloc/auth/auth_bloc/auth_bloc_state.dart';
import 'package:langas_user/bloc/auth/login_bloc/login_bloc_bloc.dart';
import 'package:langas_user/bloc/auth/password_reset_bloc/password_reset_bloc_bloc.dart';
import 'package:langas_user/bloc/auth/password_reset_request/password_reset_request_bloc_bloc.dart';
import 'package:langas_user/bloc/auth/register_bloc/register_bloc_bloc.dart';
import 'package:langas_user/bloc/auth/verify_account_bloc/verify_account_bloc_bloc.dart';
import 'package:langas_user/bloc/deliveries/cancel_delivery_bloc/cancel_delivery_bloc_bloc.dart';
import 'package:langas_user/bloc/deliveries/create_delivery_bloc/create_delivery_bloc_bloc.dart';
import 'package:langas_user/bloc/deliveries/create_payment_bloc/create_payment_bloc_bloc.dart';
import 'package:langas_user/bloc/deliveries/delete_delivery_bloc/delete_delivery_bloc_bloc.dart';
import 'package:langas_user/bloc/deliveries/deliveries_bloc/deliveries_bloc_bloc.dart';
import 'package:langas_user/bloc/deliveries/delivery_price_bloc/delivery_price_bloc_bloc.dart';
import 'package:langas_user/bloc/deliveries/select_driver_bloc/select_driver_bloc_bloc.dart';
import 'package:langas_user/bloc/deliveries/single_delivery_bloc/single_delivery_bloc_bloc.dart';
import 'package:langas_user/bloc/drivers/active_drivers/available_drivers_bloc_bloc.dart';
import 'package:langas_user/bloc/notification/notification_bloc_bloc.dart';
import 'package:langas_user/repository/auth_repository.dart';
import 'package:langas_user/repository/delivery_repository.dart';
import 'package:langas_user/repository/driver_repository.dart';
import 'package:langas_user/repository/notification_repository.dart';
import 'package:langas_user/services/fcm_service.dart';
import 'package:langas_user/services/firebase_driver_service.dart';
import 'package:langas_user/services/geolocation.dart';
import 'package:langas_user/flutter_flow/flutter_flow_theme.dart';
import 'package:langas_user/flutter_flow/flutter_flow_util.dart';
import 'package:langas_user/flutter_flow/nav/nav.dart';
import 'package:langas_user/services/secure_storage.dart';
import 'package:langas_user/services/dio_client.dart';
import 'package:langas_user/util/api_constants.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();
GoRouter? _navigatorRouter;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  usePathUrlStrategy();

  await FlutterFlowTheme.initialize();
  await Firebase.initializeApp();

  FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

  await SystemChrome.setPreferredOrientations(
    [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown],
  );

  final secureStorageService = SecureStorageService();
  final dioClient = DioClient(
      baseUrl: ApiConstants.baseUrl, storageService: secureStorageService);
  final authRepository = AuthRepository(
      dioClient: dioClient, storageService: secureStorageService);
  final deliveryRepository = DeliveryRepository(dioClient: dioClient);
  final driverRepository = DriverRepository(dioClient: dioClient);
  final notificationRepository = NotificationRepository(dioClient: dioClient);
  final geolocationService = GeolocationService();
  final firebaseDriverService = FirebaseDriverService();

  final fcmService = FCMService(
    firebaseMessaging: FirebaseMessaging.instance,
    authRepository: authRepository,
    secureStorageService: secureStorageService,
    flutterLocalNotificationsPlugin: flutterLocalNotificationsPlugin,
  );
  await fcmService.initialize();

  runApp(
    MultiRepositoryProvider(
      providers: [
        RepositoryProvider.value(value: secureStorageService),
        RepositoryProvider.value(value: dioClient),
        RepositoryProvider.value(value: authRepository),
        RepositoryProvider.value(value: deliveryRepository),
        RepositoryProvider.value(value: driverRepository),
        RepositoryProvider.value(value: notificationRepository),
        RepositoryProvider.value(value: geolocationService),
        RepositoryProvider.value(value: fcmService),
        RepositoryProvider.value(value: firebaseDriverService),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider<AuthBloc>(
            create: (context) => AuthBloc(
              storageService: context.read<SecureStorageService>(),
              authRepository: context.read<AuthRepository>(),
              fcmService: context.read<FCMService>(),
            )..add(AuthCheckRequested()),
          ),
          BlocProvider<LoginBloc>(
            create: (context) => LoginBloc(
              authRepository: context.read<AuthRepository>(),
            ),
          ),
          BlocProvider<RegisterBloc>(
            create: (context) => RegisterBloc(
              authRepository: context.read<AuthRepository>(),
            ),
          ),
          BlocProvider<VerifyAccountBloc>(
            create: (context) => VerifyAccountBloc(
              authRepository: context.read<AuthRepository>(),
            ),
          ),
          BlocProvider<PasswordResetRequestBloc>(
            create: (context) => PasswordResetRequestBloc(
              authRepository: context.read<AuthRepository>(),
            ),
          ),
          BlocProvider<PasswordResetBloc>(
            create: (context) => PasswordResetBloc(
              authRepository: context.read<AuthRepository>(),
            ),
          ),
          BlocProvider<CreateDeliveryBloc>(
            create: (context) => CreateDeliveryBloc(
              deliveryRepository: context.read<DeliveryRepository>(),
            ),
          ),
          BlocProvider<DeliveriesBloc>(
            create: (context) => DeliveriesBloc(
              deliveryRepository: context.read<DeliveryRepository>(),
            ),
          ),
          BlocProvider<SingleDeliveryBloc>(
            create: (context) => SingleDeliveryBloc(
              deliveryRepository: context.read<DeliveryRepository>(),
            ),
          ),
          BlocProvider<CancelDeliveryBloc>(
            create: (context) => CancelDeliveryBloc(
              deliveryRepository: context.read<DeliveryRepository>(),
            ),
          ),
          BlocProvider<DeliveryPriceBloc>(
            create: (context) => DeliveryPriceBloc(
              deliveryRepository: context.read<DeliveryRepository>(),
            ),
          ),
          BlocProvider<DeleteDeliveryBloc>(
            create: (context) => DeleteDeliveryBloc(
              deliveryRepository: context.read<DeliveryRepository>(),
            ),
          ),
          BlocProvider<SelectDriverBloc>(
            create: (context) => SelectDriverBloc(
              deliveryRepository: context.read<DeliveryRepository>(),
            ),
          ),
          BlocProvider<CreatePaymentBloc>(
            create: (context) => CreatePaymentBloc(
              deliveryRepository: context.read<DeliveryRepository>(),
            ),
          ),
          BlocProvider<AvailableDriversBloc>(
            create: (context) => AvailableDriversBloc(
              firebaseDriverService: context.read<FirebaseDriverService>(),
            ),
          ),
          BlocProvider<NotificationBloc>(
            create: (context) => NotificationBloc(
              notificationRepository: context.read<NotificationRepository>(),
            ),
          ),
        ],
        child: const MyApp(),
      ),
    ),
  );
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();

  static _MyAppState of(BuildContext context) =>
      context.findAncestorStateOfType<_MyAppState>()!;
}

class _MyAppState extends State<MyApp> {
  Locale? _locale;
  late AppStateNotifier _appStateNotifier;
  late GoRouter _router;
  late FCMService _fcmService;
  AuthState? _previousAuthState;

  @override
  void initState() {
    super.initState();
    _appStateNotifier = AppStateNotifier.instance;
    _router = createRouter(_appStateNotifier);
    _navigatorRouter = _router;

    _fcmService = FCMService(
      firebaseMessaging: FirebaseMessaging.instance,
      authRepository: context.read<AuthRepository>(),
      secureStorageService: context.read<SecureStorageService>(),
      flutterLocalNotificationsPlugin: flutterLocalNotificationsPlugin,
      router: _router,
    );

    final authBloc = BlocProvider.of<AuthBloc>(context);
    _previousAuthState = authBloc.state;

    authBloc.stream.listen((authState) {
      if (authState is Authenticated) {
        final userId = authState.user.userId.toString();
        _fcmService.registerTokenForUser(userId, forceSend: true);
      } else if (authState is Unauthenticated &&
          _previousAuthState is Authenticated) {
        _fcmService.handleLogout();
      }
      _previousAuthState = authState;
    });

    final initialAuthState = authBloc.state;
    if (initialAuthState is Authenticated) {
      final userId = initialAuthState.user.userId.toString();
      _fcmService.registerTokenForUser(userId, forceSend: true);
    }
  }

  @override
  void dispose() {
    _navigatorRouter = null;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        final String currentLocation =
            _router.routerDelegate.currentConfiguration.uri.toString();
        final publicRoutes = {
          '/userLogin',
          '/userSignup',
          '/forgotPassword',
          '/otpVerification',
          '/resetPassword',
        };

        if (state is Authenticated) {
          debugPrint(
              "[MyApp Listener] Authenticated state detected. Current route: $currentLocation");
          if (publicRoutes.contains(currentLocation) &&
              currentLocation != '/') {
            debugPrint(
                "[MyApp Listener] Navigating to HomePage from public authenticated route...");
            _router.goNamed('HomePage');
            debugPrint(
                "[MyApp Listener] AFTER navigating to HomePage from public authenticated route.");
          } else if (currentLocation == '/') {
            debugPrint(
                "[MyApp Listener] Navigating to HomePage from splash...");
            _router.goNamed('HomePage');
            debugPrint(
                "[MyApp Listener] AFTER navigating to HomePage from splash.");
          }
        } else if (state is Unauthenticated) {
          debugPrint(
              "[MyApp Listener] Unauthenticated state detected. Current route: $currentLocation");
          final bool isOnAuthRoute =
              publicRoutes.any((route) => currentLocation.startsWith(route));
          if (!isOnAuthRoute) {
            debugPrint(
                "[MyApp Listener] Not on auth/public route. Attempting to navigate to LoginScreen...");
            _router.goNamed('LoginScreen');
            debugPrint(
                "[MyApp Listener] AFTER _router.goNamed('LoginScreen') call.");
          } else {
            debugPrint(
                "[MyApp Listener] Already on an auth/public route ($currentLocation). No navigation to LoginScreen needed by this listener.");
          }
        }
      },
      child: MaterialApp.router(
        title: 'TakeU',
        debugShowCheckedModeBanner: false,
        locale: _locale,
        theme: ThemeData(
          brightness: Brightness.light,
          useMaterial3: false,
        ),
        themeMode: ThemeMode.light,
        routerConfig: _router,
      ),
    );
  }
}
