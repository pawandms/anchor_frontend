import 'package:get/get.dart';
import '../../data/models/user_model.dart';

class ProfileController extends GetxController {
  final user = Rx<UserModel?>(null);

  @override
  void onInit() {
    super.onInit();
    loadProfile();
  }

  void loadProfile() {
    // Load user profile
    user.value = UserModel(
      id: 'currentUser',
      name: 'John Doe',
      email: 'john@example.com',
      phoneNumber: '+1234567890',
      about: 'Flutter Developer 💙',
      isOnline: true,
    );
  }

  void editProfile() {
    Get.snackbar('Info', 'Edit profile feature coming soon');
  }
}
