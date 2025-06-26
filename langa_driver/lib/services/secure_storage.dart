import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:langas_driver/models/auth_models.dart';
import 'dart:convert';

class SecureStorageService {
  final FlutterSecureStorage _storage = const FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
    iOptions: IOSOptions(accessibility: KeychainAccessibility.first_unlock),
  );

  final String _authDataKey = 'auth_data';
  final String _accessTokenKey =
      'access_token'; // Keep for direct access if needed
  final String _refreshTokenKey = 'refresh_token';

  Future<void> saveAuthData(AuthResponseData authData) async {
    try {
      final String authDataString = jsonEncode(authData.toJson());
      await _storage.write(key: _authDataKey, value: authDataString);
      // Also save tokens individually for potential direct access (e.g., interceptor)
      await _storage.write(key: _accessTokenKey, value: authData.accessToken);
      await _storage.write(key: _refreshTokenKey, value: authData.refreshToken);
    } catch (e) {
      // Handle potential encoding errors
      print('Error saving auth data: $e');
    }
  }

  Future<AuthResponseData?> getAuthData() async {
    try {
      final String? authDataString = await _storage.read(key: _authDataKey);
      if (authDataString != null) {
        final Map<String, dynamic> authDataJson = jsonDecode(authDataString);
        return AuthResponseData.fromJson(authDataJson);
      }
      return null;
    } catch (e) {
      // Handle potential decoding errors
      print('Error reading auth data: $e');
      return null;
    }
  }

  Future<String?> getAccessToken() async {
    return await _storage.read(key: _accessTokenKey);
  }

  Future<String?> getRefreshToken() async {
    return await _storage.read(key: _refreshTokenKey);
  }

  Future<void> deleteAuthData() async {
    await _storage.delete(key: _authDataKey);
    await _storage.delete(key: _accessTokenKey);
    await _storage.delete(key: _refreshTokenKey);
  }
}
