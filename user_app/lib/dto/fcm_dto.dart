class FCMDeviceRegistrationRequestDto {
  final String deviceName;
  final String devicePlatform;
  final String pushNotificationToken;

  FCMDeviceRegistrationRequestDto({
    required this.deviceName,
    required this.devicePlatform,
    required this.pushNotificationToken,
  });

  Map<String, dynamic> toJson() {
    return {
      'deviceName': deviceName,
      'devicePlatform': devicePlatform,
      'pushNotificationToken': pushNotificationToken,
    };
  }
}

class FCMDeviceDataDto {
  final int id;
  final String deviceName;
  final String devicePlatform;
  final String? lastActiveTime;
  final String pushNotificationToken;
  final bool active;

  FCMDeviceDataDto({
    required this.id,
    required this.deviceName,
    required this.devicePlatform,
    this.lastActiveTime,
    required this.pushNotificationToken,
    required this.active,
  });

  factory FCMDeviceDataDto.fromJson(Map<String, dynamic> json) {
    return FCMDeviceDataDto(
      id: json['id'] ?? 0,
      deviceName: json['deviceName'] ?? '',
      devicePlatform: json['devicePlatform'] ?? '',
      lastActiveTime: json['lastActiveTime'] as String?,
      pushNotificationToken: json['pushNotificationToken'] ?? '',
      active: json['active'] ?? false,
    );
  }
}
