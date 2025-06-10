import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:langas_user/models/auth_response_model.dart';
import 'package:langas_user/models/user_model.dart';

class SecureStorageService {
  final FlutterSecureStorage _storage = const FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
    iOptions: IOSOptions(accessibility: KeychainAccessibility.first_unlock),
  );

  static const String _authResultKey = 'auth_result_user_app';
  static const String _accessTokenKey = 'access_token_user_app';
  static const String _refreshTokenKey = 'refresh_token_user_app';
  static const String _userDetailsKey = 'user_details_user_app';

  Future<void> write({required String key, String? value}) async {
    await _storage.write(key: key, value: value);
  }

  Future<String?> read({required String key}) async {
    return await _storage.read(key: key);
  }

  Future<void> delete({required String key}) async {
    await _storage.delete(key: key);
  }

  Future<void> saveAuthResult(AuthResult authResult) async {
    try {
      final String authResultString = jsonEncode({
        'accessToken': authResult.accessToken,
        'refreshToken': authResult.refreshToken,
        'userType': authResult.userType,
        'userID': authResult.userID,
        'userProfile': {
          'userId': authResult.userProfile.userId,
          'email': authResult.userProfile.email,
          'phoneNumber': authResult.userProfile.phoneNumber,
          'firstName': authResult.userProfile.firstName,
          'lastName': authResult.userProfile.lastName,
          'walletBalance': authResult.userProfile.walletBalance,
        }
      });
      await write(key: _authResultKey, value: authResultString);
      await saveAccessToken(authResult.accessToken);
      await saveRefreshToken(authResult.refreshToken);
      await saveUserDetails(authResult.userProfile);
    } catch (e) {
      print('Error saving auth result: $e');
    }
  }

  Future<AuthResult?> getAuthResult() async {
    try {
      final String? authResultString = await read(key: _authResultKey);
      if (authResultString != null && authResultString.isNotEmpty) {
        final Map<String, dynamic> authResultJson =
            jsonDecode(authResultString);
        return AuthResult.fromJson(authResultJson);
      }
      return null;
    } catch (e) {
      print('Error reading auth result: $e');
      return null;
    }
  }

  Future<void> saveAccessToken(String token) async {
    await write(key: _accessTokenKey, value: token);
  }

  Future<String?> getAccessToken() async {
    return await read(key: _accessTokenKey);
  }

  Future<void> deleteAccessToken() async {
    await delete(key: _accessTokenKey);
  }

  Future<void> saveRefreshToken(String token) async {
    await write(key: _refreshTokenKey, value: token);
  }

  Future<String?> getRefreshToken() async {
    return await read(key: _refreshTokenKey);
  }

  Future<void> deleteRefreshToken() async {
    await delete(key: _refreshTokenKey);
  }

  Future<void> saveUserDetails(User user) async {
    try {
      final userMap = {
        'userId': user.userId,
        'email': user.email,
        'phoneNumber': user.phoneNumber,
        'firstName': user.firstName,
        'lastName': user.lastName,
        'walletBalance': user.walletBalance,
      };
      final String userJson = jsonEncode(userMap);
      await write(key: _userDetailsKey, value: userJson);
    } catch (e) {
      print('Error saving user details: $e');
    }
  }

  Future<User?> getUserDetails() async {
    try {
      final String? userJson = await read(key: _userDetailsKey);
      if (userJson != null && userJson.isNotEmpty) {
        final Map<String, dynamic> userMap = jsonDecode(userJson);
        return User.fromJson(userMap);
      }
      return null;
    } catch (e) {
      print('Error reading user details: $e');
      return null;
    }
  }

  Future<void> deleteUserDetails() async {
    await delete(key: _userDetailsKey);
  }

  Future<void> deleteAllData() async {
    await delete(key: _authResultKey);
    await deleteAccessToken();
    await deleteRefreshToken();
    await deleteUserDetails();
  }
}
