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
import '../../shared/widgets/profile_menu_content.dart';

class MobileScaffold extends StatelessWidget {
  const MobileScaffold({super.key});

  @override
  Widget build(BuildContext context) {
    final NavController navController = Get.find();

    final List<Widget> screens = const [
      ActivityScreen(),
      ChatListScreen(),
      VideoChannelsScreen(),
      ReelsFeedScreen(),
    ];

    return Scaffold(
      appBar: AppBar(
        leading: Builder(
          builder: (context) {
            return InkWell(
              onTap: () => Scaffold.of(context).openDrawer(),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Obx(() {
                  final authController = Get.find<AuthController>();
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
                    radius: 16,
                    backgroundColor: Colors.deepPurpleAccent,
                    textStyle:
                        const TextStyle(color: Colors.white, fontSize: 12),
                    status: UserPresenceStatus.available,
                    userId: user?.id,
                  );
                }),
              ),
            );
          },
        ),
        title: Obx(() {
          final titles = [
            'nav_home'.tr,
            'nav_chat'.tr,
            'nav_channels'.tr,
            'nav_reels'.tr
          ];
          return Text(titles[navController.selectedIndex.value]);
        }),
      ),
      drawer: const _ProfileDrawer(),
      body: Obx(() => screens[navController.selectedIndex.value]),
      bottomNavigationBar: Obx(
        () => BottomNavigationBar(
          currentIndex: navController.selectedIndex.value,
          onTap: navController.changeTab,
          type: BottomNavigationBarType.fixed,
          items: [
            BottomNavigationBarItem(
              icon: const Icon(Icons.home),
              label: 'nav_home'.tr,
            ),
            BottomNavigationBarItem(
              icon: const Icon(Icons.chat_bubble),
              label: 'nav_chat'.tr,
            ),
            BottomNavigationBarItem(
              icon: const Icon(Icons.tv),
              label: 'nav_channels'.tr,
            ),
            BottomNavigationBarItem(
              icon: const Icon(Icons.play_circle_fill),
              label: 'nav_reels'.tr,
            ),
          ],
        ),
      ),
    );
  }
}

class _ProfileDrawer extends StatelessWidget {
  const _ProfileDrawer();

  @override
  Widget build(BuildContext context) {
    // final AuthController authController = Get.find(); // Not used anymore

    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          ProfileMenuContent(
            onClose: Get.back,
            useSpacer: false, // Mobile fits content naturally
          ),
        ],
      ),
    );
  }
}
