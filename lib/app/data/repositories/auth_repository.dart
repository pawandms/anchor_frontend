import 'package:get/get.dart';
import '../../core/utils/app_logger.dart';
import '../providers/auth_api_service.dart';

class AuthRepository {
  final AuthApiService _authApi = AuthApiService();

  /// Login with email and password
  Future<Map<String, dynamic>?> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _authApi.login(
        username: email,
        password: password,
      );

      if (response.statusCode == 200) {
        return response.body as Map<String, dynamic>;
      } else {
        Get.snackbar(
          'Login Failed',
          response.body?['error_description'] ?? 'Invalid credentials',
          snackPosition: SnackPosition.BOTTOM,
        );
        return null;
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to login: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
      return null;
    }
  }

  /// Sign up new user
  Future<Map<String, dynamic>?> signUp({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
    required String gender,
    String profileType = 'Private',
  }) async {
    try {
      final response = await _authApi.signUp(
        email: email,
        password: password,
        firstName: firstName,
        lastName: lastName,
        gender: gender,
        profileType: profileType,
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        Get.snackbar(
          'Success',
          'Account created successfully!',
          snackPosition: SnackPosition.BOTTOM,
        );
        return response.body as Map<String, dynamic>;
      } else {
        Get.snackbar(
          'Signup Failed',
          response.body?['message'] ?? 'Failed to create account',
          snackPosition: SnackPosition.BOTTOM,
        );
        return null;
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to sign up: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
      return null;
    }
  }

  /// Refresh access token
  Future<bool> refreshToken(String refreshToken) async {
    try {
      final response = await _authApi.refreshToken(refreshToken);
      return response.statusCode == 200;
    } catch (e) {
      AppLogger.error('❌ Refresh token failed: $e', e);
      return false;
    }
  }

  /// Logout
  Future<void> logout() async {
    await _authApi.logout();
  }
}
