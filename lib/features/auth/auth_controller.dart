import 'package:get/get.dart';
import 'package:flutter/foundation.dart';
import 'dart:ui';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/services/auth_service.dart';
import '../../core/services/user_service.dart';
import '../../core/models/user_model.dart';
import '../../core/enums/user_language_type.dart';
import '../../core/enums/gender_type.dart';
import '../../core/models/api_error_response.dart';

class AuthController extends GetxController {
  final AuthService _authService = Get.find<AuthService>();
  final UserService _userService = Get.find<UserService>();
  var isLoggedIn = false.obs;
  var isLoading = false.obs;
  var loginError = RxnString();
  var validationErrors =
      <String, String>{}.obs; // FieldName -> Translate Message
  Rx<UserModel?> currentUser = Rx<UserModel?>(null);

  @override
  void onInit() {
    super.onInit();
    if (!Get.testMode) {
      _checkSession();
    }
  }

  Future<void> _checkSession() async {
    // Minimum delay to ensure Splash Screen is visible
    await Future.delayed(const Duration(seconds: 2));

    String? token = await _authService.getValidToken();
    debugPrint('Session Check: Token found: ${token != null}');

    if (token != null) {
      isLoggedIn.value = true;
      Get.offAllNamed('/home');
      _fetchUserProfile();
    } else {
      isLoggedIn.value = false;
      Get.offAllNamed('/login');
    }
  }

  Future<void> login(String email, String password) async {
    try {
      isLoading.value = true;
      loginError.value = null;

      final result = await _authService.login(email, password);

      if (result['success'] == true) {
        isLoggedIn.value = true;
        Get.offAllNamed('/home');
        _fetchUserProfile();
      } else {
        loginError.value = result['message'] ?? 'Login failed';
      }
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> _fetchUserProfile() async {
    final prefs = await SharedPreferences.getInstance();
    String? userId = prefs.getString('userID');
    debugPrint('AuthController: Fetching profile for userId: $userId');

    if (userId != null) {
      try {
        final profileData = await _userService.getUserProfile(userId);
        if (profileData != null) {
          debugPrint('AuthController: Profile data received. Parsing...');
          currentUser.value = UserModel.fromJson(profileData);

          // Set locale based on user language
          if (currentUser.value != null) {
            _updateLocale(currentUser.value!.userLanguage);
          }

          debugPrint(
              'AuthController: Profile parsed. User: ${currentUser.value?.fullName}');
        } else {
          debugPrint('AuthController: Profile data is NULL');
        }
      } catch (e) {
        debugPrint('AuthController: Error fetching/parsing profile: $e');
      }
    } else {
      debugPrint('AuthController: No userId found in SharedPreferences');
    }
  }

  Future<void> signup({
    required String firstName,
    required String lastName,
    required String email,
    required String password,
    String? mobile,
    DateTime? dob,
    GenderType? gender,
  }) async {
    try {
      isLoading.value = true;
      loginError.value = null;
      validationErrors.clear();

      Map<String, dynamic> data = {
        'firstName': firstName,
        'lastName': lastName,
        'email': email,
        'password': password,
        'mobile': mobile,
        'dob': dob?.toIso8601String().split('T')[0], // YYYY-MM-DD
        'gender': gender?.value ?? GenderType.other.value,
      };

      final result = await _authService.signup(data);

      if (result['success'] == true) {
        Get.snackbar('Success', 'Account created! Please login.');
        Get.offAllNamed('/login');
      } else {
        if (result['validationErrors'] != null) {
          final List<ApiValidationError> errors = result['validationErrors'];
          for (var error in errors) {
            // Map fieldName to translated error message
            // error.errorCode should be the key in TranslationService (e.g. Email_Already_Present)
            // If translation not found, fallback to fieldName + error.errorCode or generic
            validationErrors[error.fieldName] = error.errorCode.tr;
          }
        }
        // Use inline error instead of snackbar
        loginError.value = result['message'] ?? 'Signup failed';
      }
    } finally {
      isLoading.value = false;
    }
  }

  void logout() async {
    await _authService.logout();
    isLoggedIn.value = false;
    currentUser.value = null;
  }

  void updateProfileImage(String mediaId) {
    debugPrint(
        'AuthController: Updating profile image state with mediaId: $mediaId');
    if (currentUser.value != null) {
      currentUser.value =
          currentUser.value!.copyWith(profileImageMediaId: mediaId);
      currentUser.refresh(); // Explicitly notify listeners
      debugPrint(
          'AuthController: Profile image updated and listeners notified.');
    } else {
      debugPrint(
          'AuthController: Cannot update profile image. Current user is null.');
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

  void forgotPassword(String email) {
    Get.snackbar('Email Sent', 'Reset link sent to $email');
    Get.back();
  }
}
