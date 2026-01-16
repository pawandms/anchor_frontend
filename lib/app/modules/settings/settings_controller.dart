import 'package:get/get.dart';
import '../../routes/app_routes.dart';

class SettingsController extends GetxController {
  final notificationsEnabled = true.obs;

  void navigateToProfile() {
    Get.toNamed(AppRoutes.profile);
  }

  void toggleNotifications(bool value) {
    notificationsEnabled.value = value;
    Get.snackbar(
      'Settings',
      'Notifications ${value ? "enabled" : "disabled"}',
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  void logout() {
    Get.defaultDialog(
      title: 'Logout',
      middleText: 'Are you sure you want to logout?',
      textConfirm: 'Yes',
      textCancel: 'No',
      onConfirm: () {
        Get.back();
        Get.offAllNamed(AppRoutes.signIn);
        Get.snackbar('Success', 'Logged out successfully');
      },
    );
  }
}
