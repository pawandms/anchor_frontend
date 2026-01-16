import 'package:flutter_dotenv/flutter_dotenv.dart';

class ApiConfig {
  // Base URL
  static String get baseUrl =>
      dotenv.env['BASE_URL'] ?? 'http://msgapp.local:8080';

  // Authentication Header
  static String get authHeader =>
      dotenv.env['AUTH_HEADER'] ?? 'Basic R2VuZXJhbDpHZW5lcmFs';

  // Endpoint paths constants
  static const String registerPath = 'api/v1/public/signup';
  static const String loginPath = '/oauth2/token';
  static const String oauthTokenPath = '/oauth2/token';
  static const String publicPath = '/public/';

  // API Endpoints
  static String get register => dotenv.env['REGISTER_ENDPOINT'] ?? registerPath;
  static String get login => dotenv.env['LOGIN_ENDPOINT'] ?? loginPath;

  // Full URLs
  static String get registerUrl => '$baseUrl$register';
  static String get loginUrl => '$baseUrl$login';

  // Request Headers
  static Map<String, String> get headers => {
    'Content-Type': 'application/json',
    'Authorization': authHeader,
  };

  // Request Headers without Auth
  static Map<String, String> get headersWithoutAuth => {
    'Content-Type': 'application/json',
  };
}
