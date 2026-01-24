import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/services/user_service.dart';
import '../../../core/models/user_model.dart';
import '../../../core/enums/user_language_type.dart';

class UserController extends GetxController {
  final UserService _userService = Get.find<UserService>();

  Rx<UserModel?> currentUser = Rx<UserModel?>(null);
  var isLoading = false.obs;

  // Inline messaging state
  var profileUpdateMessage = RxnString();
  var isProfileUpdateSuccess = false.obs;

  @override
  void onInit() {
    super.onInit();
  }

  Future<void> fetchUserProfile() async {
    final prefs = await SharedPreferences.getInstance();
    String? userId = prefs.getString('userID');
    debugPrint('UserController: Fetching profile for userId: $userId');

    if (userId != null) {
      try {
        final profileData = await _userService.getUserProfile(userId);
        if (profileData != null) {
          debugPrint('UserController: Profile data received. Parsing...');
          currentUser.value = UserModel.fromJson(profileData);

          // Set locale based on user language
          if (currentUser.value != null) {
            _updateLocale(currentUser.value!.userLanguage);
          }

          debugPrint(
              'UserController: Profile parsed. User: ${currentUser.value?.fullName}');
        } else {
          debugPrint('UserController: Profile data is NULL');
        }
      } catch (e) {
        debugPrint('UserController: Error fetching/parsing profile: $e');
      }
    } else {
      debugPrint('UserController: No userId found in SharedPreferences');
    }
  }

  void updateUserLanguage(UserLanguageType language) async {
    if (currentUser.value == null) return;

    // Optimistic update
    final previousLanguage = currentUser.value!.userLanguage;
    currentUser.value = currentUser.value!.copyWith(userLanguage: language);
    _updateLocale(language);

    bool success = await _userService.updateUserProfile(
      currentUser.value!.id,
      {'userLanguage': language.value},
    );

    if (!success) {
      Get.snackbar('Error', 'Failed to update language preference');
      // Revert
      currentUser.value =
          currentUser.value!.copyWith(userLanguage: previousLanguage);
      _updateLocale(previousLanguage);
    }
  }

  void updateProfileImage(String mediaId) {
    debugPrint(
        'UserController: Updating profile image state with mediaId: $mediaId');
    if (currentUser.value != null) {
      currentUser.value =
          currentUser.value!.copyWith(profileImageMediaId: mediaId);
      currentUser.refresh(); // Explicitly notify listeners
      debugPrint(
          'UserController: Profile image updated and listeners notified.');
    } else {
      debugPrint(
          'UserController: Cannot update profile image. Current user is null.');
    }
  }

  Future<void> updateUserDetails(Map<String, dynamic> updates) async {
    if (currentUser.value == null) return;

    try {
      isLoading.value = true;
      profileUpdateMessage.value = null;
      isProfileUpdateSuccess.value = false;

      bool success = await _userService.updateUserProfile(
        currentUser.value!.id,
        updates,
      );

      if (success) {
        // Fetch fresh profile to ensure local state matches server
        await fetchUserProfile();
        isProfileUpdateSuccess.value = true;
        profileUpdateMessage.value = 'Profile updated successfully'.tr;
      } else {
        isProfileUpdateSuccess.value = false;
        profileUpdateMessage.value = 'Failed to update profile'.tr;
      }
    } catch (e) {
      isProfileUpdateSuccess.value = false;
      profileUpdateMessage.value = 'An error occurred: $e'.tr;
    } finally {
      isLoading.value = false;
    }
  }

  void clearProfileMessages() {
    profileUpdateMessage.value = null;
    isProfileUpdateSuccess.value = false;
  }

  void clearUser() {
    currentUser.value = null;
  }

  void _updateLocale(UserLanguageType language) {
    Locale locale;
    switch (language) {
      case UserLanguageType.hindi:
        locale = const Locale('hi', 'IN');
        break;
      default:
        locale = const Locale('en', 'US');
        break;
    }
    Get.updateLocale(locale);
  }
}
