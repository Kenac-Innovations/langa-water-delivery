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
}
