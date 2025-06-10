import 'package:equatable/equatable.dart';

class User extends Equatable {
  final int userId;
  final String email;
  final String phoneNumber;
  final String firstName;
  final String lastName;
  final num walletBalance;

  const User({
    required this.userId,
    required this.email,
    required this.phoneNumber,
    required this.firstName,
    required this.lastName,
    required this.walletBalance,
  });

  @override
  List<Object?> get props =>
      [userId, email, phoneNumber, firstName, lastName, walletBalance];

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      userId: json['userId'] as int? ?? json['userID'] as int? ?? 0,
      email: json['email'] as String? ?? '',
      phoneNumber: json['phoneNumber'] as String? ?? '',
      firstName: json['firstName'] as String? ?? '',
      lastName: json['lastName'] as String? ?? '',
      walletBalance: json['walletBalance'] as num? ?? 0,
    );
  }
}
