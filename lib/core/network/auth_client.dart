import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../constants/api_endpoints.dart';

class AuthClient extends GetConnect {
  // Environment Variables
  String get _protocol => dotenv.env['API_PROTOCOL'] ?? 'http';
  String get _host => dotenv.env['API_HOST'] ?? 'localhost';
  String get _port => dotenv.env['API_PORT'] ?? '8080';
  String get _clientId => dotenv.env['CLIENT_ID'] ?? '';
  String get _clientSecret => dotenv.env['CLIENT_SECRET'] ?? '';

  // Reactive Token for UI binding
  final RxnString accessToken = RxnString();

  @override
  void onInit() {
    httpClient.baseUrl = '$_protocol://$_host:$_port';
    httpClient.timeout = const Duration(seconds: 30);
    super.onInit();
    // Initialize token from storage
    SharedPreferences.getInstance().then((prefs) {
      accessToken.value = prefs.getString('access_token');
    });
  }

  // --- Core Request Wrapper ---
  Future<Response> authenticatedRequest(
    String method,
    String url, {
    dynamic body,
    Map<String, String>? headers,
    Map<String, dynamic>? query,
  }) async {
    final token = await getValidToken();
    if (token == null) {
      return const Response(statusCode: 401, statusText: 'Unauthorized');
    }

    final authHeaders = headers ?? {};
    authHeaders['Authorization'] = 'Bearer $token';

    return request(url, method, body: body, headers: authHeaders, query: query);
  }

  // --- Auth Actions ---

  Future<bool> login(String email, String password) async {
    final String basicAuth =
        'Basic ${base64Encode(utf8.encode('$_clientId:$_clientSecret'))}';

    // Using FormData as requested
    final formData = FormData({
      'grant_type': 'password',
      'username': email,
      'password': password,
    });

    try {
      final response = await post(
        ApiEndpoints.oauthToken,
        formData,
        headers: {'Authorization': basicAuth},
      );

      if (response.statusCode == 200) {
        final data = response.body;
        if (data is Map<String, dynamic>) {
          await _saveTokens(data);
        } else if (data is String) {
          await _saveTokens(jsonDecode(data));
        }
        return true;
      } else {
        debugPrint(
          'Login Failed: ${response.statusCode} - ${response.bodyString}',
        );
        return false;
      }
    } catch (e) {
      debugPrint('Login Error: $e');
      return false;
    }
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    accessToken.value = null;
    Get.offAllNamed('/login');
  }

  // --- Token Management ---

  Future<void> _saveTokens(Map<String, dynamic> data) async {
    final prefs = await SharedPreferences.getInstance();

    if (data['access_token'] != null) {
      final token = data['access_token'];
      await prefs.setString('access_token', token);
      accessToken.value = token; // Update reactive variable
    }
    if (data['refresh_token'] != null) {
      await prefs.setString('refresh_token', data['refresh_token']);
    }

    final int expiresIn = data['expires_in'] ?? 3600;
    final DateTime expiryDate = DateTime.now().add(
      Duration(seconds: expiresIn),
    );
    await prefs.setString('token_expiry', expiryDate.toIso8601String());

    // Basic User Info from Token Response (if any)
    if (data['username'] != null) {
      await prefs.setString('username', data['username']);
    }
    if (data['userID'] != null) {
      await prefs.setString('userID', data['userID'].toString());
    }
  }

  // getValidToken method needs to update accessToken if it refreshes
  Future<String?> getValidToken() async {
    final prefs = await SharedPreferences.getInstance();

    String? token = prefs.getString('access_token');
    if (token == null) {
      accessToken.value = null; // Sync
      return null;
    }

    String? expiryStr = prefs.getString('token_expiry');
    if (expiryStr != null) {
      DateTime expiryDate = DateTime.parse(expiryStr);
      // Refresh if expired or expiring in 5 mins
      if (DateTime.now().isAfter(
        expiryDate.subtract(const Duration(minutes: 5)),
      )) {
        debugPrint("Token expired, refreshing...");
        bool refreshed = await _refreshToken();
        if (refreshed) {
          final updatedPrefs = await SharedPreferences.getInstance();
          token = updatedPrefs.getString('access_token');
          accessToken.value = token; // Sync
        } else {
          await logout();
          return null;
        }
      }
    }
    // Ensure sync even if no refresh needed (e.g. initial load)
    if (accessToken.value != token) {
      accessToken.value = token;
    }
    return token;
  }

  Future<bool> _refreshToken() async {
    final prefs = await SharedPreferences.getInstance();
    String? refreshToken = prefs.getString('refresh_token');

    if (refreshToken == null) return false;

    final String basicAuth =
        'Basic ${base64Encode(utf8.encode('$_clientId:$_clientSecret'))}';

    final formData = FormData({
      'grant_type': 'refresh_token',
      'refresh_token': refreshToken,
    });

    try {
      final response = await post(
        ApiEndpoints.oauthToken,
        formData,
        headers: {'Authorization': basicAuth},
      );

      if (response.statusCode == 200) {
        final data = response.body;
        if (data is Map<String, dynamic>) {
          await _saveTokens(data);
        } else if (data is String) {
          await _saveTokens(jsonDecode(data));
        }
        return true;
      } else {
        return false;
      }
    } catch (e) {
      return false;
    }
  }
}
