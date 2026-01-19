import 'package:get/get.dart';
import '../network/auth_client.dart';

class AuthService extends GetxService {
  final AuthClient _authClient = Get.find<AuthClient>();

  Future<bool> login(String email, String password) =>
      _authClient.login(email, password);

  Future<void> logout() => _authClient.logout();

  Future<String?> getValidToken() => _authClient.getValidToken();
}
