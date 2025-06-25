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

  // Promotions Endpoints
  static const String promotions = '/api/v2/promotions';
  static String promotionById(int id) => '$promotions/$id';

  // === User Device FCM Token Registration ===
  static String registerDeviceToken(String userId) =>
      '/api/v1/users/$userId/devices';

  // Water Orders Endpoints
  static const String createWaterOrder = '/api/v2/water-orders/create';
  static String waterOrderById(int orderId) => '/api/v2/water-orders/$orderId';
  static String clientRecentDeliveries(int clientId) =>
      '/api/v2/water-orders/client/$clientId';

  // Water Deliveries Endpoints
  static String waterDeliveryById(int orderId) =>
      '/api/v2/water-deliveries/getbyId/$orderId';
  static String allWaterDeliveriesByClientId(int clientId) =>
      '/api/v2/water-deliveries/client/$clientId';

  // Payment Card Endpoints
  static const String createPaymentCard = '/api/v2/payment-cards/create';
  static const String setDefaultPaymentCard =
      '/api/v2/payment-cards/set-default';
  static String updatePaymentCard(int cardId) =>
      '/api/v2/payment-cards/update/$cardId';
  static String getClientPaymentCards(int clientId) =>
      '/api/v2/payment-cards/client/$clientId';
  static String deletePaymentCard(int cardId) =>
      '/api/v2/payment-cards/delete/$cardId';

  // Client Address Endpoints
  static const String createClientAddress =
      '/api/v2/client-profile/address/create';
  static String getClientAddresses(int clientId) =>
      '/api/v2/client-profile/address/getbyclient/$clientId';
  static const String setDefaultAddress =
      '/api/v2/client-profile/address/set-default';
  static String updateClientAddress(int addressId) =>
      '/api/v2/client-profile/address/update/$addressId';
  static String deleteClientAddress(int addressId) =>
      '/api/v2/client-profile/address/delete/$addressId';
}
