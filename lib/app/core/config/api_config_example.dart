import 'package:flutter_demo_1/app/core/config/api_config.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

// Example: Login Request
Future<void> loginExample() async {
  try {
    final response = await http.post(
      Uri.parse(ApiConfig.loginUrl),
      headers: ApiConfig.headers,
      body: jsonEncode({
        'username': 'user@example.com',
        'password': 'password123',
        'grant_type': 'password',
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      print('Login successful: $data');
    } else {
      print('Login failed: ${response.statusCode}');
    }
  } catch (e) {
    print('Error: $e');
  }
}

// Example: Register Request
Future<void> registerExample() async {
  try {
    final response = await http.post(
      Uri.parse(ApiConfig.registerUrl),
      headers: ApiConfig.headersWithoutAuth,
      body: jsonEncode({
        'name': 'John Doe',
        'email': 'john@example.com',
        'password': 'password123',
      }),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      final data = jsonDecode(response.body);
      print('Registration successful: $data');
    } else {
      print('Registration failed: ${response.statusCode}');
    }
  } catch (e) {
    print('Error: $e');
  }
}

// Example: Accessing Config Values
void printConfig() {
  print('Base URL: ${ApiConfig.baseUrl}');
  print('Register URL: ${ApiConfig.registerUrl}');
  print('Login URL: ${ApiConfig.loginUrl}');
  print('Auth Header: ${ApiConfig.authHeader}');
}
