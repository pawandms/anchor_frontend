// import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import '../network/auth_client.dart';
import '../constants/api_endpoints.dart';

class UserService extends GetxService {
  final AuthClient _authClient = Get.find<AuthClient>();

  Future<Map<String, dynamic>?> getUserProfile(String userId) async {
    try {
      final response = await _authClient.authenticatedRequest(
        'GET',
        ApiEndpoints.userProfile(userId),
      );

      if (response.statusCode == 200) {
        final data = response.body;
        debugPrint('UserService: Received User Profile: $data');
        if (data is Map<String, dynamic>) {
          return data;
        }
        return data; // Should probably ensure map
      } else {
        debugPrint(
          'Get Profile Failed: ${response.statusCode} - ${response.bodyString}',
        );
      }
    } catch (e) {
      debugPrint('Get Profile Error: $e');
    }
    return null;
  }

  Future<String?> uploadProfileImage(String userId, XFile imageFile) async {
    final url = ApiEndpoints.uploadProfileImage(userId);
    debugPrint('UserService: Uploading image to $url');

    debugPrint('UserService: Reading file bytes...');
    List<int> bytes;
    try {
      bytes = await imageFile.readAsBytes();
      debugPrint('UserService: File size: ${bytes.length / 1024} KB');
    } catch (e) {
      debugPrint('UserService: Error reading bytes: $e');
      return null;
    }

    final form = FormData({
      'file': MultipartFile(bytes, filename: 'profile_image.jpg'),
    });
    debugPrint('UserService: FormData created. Sending request...');

    try {
      final response = await _authClient.authenticatedRequest(
        'POST',
        url,
        body: form,
      );
      debugPrint('UserService: Request returned.');

      debugPrint(
          'UserService: Upload Response: ${response.statusCode} ${response.bodyString}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = response.body;
        if (data is Map<String, dynamic>) {
          // Handle different potential keys for success
          final isValid = data['valid'] == true || data['success'] == true;
          if (isValid) {
            return data['mediaId'] ?? data['id'];
          }
        }
        return null;
      } else {
        debugPrint(
          'Upload Failed: ${response.statusCode} - ${response.bodyString}',
        );
        return null;
      }
    } catch (e) {
      debugPrint('Upload Error: $e');
      return null;
    }
  }
}
