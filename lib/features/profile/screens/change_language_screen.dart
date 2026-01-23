import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../auth/auth_controller.dart';
import '../../../core/enums/user_language_type.dart';

class ChangeLanguageScreen extends StatelessWidget {
  const ChangeLanguageScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final AuthController authController = Get.find<AuthController>();

    return Scaffold(
      appBar: AppBar(
        title: Text('change_language'.tr),
      ),
      body: Obx(() {
        final currentLanguage =
            authController.currentUser.value?.userLanguage ??
                UserLanguageType.english;

        return ListView.builder(
          itemCount: UserLanguageType.values.length,
          itemBuilder: (context, index) {
            final language = UserLanguageType.values[index];
            final isSelected = currentLanguage == language;

            return ListTile(
              title: Text(language.value),
              trailing: isSelected
                  ? const Icon(Icons.check, color: Colors.deepPurpleAccent)
                  : null,
              onTap: () {
                authController.updateUserLanguage(language);
              },
            );
          },
        );
      }),
    );
  }
}
