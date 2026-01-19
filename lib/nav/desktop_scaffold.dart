import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../features/activity/activity_screen.dart';
import '../features/chat/chat_list_screen.dart';
import '../features/channels/video_channels_screen.dart';
import '../features/reels/reels_feed_screen.dart';
import 'nav_controller.dart';
import '../features/auth/auth_controller.dart';
import '../../shared/widgets/user_avatar.dart';
import '../../core/constants/api_endpoints.dart';
import '../../core/network/auth_client.dart';
import '../../core/enums/user_presence_status.dart';

class DesktopScaffold extends StatelessWidget {
  const DesktopScaffold({super.key});

  @override
  Widget build(BuildContext context) {
    final NavController navController = Get.find();
    final AuthController authController = Get.find();

    final List<Widget> screens = const [
      ActivityScreen(),
      ChatListScreen(),
      VideoChannelsScreen(),
      ReelsFeedScreen(),
    ];

    return Scaffold(
      body: Stack(
        children: [
          Row(
            children: [
              // 1. Sidebar Rail
              Container(
                width: 72,
                color: Theme.of(
                  context,
                ).bottomNavigationBarTheme.backgroundColor,
                child: Column(
                  children: [
                    const SizedBox(height: 20),
                    // User Avatar (Profile Trigger)
                    InkWell(
                      onTap: navController.toggleDeck,
                      child: Obx(() {
                        final user = authController.currentUser.value;
                        final token = Get.find<AuthClient>().accessToken.value;
                        return UserAvatar(
                          profileImageUrl: user?.profileImageMediaId != null
                              ? ApiEndpoints.makeProfileImageUrl(
                                  user!.profileImageMediaId!,
                                )
                              : null,
                          authToken: token,
                          initials: user?.initials ?? '?',
                          radius: 20,
                          backgroundColor: Colors.deepPurpleAccent,
                          textStyle: const TextStyle(color: Colors.white),
                          status: UserPresenceStatus.available,
                          userId: user?.id,
                        );
                      }),
                    ),
                    const SizedBox(height: 40),
                    Obx(
                      () => _NavItem(
                        icon: Icons.home,
                        label: 'nav_home'.tr,
                        isSelected: navController.selectedIndex.value == 0,
                        onTap: () => navController.changeTab(0),
                      ),
                    ),
                    Obx(
                      () => _NavItem(
                        icon: Icons.chat_bubble,
                        label: 'nav_chat'.tr,
                        isSelected: navController.selectedIndex.value == 1,
                        onTap: () => navController.changeTab(1),
                      ),
                    ),
                    Obx(
                      () => _NavItem(
                        icon: Icons.tv,
                        label: 'nav_channels'.tr,
                        isSelected: navController.selectedIndex.value == 2,
                        onTap: () => navController.changeTab(2),
                      ),
                    ),
                    Obx(
                      () => _NavItem(
                        icon: Icons.play_circle_fill,
                        label: 'nav_reels'.tr,
                        isSelected: navController.selectedIndex.value == 3,
                        onTap: () => navController.changeTab(3),
                      ),
                    ),
                  ],
                ),
              ),
              // 2. Main Content
              Expanded(
                child: Obx(() => screens[navController.selectedIndex.value]),
              ),
            ],
          ),

          // 3. Overlay Barrier
          Obx(
            () => navController.isProfileDeckOpen.value
                ? Positioned.fill(
                    child: GestureDetector(
                      onTap: navController.toggleDeck,
                      child: Container(
                        color: Colors.black12, // Subtle overlay
                      ),
                    ),
                  )
                : const SizedBox.shrink(),
          ),

          // 4. Profile Deck Overlay
          Obx(
            () => AnimatedPositioned(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              left: navController.isProfileDeckOpen.value ? 0 : -300,
              top: 0,
              bottom: 0,
              width: 300,
              child: Container(
                color: Theme.of(context).cardColor,
                child: Column(
                  children: [
                    const SizedBox(height: 40),
                    // User Avatar (Large)
                    Obx(() {
                      final user = authController.currentUser.value;
                      final token = Get.find<AuthClient>().accessToken.value;
                      return UserAvatar(
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
                      );
                    }),
                    const SizedBox(height: 16),
                    // User Name
                    Obx(() {
                      final user = authController.currentUser.value;
                      return Text(
                        user?.fullName ?? 'Loading...',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      );
                    }),
                    // Email / Role
                    Obx(() {
                      final user = authController.currentUser.value;
                      return Text(
                        user?.email ?? '',
                        style: const TextStyle(color: Colors.grey),
                      );
                    }),
                    const SizedBox(height: 40),
                    ListTile(
                      leading: const Icon(Icons.settings),
                      title: Text('profile_settings'.tr),
                      onTap: () {},
                    ),
                    ListTile(
                      leading: const Icon(Icons.language),
                      title: const Text('Change Language'),
                      onTap: () {
                        var locale = Get.locale?.languageCode == 'en'
                            ? const Locale('hi', 'IN')
                            : const Locale('en', 'US');
                        Get.updateLocale(locale);
                      },
                    ),
                    ListTile(
                      leading: const Icon(Icons.brightness_6),
                      title: const Text('Toggle Theme'),
                      onTap: () {
                        if (Get.isDarkMode) {
                          Get.changeThemeMode(ThemeMode.light);
                        } else {
                          Get.changeThemeMode(ThemeMode.dark);
                        }
                      },
                    ),
                    const Spacer(),
                    ListTile(
                      leading: const Icon(Icons.logout, color: Colors.red),
                      title: Text(
                        'profile_logout'.tr,
                        style: const TextStyle(color: Colors.red),
                      ),
                      onTap: authController.logout,
                    ),
                    ListTile(
                      leading: const Icon(Icons.close),
                      title: const Text('Close Deck'),
                      onTap: navController.toggleDeck,
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _NavItem({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        height: 72,
        width: 72,
        decoration: isSelected
            ? const BoxDecoration(
                border: Border(
                  left: BorderSide(color: Colors.deepPurpleAccent, width: 3),
                ),
              )
            : null,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: isSelected ? Colors.deepPurpleAccent : Colors.grey,
            ),
            Text(
              label,
              style: const TextStyle(color: Colors.grey, fontSize: 10),
            ),
          ],
        ),
      ),
    );
  }
}
