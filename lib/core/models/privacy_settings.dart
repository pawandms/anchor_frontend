import '../enums/user_privacy_type.dart';

class PrivacySettings {
  final UserPrivacyType lastSeen;
  final UserPrivacyType profileVisiblity;
  final UserPrivacyType statusVisibility;
  final bool readReceipts;
  final UserPrivacyType callVisibility;

  PrivacySettings({
    required this.lastSeen,
    required this.profileVisiblity,
    required this.statusVisibility,
    required this.readReceipts,
    required this.callVisibility,
  });

  factory PrivacySettings.fromJson(Map<String, dynamic> json) {
    return PrivacySettings(
      lastSeen: UserPrivacyType.fromString(json['lastSeen']),
      profileVisiblity: UserPrivacyType.fromString(json['profileVisiblity']),
      statusVisibility: UserPrivacyType.fromString(json['statusVisibility']),
      readReceipts: json['readReceipts'] ?? true,
      callVisibility: UserPrivacyType.fromString(json['callVisibility']),
    );
  }
}
