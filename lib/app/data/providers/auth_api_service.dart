import 'package:get/get.dart';
import '../../core/config/api_config.dart';
import '../../core/utils/app_logger.dart';
import '../providers/auth_interceptor.dart';
import '../providers/token_manager.dart';

class AuthApiService {
  final ApiClient _apiClient = ApiClient.instance;

  /// Login with username and password to get OAuth tokens
  /// POST /oauth/token
  /// Body: grant_type=password, username, password (form-data)
  /// Headers: Authorization: Basic R2VuZXJhbDpHZW5lcmFs
  /// Response: { access_token, refresh_token, expires_in, refreshToken_ExpireIn }
  Future<Response> login({
    required String username,
    required String password,
  }) async {
    try {
      AppLogger.info('🔐 Attempting login for: $username');

      // Create FormData for multipart/form-data
      final formData = FormData({
        'grant_type': 'password',
        'username': username,
        'password': password,
      });

      final response = await _apiClient.post(
        ApiConfig.login,
        formData,
        headers: {'Authorization': ApiConfig.authHeader},
      );

      if (response.statusCode == 200 && response.body != null) {
        final data = response.body;

        // Extract token expiry times
        final expiresIn = data['expires_in'] ?? 3600; // Default 1 hour
        final refreshTokenExpiresIn =
            data['refreshToken_ExpireIn'] ?? 86400; // Default 24 hours

        // Save tokens with expiry info
        await TokenManager.saveTokens(
          accessToken: data['access_token'],
          refreshToken: data['refresh_token'],
          expiresIn: expiresIn,
          refreshTokenExpiresIn: refreshTokenExpiresIn,
        );

        AppLogger.info('✅ Login successful');
        AppLogger.debug('   Access token expires in: $expiresIn seconds');
        AppLogger.debug(
          '   Refresh token expires in: $refreshTokenExpiresIn seconds',
        );
      }

      return response;
    } catch (e) {
      AppLogger.error('❌ Login error: $e', e);
      rethrow;
    }
  }

  /// Refresh access token using refresh token
  /// POST /oauth/token
  /// Body: grant_type=refresh_token, refresh_token (form-data)
  /// Headers: Authorization: Basic R2VuZXJhbDpHZW5lcmFs
  /// Response: { access_token, refresh_token, expires_in, refreshToken_ExpireIn }
  Future<Response> refreshToken(String refreshToken) async {
    try {
      AppLogger.info('🔄 Attempting token refresh');

      // Create FormData for multipart/form-data
      final formData = FormData({
        'grant_type': 'refresh_token',
        'refresh_token': refreshToken,
      });

      final response = await _apiClient.post(
        ApiConfig.login,
        formData,
        headers: {'Authorization': ApiConfig.authHeader},
      );

      if (response.statusCode == 200 && response.body != null) {
        final data = response.body;

        // Extract token expiry times
        final expiresIn = data['expires_in'] ?? 3600; // Default 1 hour
        final refreshTokenExpiresIn =
            data['refreshToken_ExpireIn'] ?? 86400; // Default 24 hours

        // Save new tokens with expiry info
        await TokenManager.saveTokens(
          accessToken: data['access_token'],
          refreshToken: data['refresh_token'],
          expiresIn: expiresIn,
          refreshTokenExpiresIn: refreshTokenExpiresIn,
        );

        AppLogger.info('✅ Token refresh successful');
        AppLogger.debug('   Access token expires in: $expiresIn seconds');
        AppLogger.debug(
          '   Refresh token expires in: $refreshTokenExpiresIn seconds',
        );
      }

      return response;
    } catch (e) {
      AppLogger.error('❌ Token refresh error: $e', e);
      rethrow;
    }
  }

  /// Sign up a new user
  /// POST /public/signup
  /// Body: JSON with user details
  Future<Response> signUp({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
    required String gender,
    String profileType = 'Private',
  }) async {
    try {
      AppLogger.info('📝 Attempting signup for: $email');

      final response = await _apiClient.post(ApiConfig.register, {
        'email': email,
        'password': password,
        'firstName': firstName,
        'lastName': lastName,
        'gender': gender,
        'profileType': profileType,
      });

      AppLogger.info('📥 Signup response: ${response.statusCode}');
      return response;
    } catch (e) {
      AppLogger.error('❌ Signup error: $e', e);
      rethrow;
    }
  }

  /// Sign up a new user with custom data
  /// POST /public/signup
  /// Body: JSON with user details (accepts Map for flexibility)
  Future<Response> signUpWithData(Map<String, dynamic> data) async {
    try {
      AppLogger.info('📝 Attempting signup for: ${data['email']}');

      final response = await _apiClient.post(ApiConfig.register, data);

      AppLogger.info('📥 Signup response: ${response.statusCode}');
      return response;
    } catch (e) {
      AppLogger.error('❌ Signup error: $e', e);
      rethrow;
    }
  }

  /// Logout - clear tokens
  Future<void> logout() async {
    try {
      AppLogger.info('🚪 Logging out');
      await _apiClient.clearTokens();
      Get.offAllNamed('/sign-in');
    } catch (e) {
      AppLogger.error('❌ Logout error: $e', e);
    }
  }
}
