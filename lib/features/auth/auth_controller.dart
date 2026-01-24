import 'package:get/get.dart';
import 'package:flutter/foundation.dart';

import '../../core/services/auth_service.dart';
import '../../core/enums/gender_type.dart';
import '../../core/models/api_error_response.dart';
import '../../shared/screens/server_side_error_screen.dart';
import '../profile/controllers/user_controller.dart';

class AuthController extends GetxController {
  final AuthService _authService = Get.find<AuthService>();
  final UserController _userController = Get.find<UserController>();
  var isLoggedIn = false.obs;
  var isLoading = false.obs;
  var loginError = RxnString();
  var validationErrors =
      <String, String>{}.obs; // FieldName -> Translate Message

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
      _userController.fetchUserProfile();
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
        _userController.fetchUserProfile();
      } else {
        if (result['statusCode'] == 401) {
          loginError.value = 'invalid_credentials'.tr;
        } else if (result['statusCode'] == 500) {
          Get.to(() => ServerSideErrorScreen(
                errorDetails: result['message'] ?? 'Unknown Error',
              ));
        } else {
          loginError.value = result['message'] ?? 'Login failed';
        }
      }
    } finally {
      isLoading.value = false;
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
            validationErrors[error.fieldName] = error.errorCode.tr;
          }
        }
        loginError.value = result['message'] ?? 'Signup failed';
      }
    } finally {
      isLoading.value = false;
    }
  }

  void logout() async {
    await _authService.logout();
    isLoggedIn.value = false;
    _userController.clearUser();
  }

  void forgotPassword(String email) {
    Get.snackbar('Email Sent', 'Reset link sent to $email');
    Get.back();
  }
}
