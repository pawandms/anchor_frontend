import 'package:flutter_demo_1/app/data/providers/auth_api_service.dart';
import 'package:flutter_demo_1/app/data/repositories/auth_repository.dart';
import 'package:flutter_demo_1/app/data/providers/auth_interceptor.dart';

/// Example: How to use the GetX HTTP Client with Token Interceptor

void main() async {
  // Initialize API Client (automatically handles token interceptor)
  final apiClient = ApiClient.instance;

  print('✅ API Client initialized with token interceptor');
  print('🔐 Automatic token refresh on 401 responses');
  print('📤 All requests automatically include Bearer token');
}

// Example 1: Login with OAuth
Future<void> exampleLogin() async {
  final authRepo = AuthRepository();

  final result = await authRepo.login(
    email: 'user1@anchor.com',
    password: 'Mumbai@123',
  );

  if (result != null) {
    print('✅ Login successful');
    print('Access Token: ${result['access_token']}');
    print('Refresh Token: ${result['refresh_token']}');
    print('Token Type: ${result['token_type']}');
    print('Expires In: ${result['expires_in']} seconds');
  }
}

// Example 2: Sign Up
Future<void> exampleSignUp() async {
  final authRepo = AuthRepository();

  final result = await authRepo.signUp(
    email: 'newuser@anchor.com',
    password: 'Mumbai@123',
    firstName: 'John',
    lastName: 'Doe',
    gender: 'Male',
    profileType: 'Private',
  );

  if (result != null) {
    print('✅ Signup successful');
  }
}

// Example 3: Manual Token Refresh (usually automatic)
Future<void> exampleRefreshToken() async {
  final authApi = AuthApiService();
  final apiClient = ApiClient.instance;

  // Get current refresh token
  final refreshToken = 'your-refresh-token-here';

  final response = await authApi.refreshToken(refreshToken);

  if (response.statusCode == 200) {
    print('✅ Token refreshed');
  }
}

// Example 4: Logout
Future<void> exampleLogout() async {
  final authRepo = AuthRepository();

  await authRepo.logout();
  print('✅ Logged out successfully');
}

// Example 5: Make Authenticated Request (token added automatically)
Future<void> exampleAuthenticatedRequest() async {
  final apiClient = ApiClient.instance;

  // Token will be automatically added to this request
  final response = await apiClient.get('/api/user/profile');

  if (response.statusCode == 200) {
    print('✅ Profile data: ${response.body}');
  }
}

/// How it works:
/// 
/// 1. LOGIN:
///    - User enters credentials
///    - POST /oauth/token with grant_type=password
///    - Response contains access_token and refresh_token
///    - Tokens saved to SharedPreferences
/// 
/// 2. AUTHENTICATED REQUESTS:
///    - All requests automatically get Bearer token in header
///    - Interceptor adds: Authorization: Bearer {access_token}
/// 
/// 3. TOKEN EXPIRY (401 Response):
///    - Interceptor detects 401 status
///    - Automatically calls POST /oauth/token with grant_type=refresh_token
///    - New tokens saved
///    - Original request retried with new token
///    - User doesn't notice anything!
/// 
/// 4. REFRESH FAILURE:
///    - If refresh token also expired
///    - User logged out automatically
///    - Redirected to login screen
