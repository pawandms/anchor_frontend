import 'package:get/get.dart';
import '../../routes/app_routes.dart';

class SplashController extends GetxController {
  @override
  void onInit() {
    super.onInit();
    _navigateToNext();
  }

  Future<void> _navigateToNext() async {
    await Future.delayed(const Duration(seconds: 3));
    
    // Navigate to sign in screen
    // TODO: Check if user is logged in from shared preferences
    // and navigate to home if logged in
    Get.offAllNamed(AppRoutes.signIn);
  }
}
