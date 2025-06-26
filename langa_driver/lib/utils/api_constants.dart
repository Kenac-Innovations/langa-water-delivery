import 'dart:ffi';

class ApiConstants {
  static const String baseUrl = 'http://41.174.125.165:4027/api/v1';

  static const String googleApiKey = 'AIzaSyCypv_t46n6rxFVM65vQ8Qpt5kekFR007I';
  static const String paynowIntegrationKey = '20900';
  static const String paynowIntegrationID =
      '788476bb-fcc1-4291-bd25-5f09e8f9af9e';
  static const String paynowReturnUrl =
      'AIzaSyCypv_t46n6rxFVM65vQ8Qpt5kekFR007I';
  static const String paynowResultUrl =
      'AIzaSyCypv_t46n6rxFVM65vQ8Qpt5kekFR007I';

  // Driver Auth Endpoints
  static const String driverRegister = "$baseUrl/driver/auth/register";
  static const String driverVerifyAccount =
      "$baseUrl/driver/auth/verify-account";
  static const String driverLogin = "$baseUrl/driver/auth/login";
  static String requestPasswordLink(String loginId) =>
      "$baseUrl/driver/auth/request-password-link?loginId=$loginId";
  static const String resetPassword = "$baseUrl/driver/auth/reset-password";

// Driver Profile
  static String driverProfile(String driverId) =>
      "$baseUrl/driver/profile/$driverId";
  static String driverUpdateWorkStatus(int driverId) =>

      ///api/v1/driver/profile/{driverId}/online-status
      "$baseUrl/driver/profile/$driverId/online-status";
  static String updateAvailabilityStatus(String driverId) =>
      "$baseUrl/api/v1/drivers/update-availability";
  static String updateSearchRadius(String driverId) =>
      "$baseUrl/api/v1/drivers/update-work-status";
  // Vehicle Management Endpoints
  static String driverVehicles(String driverId) =>
      "$baseUrl/driver/vehicles/$driverId";
  static String specificVehicle(String driverId, String vehicleId) =>
      "$baseUrl/driver/vehicles/$driverId/$vehicleId";
  static String switchVehicle(String driverId, String vehicleId) =>
      "$baseUrl/driver/vehicles/$driverId/switch/$vehicleId";

  // Delivery Action Endpoints (require deliveryId)
  static String proposeDelivery(String deliveryId) =>
      "$baseUrl/driver/deliveries/$deliveryId/propose";
  static String pickupDelivery(String deliveryId) =>
      "$baseUrl/driver/deliveries/$deliveryId/pickup";
  static String completeDelivery(String deliveryId) =>
      "$baseUrl/driver/deliveries/$deliveryId/complete";
  static String cancelDelivery(String deliveryId) =>
      "$baseUrl/driver/deliveries/$deliveryId/cancel";
  static String selectDelivery(String clientId) =>
      "$baseUrl/client/$clientId/deliveries/select";
  static String acceptDelivery(String deliveryId) =>
      "$baseUrl/driver/deliveries/$deliveryId/accept";

  static String deliveryDetails(String deliveryId) =>
      "$baseUrl/driver/deliveries/$deliveryId";

  static String driverOpenDeliveries(String driverId) =>
      "$baseUrl/driver/$driverId/deliveries/open";
  static String driverCurrentDeliveries(String driverId) =>
      "$baseUrl/driver/$driverId/current-deliveries";
  static String driverDeliveriesHistory(String driverId) =>
      "$baseUrl/driver/$driverId/deliveries";

  static String driverWalletFloat(String driverId) =>
      "$baseUrl/wallet/driver/$driverId/operation-float";
  static String driverTransactions(String driverId) =>
      "$baseUrl/transactions/driver/$driverId";

  // Notifications
  static const String updateNotificationStatus =
      "$baseUrl/notifications/update-status";
  static String markAllNotificationsAsRead(String userId) =>
      "$baseUrl/notifications/mark-all-read/$userId";
  static String deleteNotificationById(String notificationId) =>
      "$baseUrl/notifications/$notificationId";
  static String getUserNotifications(String userId) =>
      "$baseUrl/notifications/user/$userId";
  static String getUnreadNotificationCount(String userId) =>
      "$baseUrl/notifications/unread-count/$userId";
  static const String driverWalletDeposit = "$baseUrl/driver-wallet/deposit";
}
