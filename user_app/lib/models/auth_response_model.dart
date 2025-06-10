import 'package:equatable/equatable.dart';
import 'package:langas_user/models/user_model.dart';

class AuthResult extends Equatable {
  final String accessToken;
  final String refreshToken;
  final String userType;
  final int userID;
  final User userProfile;

  const AuthResult({
    required this.accessToken,
    required this.refreshToken,
    required this.userType,
    required this.userID,
    required this.userProfile,
  });

  @override
  List<Object?> get props =>
      [accessToken, refreshToken, userType, userID, userProfile];

  factory AuthResult.fromJson(Map<String, dynamic> json) {
    final userProfileJson = json['userProfile'] as Map<String, dynamic>? ?? {};
    return AuthResult(
      accessToken: json['accessToken'] as String? ?? '',
      refreshToken: json['refreshToken'] as String? ?? '',
      userType: json['userType'] as String? ?? '',
      userID: json['userID'] as int? ?? 0,
      userProfile: User.fromJson(userProfileJson),
    );
  }
}
