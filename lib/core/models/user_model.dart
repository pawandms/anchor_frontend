import 'package:flutter/foundation.dart';
import '../enums/user_status_type.dart';
import '../enums/gender.dart';
import '../enums/profile_type.dart';
import 'privacy_settings.dart';
import 'notification_settings.dart';

class UserModel {
  final String id;
  final String firstName;
  final String lastName;
  final String userName;
  final String email;
  final String mobile;
  final Gender gender;
  final DateTime? dob;
  final ProfileType profileType;
  final UserStatusType status;
  final String? profileImageMediaId;
  final PrivacySettings privacySettings;
  final NotificationSettings notificationSettings;

  UserModel({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.userName,
    required this.email,
    required this.mobile,
    required this.gender,
    this.dob,
    required this.profileType,
    required this.status,
    this.profileImageMediaId,
    required this.privacySettings,
    required this.notificationSettings,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    if (kDebugMode) {
      print('Parsing UserModel from JSON: $json');
    }

    // Helper to find key efficiently
    dynamic getValue(String key, {List<String>? altKeys}) {
      if (json.containsKey(key)) return json[key];
      if (altKeys != null) {
        for (var k in altKeys) {
          if (json.containsKey(k)) return json[k];
        }
      }
      return null;
    }

    return UserModel(
      id: getValue('id') ?? '',
      firstName: getValue('firstName', altKeys: ['first_name']) ?? '',
      lastName: getValue('lastName', altKeys: ['last_name']) ?? '',
      userName: getValue('userName', altKeys: ['username', 'user_name']) ?? '',
      email: getValue('email') ?? '',
      mobile: getValue('mobile') ?? '',
      gender: Gender.fromString(getValue('gender') ?? 'OTHER'),
      dob: json['dob'] != null ? DateTime.tryParse(json['dob']) : null,
      profileType: ProfileType.fromString(
          getValue('profileType', altKeys: ['profile_type', 'type']) ??
              'public'),
      status: UserStatusType.fromValue(getValue('status') ?? 'offline'),
      profileImageMediaId: getValue('profileImageMediaId',
          altKeys: ['profile_image_media_id', 'mediaId', 'avatarId']),
      privacySettings: PrivacySettings.fromJson(json['privacySettings'] ?? {}),
      notificationSettings: NotificationSettings.fromJson(
        json['notificationSettings'] ?? {},
      ),
    );
  }

  String get fullName => '$firstName $lastName';
  String get initials => firstName.isNotEmpty && lastName.isNotEmpty
      ? '${firstName[0]}${lastName[0]}'.toUpperCase()
      : 'U';

  UserModel copyWith({
    String? id,
    String? firstName,
    String? lastName,
    String? userName,
    String? email,
    String? mobile,
    Gender? gender,
    DateTime? dob,
    ProfileType? profileType,
    UserStatusType? status,
    String? profileImageMediaId,
    PrivacySettings? privacySettings,
    NotificationSettings? notificationSettings,
  }) {
    return UserModel(
      id: id ?? this.id,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      userName: userName ?? this.userName,
      email: email ?? this.email,
      mobile: mobile ?? this.mobile,
      gender: gender ?? this.gender,
      dob: dob ?? this.dob,
      profileType: profileType ?? this.profileType,
      status: status ?? this.status,
      profileImageMediaId: profileImageMediaId ?? this.profileImageMediaId,
      privacySettings: privacySettings ?? this.privacySettings,
      notificationSettings: notificationSettings ?? this.notificationSettings,
    );
  }
}
