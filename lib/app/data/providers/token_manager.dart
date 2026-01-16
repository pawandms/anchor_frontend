import 'package:shared_preferences/shared_preferences.dart';
import '../../core/utils/app_logger.dart';

class TokenManager {
  static const String _accessTokenKey = 'access_token';
  static const String _refreshTokenKey = 'refresh_token';
  static const String _accessTokenExpiryKey = 'access_token_expiry';
  static const String _refreshTokenExpiryKey = 'refresh_token_expiry';

  /// Save tokens with expiry times
  static Future<void> saveTokens({
    required String accessToken,
    required String refreshToken,
    required int expiresIn, // seconds
    required int refreshTokenExpiresIn, // seconds
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final now = DateTime.now();

    // Calculate expiry timestamps
    final accessTokenExpiry = now.add(Duration(seconds: expiresIn));
    final refreshTokenExpiry = now.add(
      Duration(seconds: refreshTokenExpiresIn),
    );

    // Save tokens and expiry times
    await prefs.setString(_accessTokenKey, accessToken);
    await prefs.setString(_refreshTokenKey, refreshToken);
    await prefs.setInt(
      _accessTokenExpiryKey,
      accessTokenExpiry.millisecondsSinceEpoch,
    );
    await prefs.setInt(
      _refreshTokenExpiryKey,
      refreshTokenExpiry.millisecondsSinceEpoch,
    );

    AppLogger.debug('💾 Tokens saved:');
    AppLogger.debug('   Access token expires: $accessTokenExpiry');
    AppLogger.debug('   Refresh token expires: $refreshTokenExpiry');
  }

  /// Get access token
  static Future<String?> getAccessToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_accessTokenKey);
  }

  /// Get refresh token
  static Future<String?> getRefreshToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_refreshTokenKey);
  }

  /// Check if access token is expired or will expire soon
  static Future<bool> isAccessTokenExpired({int bufferSeconds = 60}) async {
    final prefs = await SharedPreferences.getInstance();
    final expiryTimestamp = prefs.getInt(_accessTokenExpiryKey);

    if (expiryTimestamp == null) {
      return true; // No expiry info, assume expired
    }

    final expiryTime = DateTime.fromMillisecondsSinceEpoch(expiryTimestamp);
    final now = DateTime.now();
    final bufferTime = now.add(Duration(seconds: bufferSeconds));

    // Check if expired or will expire within buffer time
    final isExpired = bufferTime.isAfter(expiryTime);

    if (isExpired) {
      AppLogger.debug('⏰ Access token expired or expiring soon');
      AppLogger.debug('   Expiry: $expiryTime');
      AppLogger.debug('   Now: $now');
    }

    return isExpired;
  }

  /// Check if refresh token is expired
  static Future<bool> isRefreshTokenExpired() async {
    final prefs = await SharedPreferences.getInstance();
    final expiryTimestamp = prefs.getInt(_refreshTokenExpiryKey);

    if (expiryTimestamp == null) {
      return true; // No expiry info, assume expired
    }

    final expiryTime = DateTime.fromMillisecondsSinceEpoch(expiryTimestamp);
    final now = DateTime.now();

    final isExpired = now.isAfter(expiryTime);

    if (isExpired) {
      AppLogger.debug('⏰ Refresh token expired');
      AppLogger.debug('   Expiry: $expiryTime');
      AppLogger.debug('   Now: $now');
    }

    return isExpired;
  }

  /// Get remaining time until access token expires (in seconds)
  static Future<int> getAccessTokenRemainingTime() async {
    final prefs = await SharedPreferences.getInstance();
    final expiryTimestamp = prefs.getInt(_accessTokenExpiryKey);

    if (expiryTimestamp == null) {
      return 0;
    }

    final expiryTime = DateTime.fromMillisecondsSinceEpoch(expiryTimestamp);
    final now = DateTime.now();
    final difference = expiryTime.difference(now);

    return difference.inSeconds > 0 ? difference.inSeconds : 0;
  }

  /// Get remaining time until refresh token expires (in seconds)
  static Future<int> getRefreshTokenRemainingTime() async {
    final prefs = await SharedPreferences.getInstance();
    final expiryTimestamp = prefs.getInt(_refreshTokenExpiryKey);

    if (expiryTimestamp == null) {
      return 0;
    }

    final expiryTime = DateTime.fromMillisecondsSinceEpoch(expiryTimestamp);
    final now = DateTime.now();
    final difference = expiryTime.difference(now);

    return difference.inSeconds > 0 ? difference.inSeconds : 0;
  }

  /// Check if we have valid tokens
  static Future<bool> hasValidTokens() async {
    final accessToken = await getAccessToken();
    final refreshToken = await getRefreshToken();

    if (accessToken == null || refreshToken == null) {
      return false;
    }

    // Check if refresh token is still valid
    final refreshExpired = await isRefreshTokenExpired();
    return !refreshExpired;
  }

  /// Clear all tokens
  static Future<void> clearTokens() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_accessTokenKey);
    await prefs.remove(_refreshTokenKey);
    await prefs.remove(_accessTokenExpiryKey);
    await prefs.remove(_refreshTokenExpiryKey);
    print('🗑️ All tokens cleared');
  }

  /// Get token info for debugging
  static Future<Map<String, dynamic>> getTokenInfo() async {
    final accessToken = await getAccessToken();
    final refreshToken = await getRefreshToken();
    final accessRemaining = await getAccessTokenRemainingTime();
    final refreshRemaining = await getRefreshTokenRemainingTime();
    final accessExpired = await isAccessTokenExpired();
    final refreshExpired = await isRefreshTokenExpired();

    return {
      'has_access_token': accessToken != null,
      'has_refresh_token': refreshToken != null,
      'access_token_remaining_seconds': accessRemaining,
      'refresh_token_remaining_seconds': refreshRemaining,
      'access_token_expired': accessExpired,
      'refresh_token_expired': refreshExpired,
    };
  }
}
