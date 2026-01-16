import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/values/app_colors.dart';
import '../../core/values/app_strings.dart';
import '../../core/values/app_values.dart';
import 'profile_controller.dart';

class ProfileView extends GetView<ProfileController> {
  const ProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.profile),
        actions: [
          TextButton(
            onPressed: controller.editProfile,
            child: const Text('EDIT'),
          ),
        ],
      ),
      body: Obx(() {
        final user = controller.user.value;
        if (user == null) {
          return const Center(child: CircularProgressIndicator());
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.all(AppValues.paddingL),
          child: Column(
            children: [
              // Profile Picture
              Stack(
                children: [
                  CircleAvatar(
                    radius: 60,
                    backgroundColor: AppColors.primary,
                    child: Text(
                      user.name.substring(0, 1).toUpperCase(),
                      style: const TextStyle(
                        fontSize: 48,
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 3),
                      ),
                      child: const Icon(
                        Icons.camera_alt,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppValues.paddingL),

              // Name
              Text(
                user.name,
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: AppValues.paddingS),
              Text(
                user.isOnline ? AppStrings.online : AppStrings.offline,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: user.isOnline ? AppColors.online : AppColors.textHint,
                ),
              ),
              const SizedBox(height: AppValues.paddingXL),

              // Profile Info
              _buildInfoCard(
                context,
                icon: Icons.email_outlined,
                title: AppStrings.email,
                value: user.email,
              ),
              const SizedBox(height: AppValues.paddingM),
              _buildInfoCard(
                context,
                icon: Icons.phone_outlined,
                title: AppStrings.phoneNumber,
                value: user.phoneNumber ?? 'Not set',
              ),
              const SizedBox(height: AppValues.paddingM),
              _buildInfoCard(
                context,
                icon: Icons.info_outline,
                title: AppStrings.about,
                value: user.about ?? 'Hey there! I\'m using Anchor',
              ),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildInfoCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String value,
  }) {
    return Container(
      padding: const EdgeInsets.all(AppValues.paddingM),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(AppValues.radiusM),
      ),
      child: Row(
        children: [
          Icon(icon, color: AppColors.primary),
          const SizedBox(width: AppValues.paddingM),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(value, style: Theme.of(context).textTheme.bodyLarge),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
