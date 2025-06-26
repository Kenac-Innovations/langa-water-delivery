import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
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
      child: const MyApp(),
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
    return MaterialApp.router(
      title: 'Langas Driver',
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
    );
  }
}
