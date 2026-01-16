import 'package:get/get.dart';
import '../../data/models/user_model.dart';
import '../../routes/app_routes.dart';

class ContactsController extends GetxController {
  final contacts = <UserModel>[].obs;
  final isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    loadContacts();
  }

  Future<void> loadContacts() async {
    try {
      isLoading.value = true;
      await Future.delayed(const Duration(seconds: 1));
      contacts.value = _getDummyContacts();
    } finally {
      isLoading.value = false;
    }
  }

  void openChat(UserModel contact) {
    Get.snackbar('Info', 'Opening chat with ${contact.name}');
  }

  void createGroup() {
    Get.toNamed(AppRoutes.createGroup);
  }

  List<UserModel> _getDummyContacts() {
    return [
      UserModel(
        id: '1',
        name: 'Alice Johnson',
        email: 'alice@example.com',
        phoneNumber: '+1234567890',
        isOnline: true,
      ),
      UserModel(
        id: '2',
        name: 'Bob Smith',
        email: 'bob@example.com',
        phoneNumber: '+1234567891',
        isOnline: false,
      ),
      UserModel(
        id: '3',
        name: 'Charlie Brown',
        email: 'charlie@example.com',
        phoneNumber: '+1234567892',
        isOnline: true,
      ),
    ];
  }
}
