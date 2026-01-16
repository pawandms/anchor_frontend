import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/config/api_config.dart';
import '../../core/utils/app_logger.dart';
import 'token_manager.dart';

class ApiClient extends GetConnect {
  static ApiClient? _instance;

  static ApiClient get instance {
    _instance ??= ApiClient._internal();
    return _instance!;
  }

  ApiClient._internal() {
    // Set base URL
    httpClient.baseUrl = ApiConfig.baseUrl;

    // Set timeout
    httpClient.timeout = const Duration(seconds: 30);

    // Add request interceptor
    httpClient.addRequestModifier<dynamic>((request) async {
      // Add token to all requests except login/register
      if (!request.url.path.contains(ApiConfig.oauthTokenPath) &&
          !request.url.path.contains(ApiConfig.publicPath)) {
        // Check if access token is expired or will expire soon
        final isExpired = await TokenManager.isAccessTokenExpired(
          bufferSeconds: 60,
        );

        if (isExpired) {
          AppLogger.warning(
            '⚠️ Access token expired, refreshing before request...',
          );
          final refreshed = await _refreshToken();
          if (!refreshed) {
            AppLogger.error('❌ Failed to refresh token');
            await _handleAuthFailure();
          }
        }

        // Get current access token
        final token = await TokenManager.getAccessToken();

        if (token != null && token.isNotEmpty) {
          request.headers['Authorization'] = 'Bearer $token';
        }
      }

      AppLogger.debug('📤 REQUEST: ${request.method} ${request.url}');
      AppLogger.trace('Headers: ${request.headers}');

      return request;
    });

    // Add response interceptor
    httpClient.addResponseModifier((request, response) async {
      AppLogger.debug('📥 RESPONSE: ${response.statusCode} ${request.url}');

      // Handle 401 Unauthorized - Token expired
      if (response.statusCode == 401) {
        AppLogger.warning('🔄 Got 401, attempting refresh...');

        final refreshed = await _refreshToken();
        if (refreshed) {
          // Retry original request with new token
          final newToken = await TokenManager.getAccessToken();
          request.headers['Authorization'] = 'Bearer $newToken';

          // Retry the request
          return await httpClient.request(
            request.url.toString(),
            request.method,
            headers: request.headers,
          );
        } else {
          // Refresh failed, logout user
          await _handleAuthFailure();
        }
      }

      return response;
    });

    // Add error interceptor
    httpClient.addAuthenticator<dynamic>((request) async {
      AppLogger.trace('🔐 Authenticator called for: ${request.url}');
      return request;
    });
  }

  Future<bool> _refreshToken() async {
    try {
      final refreshToken = await TokenManager.getRefreshToken();

      if (refreshToken == null || refreshToken.isEmpty) {
        AppLogger.error('❌ No refresh token available');
        return false;
      }

      // Check if refresh token itself is expired
      final isRefreshExpired = await TokenManager.isRefreshTokenExpired();
      if (isRefreshExpired) {
        AppLogger.error('❌ Refresh token expired');
        return false;
      }

      AppLogger.info(
        '🔄 Refreshing token with refresh_token: ${refreshToken.substring(0, 10)}...',
      );

      // Call refresh token endpoint with FormData
      final formData = FormData({
        'grant_type': 'refresh_token',
        'refresh_token': refreshToken,
      });

      final response = await post(
        ApiConfig.login,
        formData,
        headers: {'Authorization': ApiConfig.authHeader},
      );

      if (response.statusCode == 200 && response.body != null) {
        final data = response.body;

        // Extract expiry times from response
        final expiresIn = data['expires_in'] ?? 3600; // Default 1 hour
        final refreshTokenExpiresIn =
            data['refreshToken_ExpireIn'] ?? 86400; // Default 24 hours

        // Save tokens with expiry info using TokenManager
        await TokenManager.saveTokens(
          accessToken: data['access_token'],
          refreshToken: data['refresh_token'],
          expiresIn: expiresIn,
          refreshTokenExpiresIn: refreshTokenExpiresIn,
        );

        AppLogger.info(
          '✅ Token refreshed successfully (expires in $expiresIn seconds)',
        );
        return true;
      } else {
        AppLogger.error('❌ Token refresh failed: ${response.statusCode}');
        return false;
      }
    } catch (e) {
      AppLogger.error('❌ Token refresh error: $e', e);
      return false;
    }
  }

  Future<void> _handleAuthFailure() async {
    AppLogger.warning('🚪 Handling auth failure - logging out');

    // Clear all tokens using TokenManager
    await TokenManager.clearTokens();

    // Clear user data
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('user_data');

    // Navigate to login screen
    Get.offAllNamed('/sign-in');
  }

  /// Clear all tokens (for logout)
  Future<void> clearTokens() async {
    await TokenManager.clearTokens();
  }
}
