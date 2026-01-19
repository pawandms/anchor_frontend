import 'package:get/get.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/services/auth_service.dart';
import '../../core/services/user_service.dart';
import '../../core/models/user_model.dart';

class AuthController extends GetxController {
  final AuthService _authService = Get.find<AuthService>();
  final UserService _userService = Get.find<UserService>();
  var isLoggedIn = false.obs;
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
    bool success = await _authService.login(email, password);
    if (success) {
      isLoggedIn.value = true;
      Get.offAllNamed('/home');
      Get.snackbar('Success', 'Welcome back!');
      _fetchUserProfile();
    } else {
      Get.snackbar('Error', 'Login failed. Check credentials.');
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

  void signup(String name, String email, String password) {
    Get.snackbar('Notice', 'Signup API not yet configured.');
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

  void forgotPassword(String email) {
    Get.snackbar('Email Sent', 'Reset link sent to $email');
    Get.back();
  }
}
