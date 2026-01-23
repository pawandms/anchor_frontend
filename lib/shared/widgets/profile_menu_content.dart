import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../features/auth/auth_controller.dart';
import '../../features/profile/screens/change_language_screen.dart';
import '../../core/constants/api_endpoints.dart';
import '../../core/network/auth_client.dart';
import '../../core/enums/user_presence_status.dart';
import 'user_avatar.dart';

class ProfileMenuContent extends StatelessWidget {
  final VoidCallback? onClose; // Callback to close drawer/deck
  final List<Widget>? footerItems; // Extra items at the bottom
  final bool useSpacer; // Use spacer to push items to bottom (for desktop)

  const ProfileMenuContent({
    super.key,
    this.onClose,
    this.footerItems,
    this.useSpacer = false,
  });

  @override
  Widget build(BuildContext context) {
    final AuthController authController = Get.find<AuthController>();

    return Column(
      children: [
        if (useSpacer) const SizedBox(height: 40),

        // User Info Section
        Obx(() {
          final user = authController.currentUser.value;
          final token = Get.find<AuthClient>().accessToken.value;

          return Container(
            padding:
                useSpacer ? null : const EdgeInsets.symmetric(vertical: 40),
            color: useSpacer ? null : Theme.of(context).cardColor,
            child: Column(
              children: [
                UserAvatar(
                  profileImageUrl: user?.profileImageMediaId != null
                      ? ApiEndpoints.makeProfileImageUrl(
                          user!.profileImageMediaId!,
                        )
                      : null,
                  authToken: token,
                  initials: user?.initials ?? '?',
                  radius: 40,
                  backgroundColor: Colors.deepPurpleAccent,
                  textStyle: const TextStyle(
                    fontSize: 24,
                    color: Colors.white,
                  ),
                  status: UserPresenceStatus.available,
                  allowUpload: true,
                  userId: user?.id,
                ),
                const SizedBox(height: 16),
                Text(
                  user?.fullName ?? 'loading'.tr,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  user?.email ?? '',
                  style: const TextStyle(color: Colors.grey),
                ),
              ],
            ),
          );
        }),

        if (useSpacer) const SizedBox(height: 40),

        // Menu Items
        ListTile(
          leading: const Icon(Icons.settings),
          title: Text('profile_settings'.tr),
          onTap: () {
            // Navigate to settings
            onClose?.call();
          },
        ),
        ListTile(
          leading: const Icon(Icons.language),
          title: Text('change_language'.tr),
          onTap: () {
            onClose?.call();
            Get.to(() => const ChangeLanguageScreen());
          },
        ),
        ListTile(
          leading: const Icon(Icons.brightness_6),
          title: Text('toggle_theme'.tr),
          onTap: () {
            onClose?.call();
            if (Get.isDarkMode) {
              Get.changeThemeMode(ThemeMode.light);
            } else {
              Get.changeThemeMode(ThemeMode.dark);
            }
          },
        ),

        if (useSpacer) const Spacer() else const Divider(),

        ListTile(
          leading: const Icon(Icons.logout, color: Colors.red),
          title: Text(
            'profile_logout'.tr,
            style: const TextStyle(color: Colors.red),
          ),
          onTap: () {
            onClose?.call();
            authController.logout();
          },
        ),

        if (footerItems != null) ...footerItems!,

        if (useSpacer) const SizedBox(height: 20),
      ],
    );
  }
}
