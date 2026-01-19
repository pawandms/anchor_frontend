import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import '../../core/enums/user_presence_status.dart';
import '../../features/auth/auth_controller.dart';
import '../../core/services/user_service.dart';
import '../../core/constants/api_endpoints.dart';

class UserAvatar extends StatelessWidget {
  final String? profileImageUrl;
  final String? authToken;
  final String initials;
  final UserPresenceStatus status;
  final double radius;
  final Color? backgroundColor;
  final TextStyle? textStyle;
  final bool allowUpload;
  final String? userId; // Required if allowUpload is true

  // Static tick to synchronize all UserAvatar instances for the current user
  static RxInt profileRefreshTick = 0.obs;

  const UserAvatar({
    super.key,
    this.profileImageUrl,
    this.authToken,
    required this.initials,
    this.status = UserPresenceStatus.offline,
    this.radius = 20,
    this.backgroundColor,
    this.textStyle,
    this.allowUpload = false,
    this.userId,
  });

  Future<void> _handleUpload(BuildContext context) async {
    if (userId == null) return;

    debugPrint('UserAvatar: Opening Image Picker...');
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      debugPrint('UserAvatar: Image picked: ${image.path}');
      debugPrint('UserAvatar: Calling UserService.uploadProfileImage...');

      // Call API directly from Widget as requested
      final userService = Get.find<UserService>();
      final String? mediaId = await userService.uploadProfileImage(
        userId!,
        image,
      );

      if (mediaId != null) {
        // Evict from cache to ensure visual update even if URL is identical
        try {
          if (profileImageUrl != null) {
            await NetworkImage(
              profileImageUrl!,
              headers: authToken != null
                  ? {'Authorization': 'Bearer $authToken'}
                  : null,
            ).evict();
          }
          await NetworkImage(
            ApiEndpoints.makeProfileImageUrl(mediaId),
            headers: authToken != null
                ? {'Authorization': 'Bearer $authToken'}
                : null,
          ).evict();
        } catch (e) {
          debugPrint('Cache eviction error: $e');
        }

        // Update Global State triggers parent rebuild
        if (Get.isRegistered<AuthController>()) {
          final authController = Get.find<AuthController>();
          authController.updateProfileImage(mediaId);
          // Increment tick to force refresh on all avatars
          profileRefreshTick.value++;
        }

        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Profile picture updated!')),
          );
        }
      } else {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Failed to upload profile picture.')),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        _buildAvatar(),
        // Camera/Upload Icon (Visible only if allowUpload is true)
        if (allowUpload)
          Positioned(
            bottom: 0,
            right: 0,
            child: InkWell(
              onTap: () => _handleUpload(context),
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Theme.of(context).cardColor,
                    width: 2,
                  ),
                ),
                child: const Icon(
                  Icons.camera_alt,
                  size: 14,
                  color: Colors.white,
                ),
              ),
            ),
          )
        else
          Positioned(
            bottom: 0,
            right: 0,
            child: Container(
              width: radius * 0.6,
              height: radius * 0.6,
              decoration: BoxDecoration(
                color: _getStatusColor(status),
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 2),
              ),
            ),
          ),
      ],
    );
  }

  Color _getStatusColor(UserPresenceStatus status) {
    switch (status) {
      case UserPresenceStatus.available:
        return Colors.green;
      case UserPresenceStatus.away:
        return Colors.amber;
      case UserPresenceStatus.busy:
        return Colors.red;
      case UserPresenceStatus.offline:
        return Colors.grey;
    }
  }

  Widget _buildAvatar() {
    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        // Outer shadow for depth (Drop Shadow)
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(3, 3), // Bottom-right shadow
          ),
          BoxShadow(
            color: Colors.white.withOpacity(0.5),
            blurRadius: 8,
            offset: const Offset(-2, -2), // Top-left highlight (Emboss effect)
          ),
        ],
        // Gradient Border
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Colors.grey.shade200, Colors.grey.shade400],
        ),
      ),
      padding: const EdgeInsets.all(3.0), // Border thickness
      child: Container(
        decoration: const BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.white, // Gap between border and image
        ),
        padding: const EdgeInsets.all(2.0), // White ring inside border
        child: _buildInnerCircle(),
      ),
    );
  }

  Widget _buildInnerCircle() {
    return Obx(() {
      String? currentUrl = profileImageUrl;

      // Reactive update: Check if this avatar belongs to the current user
      if (userId != null && Get.isRegistered<AuthController>()) {
        final authController = Get.find<AuthController>();
        final currentUser = authController.currentUser.value;
        if (currentUser != null && currentUser.id == userId) {
          final mediaId = currentUser.profileImageMediaId;
          // Subscribe to static tick to force update
          final int tick = profileRefreshTick.value;
          if (mediaId != null) {
            currentUrl = '${ApiEndpoints.makeProfileImageUrl(mediaId)}?v=$tick';
          }
        }
      }

      if (currentUrl != null && currentUrl!.isNotEmpty) {
        return ClipOval(
          child: Container(
            width: radius * 2,
            height: radius * 2,
            color: backgroundColor ?? Colors.grey.shade300,
            child: Image.network(
              currentUrl!,
              headers: authToken != null
                  ? {'Authorization': 'Bearer $authToken'}
                  : null,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                debugPrint(
                    'UserAvatar: Image Load Error for URL $currentUrl: $error');
                return _buildInitialsAvatar();
              },
              loadingBuilder: (context, child, loadingProgress) {
                if (loadingProgress == null) return child;
                return _buildInitialsAvatar(); // Show initials while loading
              },
            ),
          ),
        );
      }
      return _buildInitialsAvatar();
    });
  }

  Widget _buildInitialsAvatar() {
    return Container(
      width: radius * 2,
      height: radius * 2,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            backgroundColor ?? Colors.deepPurpleAccent,
            (backgroundColor ?? Colors.deepPurpleAccent).withOpacity(0.7),
          ],
        ),
      ),
      alignment: Alignment.center,
      child: Text(
        initials,
        style: textStyle ??
            const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              shadows: [
                Shadow(
                  offset: Offset(1, 1),
                  blurRadius: 2,
                  color: Colors.black26,
                ),
              ],
            ),
      ),
    );
  }
}
