import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:langas_driver/bloc/auth/auth_bloc/auth_bloc_bloc.dart';
import 'package:langas_driver/bloc/auth/auth_bloc/auth_bloc_event.dart';
import 'package:langas_driver/bloc/auth/auth_bloc/auth_bloc_state.dart';
import 'package:langas_driver/bloc/auth/driver_registration_bloc/driver_registration_bloc_bloc.dart';
import 'package:langas_driver/bloc/auth/login_bloc/login_bloc_bloc.dart';
import 'package:langas_driver/bloc/auth/otp_verification/otp_verification_bloc_bloc.dart';
import 'package:langas_driver/bloc/auth/password_reset_bloc/password_reset_bloc_bloc.dart';
import 'package:langas_driver/bloc/chat_bloc/chat_bloc_bloc.dart';
import 'package:langas_driver/bloc/delivery/confirm_delivery_bloc/confirm_delivery_bloc_bloc.dart';
import 'package:langas_driver/bloc/delivery/delivery_details/delivery_details_bloc_bloc.dart';
import 'package:langas_driver/bloc/deposit/deposit_bloc_bloc.dart';
import 'package:langas_driver/bloc/driver_profile/driver_profile_bloc_bloc.dart';
import 'package:langas_driver/bloc/delivery/current_deliveries_bloc/current_deliveries_bloc_bloc.dart';
import 'package:langas_driver/bloc/delivery/delivery_history_bloc/delivery_history_bloc_bloc.dart';
import 'package:langas_driver/bloc/delivery/nearby_deliveries_bloc/nearby_deliveries_bloc_bloc.dart';
import 'package:langas_driver/bloc/driver_profile/driver_profile_bloc_event.dart';
import 'package:langas_driver/bloc/notification/notification_bloc_bloc.dart';
import 'package:langas_driver/bloc/vehicles/vehicle_management/vehicle_management_bloc_bloc.dart';
import 'package:langas_driver/bloc/wallet/wallet_float/wallet_float_bloc_bloc.dart';
import 'package:langas_driver/bloc/wallet/wallet_transactions/wallet_transactions_bloc_bloc.dart';
import 'package:langas_driver/nav/nav.dart';
import 'package:langas_driver/repository/auth_repository.dart';
import 'package:langas_driver/repository/chat_repository.dart';
import 'package:langas_driver/repository/delivery_repository.dart';
import 'package:langas_driver/repository/notification_repository.dart';
import 'package:langas_driver/repository/vehicle_repository.dart';
import 'package:langas_driver/repository/wallet_repository.dart';
import 'package:langas_driver/services/dio_client.dart';
import 'package:langas_driver/services/geolocation.dart';
import 'package:langas_driver/services/location_tracking.dart';
import 'package:langas_driver/services/permision_helper.dart';
import 'package:langas_driver/services/secure_storage.dart';
import 'package:langas_driver/utils/api_constants.dart';
import 'flutter_flow/flutter_flow_theme.dart';
import 'package:langas_driver/services/firebase_delivery_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await initializeLocationService();
  await SystemChrome.setPreferredOrientations(
    [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown],
  );

  runApp(
    MultiRepositoryProvider(
      providers: [
        RepositoryProvider<SecureStorageService>(
          create: (context) => SecureStorageService(),
        ),
        RepositoryProvider<DioClient>(
          create: (context) => DioClient(
              baseUrl: ApiConstants.baseUrl,
              storageService: context.read<SecureStorageService>()),
        ),
        RepositoryProvider<GeolocationService>(
          create: (context) => GeolocationService(),
        ),
        RepositoryProvider<AuthRepository>(
          create: (context) => AuthRepository(context.read<DioClient>()),
        ),
        RepositoryProvider<VehicleRepository>(
          create: (context) => VehicleRepository(context.read<DioClient>()),
        ),
        RepositoryProvider<DeliveryRepository>(
          create: (context) => DeliveryRepository(context.read<DioClient>()),
        ),
        RepositoryProvider<NotificationRepository>(
          create: (context) =>
              NotificationRepository(context.read<DioClient>()),
        ),
        RepositoryProvider<LocationTrackingManager>(
          create: (context) => LocationTrackingManager(),
        ),
        RepositoryProvider<WalletRepository>(
          create: (context) => WalletRepository(context.read<DioClient>()),
        ),
        RepositoryProvider<FirebaseDatabase>(
          create: (context) => FirebaseDatabase.instance,
        ),
        RepositoryProvider<FirebaseFirestore>(
          create: (context) => FirebaseFirestore.instance,
        ),
        RepositoryProvider<FirebaseDeliveryService>(
          create: (context) =>
              FirebaseDeliveryService(context.read<FirebaseDatabase>()),
        ),
        RepositoryProvider<ChatRepository>(
          create: (context) => ChatRepository(
            firestore: context.read<FirebaseFirestore>(),
          ),
        ),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider<AuthBloc>(
            create: (context) => AuthBloc(
              secureStorageService: context.read<SecureStorageService>(),
            )..add(AuthDriverAppStarted()),
          ),
          BlocProvider<DriverRegistrationBloc>(
            create: (context) => DriverRegistrationBloc(
              authRepository: context.read<AuthRepository>(),
            ),
          ),
          BlocProvider<VerifyAccountBloc>(
            create: (context) => VerifyAccountBloc(
              authRepository: context.read<AuthRepository>(),
            ),
          ),
          BlocProvider<DriverLoginBloc>(
            create: (context) => DriverLoginBloc(
              authRepository: context.read<AuthRepository>(),
              authBloc: context.read<AuthBloc>(),
            ),
          ),
          BlocProvider<PasswordResetBloc>(
            create: (context) => PasswordResetBloc(
              authRepository: context.read<AuthRepository>(),
            ),
          ),
          BlocProvider<DriverProfileBloc>(
            create: (context) => DriverProfileBloc(
              authRepository: context.read<AuthRepository>(),
              authBloc: context.read<AuthBloc>(),
            ),
          ),
          BlocProvider<VehicleManagementBloc>(
            create: (context) => VehicleManagementBloc(
              vehicleRepository: context.read<VehicleRepository>(),
            ),
          ),
          BlocProvider<NearbyDeliveriesBloc>(
            create: (context) => NearbyDeliveriesBloc(
              context.read<DeliveryRepository>(),
              firebaseDeliveryService: context.read<FirebaseDeliveryService>(),
              geolocationService: context.read<GeolocationService>(),
            ),
          ),
          BlocProvider<CurrentDeliveriesBloc>(
            create: (context) => CurrentDeliveriesBloc(
              deliveryRepository: context.read<DeliveryRepository>(),
              locationTrackingManager: context.read<LocationTrackingManager>(),
            ),
          ),
          BlocProvider<DeliveryHistoryBloc>(
            create: (context) => DeliveryHistoryBloc(
              deliveryRepository: context.read<DeliveryRepository>(),
            ),
          ),
          BlocProvider<DeliveryDetailsBloc>(
            create: (context) => DeliveryDetailsBloc(
              deliveryRepository: context.read<DeliveryRepository>(),
            ),
          ),
          BlocProvider<ConfirmDeliveryBloc>(
            create: (context) => ConfirmDeliveryBloc(
              deliveryRepository: context.read<DeliveryRepository>(),
            ),
          ),
          BlocProvider<DepositBloc>(
            create: (context) => DepositBloc(
              walletRepository: context.read<WalletRepository>(),
            ),
          ),
          BlocProvider<WalletFloatBloc>(
            create: (context) => WalletFloatBloc(
              walletRepository: context.read<WalletRepository>(),
            ),
          ),
          BlocProvider<WalletTransactionsBloc>(
            create: (context) => WalletTransactionsBloc(
              walletRepository: context.read<WalletRepository>(),
            ),
          ),
          BlocProvider<NotificationBloc>(
            create: (context) => NotificationBloc(
              notificationRepository: context.read<NotificationRepository>(),
            ),
          ),
          BlocProvider<ChatBloc>(
            create: (context) => ChatBloc(
              chatRepository: context.read<ChatRepository>(),
            ),
          ),
        ],
        child: const MyApp(),
      ),
    ),
  );
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();

  static _MyAppState of(BuildContext context) =>
      context.findAncestorStateOfType<_MyAppState>()!;
}

class _MyAppState extends State<MyApp> {
  Locale? _locale;
  ThemeMode _themeMode = FlutterFlowTheme.themeMode;

  late AppStateNotifier _appStateNotifier;
  late GoRouter _router;

  @override
  void initState() {
    super.initState();
    _appStateNotifier = AppStateNotifier.instance;
    _router = createRouter(_appStateNotifier);
  }

  @override
  void dispose() {
    super.dispose();
  }

  void setThemeMode(ThemeMode mode) => setState(() {
        _themeMode = mode;
        FlutterFlowTheme.saveThemeMode(mode);
      });

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        final currentLocation =
            _router.routerDelegate.currentConfiguration.uri.toString();
        final publicRoutes = {
          '/loginPage',
          '/registrationPage',
          '/otpScreen',
          '/forgotPassword',
          '/resetPassword',
          '/onboardingPage',
          '/'
        };

        if (state is AuthUnauthenticated) {
          if (!publicRoutes.contains(currentLocation)) {
            _router.go('/loginPage');
          }
        } else if (state is AuthDriverAuthenticated) {
          context.read<DriverProfileBloc>().add(LoadDriverProfile(
              driverId: state.authData.driverProfile!.id.toString()));
          if (publicRoutes.contains(currentLocation) &&
              currentLocation != '/') {
            _router.go('/homePage');
          } else if (currentLocation == '/') {
            _router.go('/homePage');
          }
        }
      },
      child: MaterialApp.router(
        title: 'Langa's Driver',
        debugShowCheckedModeBanner: false,
        localizationsDelegates: const [],
        locale: _locale,
        theme: ThemeData(
          brightness: Brightness.light,
        ),
        darkTheme: ThemeData(
          brightness: Brightness.light,
        ),
        themeMode: _themeMode,
        routerConfig: _router,
      ),
    );
  }
}
