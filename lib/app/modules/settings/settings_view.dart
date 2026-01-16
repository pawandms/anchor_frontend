import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/values/app_colors.dart';
import '../../core/values/app_strings.dart';
import '../../core/values/app_values.dart';
import 'settings_controller.dart';

class SettingsView extends GetView<SettingsController> {
  const SettingsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.settings),
      ),
      body: ListView(
        children: [
          // Profile Section
          ListTile(
            leading: CircleAvatar(
              radius: 28,
              backgroundColor: AppColors.primary,
              child: const Icon(Icons.person, color: Colors.white, size: 32),
            ),
            title: const Text('John Doe'),
            subtitle: const Text('john@example.com'),
            trailing: const Icon(Icons.chevron_right),
            onTap: controller.navigateToProfile,
            contentPadding: const EdgeInsets.all(AppValues.paddingM),
          ),
          const Divider(),
          
          // Settings Options
          _buildSettingsTile(
            context,
            icon: Icons.notifications_outlined,
            title: AppStrings.notifications,
            trailing: Obx(() => Switch(
              value: controller.notificationsEnabled.value,
              onChanged: controller.toggleNotifications,
              activeColor: AppColors.primary,
            )),
          ),
          _buildSettingsTile(
            context,
            icon: Icons.lock_outline,
            title: AppStrings.privacy,
            onTap: () => Get.snackbar('Info', 'Privacy settings coming soon'),
          ),
          _buildSettingsTile(
            context,
            icon: Icons.security_outlined,
            title: AppStrings.security,
            onTap: () => Get.snackbar('Info', 'Security settings coming soon'),
          ),
          _buildSettingsTile(
            context,
            icon: Icons.help_outline,
            title: AppStrings.help,
            onTap: () => Get.snackbar('Info', 'Help center coming soon'),
          ),
          _buildSettingsTile(
            context,
            icon: Icons.description_outlined,
            title: AppStrings.terms,
            onTap: () => Get.snackbar('Info', 'Terms & Conditions coming soon'),
          ),
          const Divider(),
          _buildSettingsTile(
            context,
            icon: Icons.logout,
            title: AppStrings.logout,
            iconColor: AppColors.error,
            titleColor: AppColors.error,
            onTap: controller.logout,
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    Color? iconColor,
    Color? titleColor,
    Widget? trailing,
    VoidCallback? onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: iconColor ?? AppColors.iconPrimary),
      title: Text(
        title,
        style: TextStyle(color: titleColor),
      ),
      trailing: trailing ?? const Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }
}
