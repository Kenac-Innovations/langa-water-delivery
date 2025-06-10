import 'dart:convert';
import 'dart:io';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:go_router/go_router.dart';
import 'package:langas_user/dto/fcm_dto.dart';
import 'package:langas_user/repository/auth_repository.dart';
import 'package:langas_user/services/secure_storage.dart';
import 'package:langas_user/util/api_constants.dart';
import 'package:device_info_plus/device_info_plus.dart';

@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  debugPrint(
      "FCMService (UserApp BGHandler): Handling a background message: ${message.messageId}");
  debugPrint('FCMService (UserApp BGHandler): Message data: ${message.data}');

  RemoteNotification? notification = message.notification;
  Map<String, dynamic> dataPayload = message.data;

  String notificationTitle =
      notification?.title ?? dataPayload['title'] ?? 'TakeU Update';
  String notificationBody =
      notification?.body ?? dataPayload['body'] ?? 'You have a new update.';

  if (notification != null ||
      (dataPayload.containsKey('title') && dataPayload.containsKey('body'))) {
    debugPrint(
        'FCMService (UserApp BGHandler): Background message contained a notification: $notificationTitle');
    final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
        FlutterLocalNotificationsPlugin();
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const DarwinInitializationSettings initializationSettingsIOS =
        DarwinInitializationSettings();
    const InitializationSettings initializationSettings =
        InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
    );
    await flutterLocalNotificationsPlugin.initialize(initializationSettings);

    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'langas_user_channel_id_background',
      'TakeU User Background Notifications',
      channelDescription: 'Notifications for TakeU User app (Background)',
      importance: Importance.max,
      priority: Priority.high,
      showWhen: true,
      icon: '@mipmap/ic_launcher',
    );
    const DarwinNotificationDetails iOSPlatformChannelSpecifics =
        DarwinNotificationDetails(presentSound: true);

    const NotificationDetails platformChannelSpecifics = NotificationDetails(
        android: androidPlatformChannelSpecifics,
        iOS: iOSPlatformChannelSpecifics);

    await flutterLocalNotificationsPlugin.show(
      notification?.hashCode ?? dataPayload.hashCode,
      notificationTitle,
      notificationBody,
      platformChannelSpecifics,
      payload: jsonEncode(dataPayload),
    );
  } else {
    debugPrint(
        "FCMService (UserApp BGHandler): Background message is data-only. Data: $dataPayload");
  }
}

class FCMService {
  final FirebaseMessaging _firebaseMessaging;
  final AuthRepository _authRepository;
  final SecureStorageService _secureStorageService;
  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin;
  final GoRouter? _router;

  static const String _fcmTokenKey = 'fcm_token_user_app';
  static const String _lastSentFcmTokenKey = 'last_sent_fcm_token_user_app';

  FCMService({
    required FirebaseMessaging firebaseMessaging,
    required AuthRepository authRepository,
    required SecureStorageService secureStorageService,
    required FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin,
    GoRouter? router,
  })  : _firebaseMessaging = firebaseMessaging,
        _authRepository = authRepository,
        _secureStorageService = secureStorageService,
        _flutterLocalNotificationsPlugin = flutterLocalNotificationsPlugin,
        _router = router;

  Future<void> initialize() async {
    await _initializeLocalNotifications();

    await _firebaseMessaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      debugPrint(
          'FCMService (UserApp): Got a message whilst in the foreground!');
      debugPrint('FCMService (UserApp): Message data: ${message.data}');

      RemoteNotification? notification = message.notification;
      if (notification != null) {
        _showLocalNotification(notification, message.data);
      } else if (message.data.isNotEmpty) {
        final title = message.data['title'] ?? 'TakeU Update';
        final body = message.data['body'] ?? 'You have a new update.';
        _showLocalNotification(
            RemoteNotification(title: title, body: body), message.data);
      }
    });

    FirebaseMessaging.instance
        .getInitialMessage()
        .then((RemoteMessage? message) {
      if (message != null) {
        debugPrint(
            'FCMService (UserApp): App opened from terminated state by notification: ${message.messageId}');
        Future.delayed(const Duration(milliseconds: 1000), () {
          handleNotificationNavigation(message.data);
        });
      }
    });

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      debugPrint(
          'FCMService (UserApp): App opened from background by notification: ${message.messageId}');
      handleNotificationNavigation(message.data);
    });

    _firebaseMessaging.onTokenRefresh.listen((String? newToken) {
      if (newToken != null) {
        debugPrint('FCMService (UserApp): FCM Token Refreshed: $newToken');
        _secureStorageService.write(key: _fcmTokenKey, value: newToken);
        _resendTokenIfAuthenticated(newToken);
      }
    });
  }

  Future<void> _initializeLocalNotifications() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    final DarwinInitializationSettings initializationSettingsIOS =
        DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
      onDidReceiveLocalNotification: (id, title, body, payload) async {
        debugPrint(
            "FCMService (UserApp iOS onDidReceiveLocalNotification): $title, $body, $payload");
      },
    );

    final InitializationSettings initializationSettings =
        InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
    );

    await _flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) async {
        debugPrint(
            "FCMService (UserApp onDidReceiveNotificationResponse): Payload: ${response.payload}");
        if (response.payload != null && response.payload!.isNotEmpty) {
          try {
            final Map<String, dynamic> dataPayload =
                jsonDecode(response.payload!);
            handleNotificationNavigation(dataPayload);
          } catch (e) {
            debugPrint(
                'FCMService (UserApp): Error decoding notification payload or handling navigation: $e');
            _router?.goNamed('HomePage');
          }
        } else {
          _router?.goNamed('HomePage');
        }
      },
      onDidReceiveBackgroundNotificationResponse:
          notificationTapBackgroundUserApp,
    );

    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      'langas_user_channel_id',
      'TakeU User Notifications',
      description: 'Notifications for TakeU User app',
      importance: Importance.max,
    );

    await _flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);
  }

  Future<void> _resendTokenIfAuthenticated(String newToken) async {
    final user = await _secureStorageService.getUserDetails();
    if (user != null) {
      final userId = user.userId.toString();
      await _sendTokenToServer(userId, newToken, forceSend: true);
    }
  }

  Future<String?> getFcmToken() async {
    String? token = await _secureStorageService.read(key: _fcmTokenKey);

    if (token == null) {
      try {
        token = await _firebaseMessaging.getToken();
        if (token != null) {
          await _secureStorageService.write(key: _fcmTokenKey, value: token);
          debugPrint(
              'FCMService (UserApp): FCM Token obtained and saved: $token');
        }
      } catch (e) {
        debugPrint('FCMService (UserApp): Error getting FCM token: $e');
      }
    }
    return token;
  }

  Future<void> registerTokenForUser(String userId,
      {bool forceSend = false}) async {
    final currentToken = await getFcmToken();
    if (currentToken == null) {
      debugPrint(
          'FCMService (UserApp): FCM token is null, cannot send to backend.');
      return;
    }

    debugPrint(
        'FCMService (UserApp): Proceeding to send token for user $userId. Original forceSend value: $forceSend. Effective behavior: always attempt send.');
    await _sendTokenToServer(userId, currentToken, forceSend: true);
  }

  Future<void> _sendTokenToServer(String userId, String token,
      {bool forceSend = false}) async {
    DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
    String deviceName;
    String devicePlatform;

    try {
      if (Platform.isAndroid) {
        AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
        deviceName = androidInfo.model ?? 'Unknown Android';
        devicePlatform = 'Android';
      } else if (Platform.isIOS) {
        IosDeviceInfo iosInfo = await deviceInfo.iosInfo;
        deviceName = iosInfo.utsname.machine ?? 'Unknown iOS';
        devicePlatform = 'iOS';
      } else {
        deviceName = 'Unknown Platform';
        devicePlatform = Platform.operatingSystem;
      }
    } catch (e) {
      deviceName = 'Error Getting Device Name';
      devicePlatform = Platform.operatingSystem;
      debugPrint("FCMService (UserApp): Error getting device info: $e");
    }

    final requestDto = FCMDeviceRegistrationRequestDto(
      deviceName: deviceName,
      devicePlatform: devicePlatform,
      pushNotificationToken: token,
    );

    try {
      debugPrint(
          'FCMService (UserApp): Sending FCM token for user $userId: ${requestDto.toJson()}');
      final result = await _authRepository.registerDeviceToken(
        userId: userId,
        requestDto: requestDto,
      );

      result.fold(
        (failure) {
          debugPrint(
              'FCMService (UserApp): Failed to send FCM token: ${failure.message} (Status: ${failure.statusCode})');
        },
        (deviceData) {
          debugPrint(
              'FCMService (UserApp): FCM token registered successfully for device ID: ${deviceData.id}');
          _secureStorageService.write(key: _lastSentFcmTokenKey, value: token);
        },
      );
    } catch (e) {
      debugPrint('FCMService (UserApp): Exception while sending FCM token: $e');
    }
  }

  Future<void> handleLogout() async {
    await _secureStorageService.delete(key: _fcmTokenKey);
    await _secureStorageService.delete(key: _lastSentFcmTokenKey);
    debugPrint(
        'FCMService (UserApp): FCM token deleted from local storage on logout.');
  }

  Future<void> _showLocalNotification(
      RemoteNotification notification, Map<String, dynamic> dataPayload) async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'langas_user_channel_id',
      'TakeU User Notifications',
      channelDescription: 'Notifications for TakeU User app',
      importance: Importance.max,
      priority: Priority.high,
      showWhen: true,
      icon: '@mipmap/ic_launcher',
    );
    const DarwinNotificationDetails iOSPlatformChannelSpecifics =
        DarwinNotificationDetails(
            presentSound: true, presentBadge: true, presentAlert: true);

    const NotificationDetails platformChannelSpecifics = NotificationDetails(
        android: androidPlatformChannelSpecifics,
        iOS: iOSPlatformChannelSpecifics);

    await _flutterLocalNotificationsPlugin.show(
      notification.hashCode,
      notification.title,
      notification.body,
      platformChannelSpecifics,
      payload: jsonEncode(dataPayload),
    );
  }

  void handleNotificationNavigation(Map<String, dynamic> data) {
    debugPrint("FCMService (UserApp): Handling navigation for data: $data");
    if (_router == null) {
      debugPrint("FCMService (UserApp): Router is null, cannot navigate.");
      return;
    }

    final String? screen = data['screen']?.toString().toLowerCase();
    final String? deliveryIdStr = data['deliveryId']?.toString();
    final String? clientIdStr = data['clientId']?.toString();

    if (screen != null) {
      switch (screen) {
        case 'current_deliveries':
          _router?.goNamed('Current_Deliveries');
          break;
        case 'delivery_history':
          _router?.goNamed('Delivery_History');
          break;
        case 'track_delivery':
          if (deliveryIdStr != null && clientIdStr != null) {
            try {
              final deliveryId = int.tryParse(deliveryIdStr);
              if (deliveryId != null) {
                _router?.pushNamed('TrackDeliveryPage',
                    extra: {'deliveryId': deliveryId, 'clientId': clientIdStr});
              } else {
                debugPrint(
                    "FCMService (UserApp): Invalid deliveryId format for track_delivery: $deliveryIdStr");
                _router?.goNamed('HomePage');
              }
            } catch (e) {
              debugPrint(
                  "FCMService (UserApp): Error parsing deliveryId for track_delivery: $e");
              _router?.goNamed('HomePage');
            }
          } else {
            debugPrint(
                "FCMService (UserApp): Navigation to track_delivery requested, but deliveryId or clientId is missing.");
            _router?.goNamed('HomePage');
          }
          break;
        case 'notifications':
          _router?.goNamed('Notification');
          break;
        default:
          debugPrint(
              'FCMService (UserApp): Unknown screen for notification navigation: $screen');
          _router?.goNamed('HomePage');
      }
    } else {
      debugPrint(
          "FCMService (UserApp): No screen specified in notification data for navigation.");
      _router?.goNamed('HomePage');
    }
  }
}

@pragma('vm:entry-point')
void notificationTapBackgroundUserApp(
    NotificationResponse notificationResponse) {
  debugPrint(
      'FCMService (UserApp): Notification tapped in background (flutter_local_notifications):');
  if (notificationResponse.payload != null &&
      notificationResponse.payload!.isNotEmpty) {
    debugPrint(
        'FCMService (UserApp BG): Payload: ${notificationResponse.payload}');
  }
}
