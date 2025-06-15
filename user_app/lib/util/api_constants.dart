class ApiConstants {
  static const String baseUrl = 'http://41.174.125.165:4037';

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
  static const String requestOtp = '/api/v2/auth/request-otp';
  static const String validateOtp = '/api/v2/auth/validate-otp';
  static const String register = '/api/v2/auth/register';
  static const String login = '/api/v2/auth/login';
  static const String getRandomSecurityQuestions =
      '/api/v2/security-questions/random';
  static const String requestPasswordResetOtp =
      '/api/v2/auth/password/request-reset-otp';
  static const String verifyPasswordResetOtp =
      '/api/v2/auth/password/verify-reset-otp';
  static const String verifySecurityAnswers =
      '/api/v2/auth/password/verify-security-answers';
  static const String resetPasswordWithToken =
      '/api/v2/auth/password/reset-with-token';

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
