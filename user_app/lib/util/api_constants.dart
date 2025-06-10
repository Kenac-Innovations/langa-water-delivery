class ApiConstants {
  static const String baseUrl = 'http://41.174.125.165:4027';

  static const String googleApiKey = 'AIzaSyCypv_t46n6rxFVM65vQ8Qpt5kekFR007I';
  static const String paynowIntegrationKey =
      'AIzaSyCypv_t46n6rxFVM65vQ8Qpt5kekFR007I';
  static const String paynowIntegrationID =
      'AIzaSyCypv_t46n6rxFVM65vQ8Qpt5kekFR007I';
  static const String paynowReturnUrl =
      'AIzaSyCypv_t46n6rxFVM65vQ8Qpt5kekFR007I';
  static const String paynowResultUrl =
      'AIzaSyCypv_t46n6rxFVM65vQ8Qpt5kekFR007I';

  // Authentication Endpoints
  static const String register = '/api/v1/client/auth/register';
  static const String verifyAccount = '/api/v1/client/auth/verify-account';
  static const String login = '/api/v1/client/auth/login';
  static const String requestPasswordLink =
      '/api/v1/client/auth/request-password-link';
  static const String resetPassword = '/api/v1/client/auth/reset-password';

  // === Delivery Endpoints ===
  static const String clientDeliveriesBase = '/api/v1/client';
  static const String deliveryHistory = '/delivery-history';
  static const String deliveries = '/deliveries';
  static const String selectDriver = '/select';
  static const String cancelDelivery = '/cancel';
  static const String payment = '/payment';
  static const String priceGenerator = '/api/v1/client/price-generator';

  static const String notificationsBase = '/api/v1/notifications';
  static const String updateNotificationStatus =
      '$notificationsBase/update-status';
  static const String markAllNotificationsRead =
      '$notificationsBase/mark-all-read';
  static const String userNotifications = '$notificationsBase/user';
  static const String unreadNotificationCount =
      '$notificationsBase/unread-count';

  // === User Device FCM Token Registration ===
  static String registerDeviceToken(String userId) =>
      '/api/v1/users/$userId/devices';

  // Helper to build paths with IDs
  static String deliveryById(String clientId, int deliveryId) =>
      '$clientDeliveriesBase/$clientId$deliveries/$deliveryId';

  static String clientDeliveries(String clientId) =>
      '$clientDeliveriesBase/$clientId$deliveries';
  static String clientActiveDeliveries(String clientId) =>
      '$clientDeliveriesBase/$clientId$deliveries/active';
  static String clientDeliveryHistory(String clientId) =>
      '$clientDeliveriesBase/$clientId$deliveryHistory';
  static String availableDriversForDelivery(String deliveryId) =>
      '$clientDeliveriesBase/$deliveryId/available-drivers';

  static String selectDriverForDelivery(String clientId) =>
      '$clientDeliveriesBase/$clientId$deliveries$selectDriver';

  static String cancelClientDelivery(String clientId) =>
      '$clientDeliveriesBase/$clientId$deliveries$cancelDelivery';

  static String createDeliveryPayment(String clientId) =>
      '$clientDeliveriesBase/$clientId$deliveries$payment';

  static String notificationById(int notificationId) =>
      '$notificationsBase/$notificationId';

  static String markAllNotificationsReadByUserId(int userId) =>
      '$markAllNotificationsRead/$userId';

  static String notificationsByUserId(int userId) =>
      '$userNotifications/$userId';

  static String unreadNotificationCountByUserId(int userId) =>
      '$unreadNotificationCount/$userId';
}
