import 'package:flutter_dotenv/flutter_dotenv.dart';

class ApiEndpoints {
  static String get _baseUrl {
    final protocol = dotenv.env['API_PROTOCOL'] ?? 'http';
    final host = dotenv.env['API_HOST'] ?? 'localhost';
    final port = dotenv.env['API_PORT'] ?? '8080';
    return '$protocol://$host:$port';
  }

  // Auth
  static const String oauthToken = '/oauth2/token';
  static const String signup = '/api/v1/public/signup';

  // Users
  static String userProfile(String userId) => '/api/v1/users/$userId/profile';

  // Media
  static String profileImage(String mediaId) =>
      '/api/v1/media/profile/$mediaId';

  static String makeProfileImageUrl(String mediaId) =>
      '$_baseUrl${profileImage(mediaId)}';

  static String uploadProfileImage(String userId) =>
      '/api/v1/users/$userId/media/profile-image';

  static String updateUserInfo(String userId) =>
      '/api/v1/users/$userId/user-info';
}
