import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../core/values/app_colors.dart';
import '../../core/values/app_strings.dart';
import '../../core/values/app_values.dart';
import '../../data/models/chat_model.dart';
import 'desktop_chat_layout.dart';
import 'home_controller.dart';

class HomeView extends GetView<HomeController> {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Update layout mode based on screen width
        final isDesktop = constraints.maxWidth >= 768;
        controller.updateLayoutMode(isDesktop);
        
        // Use Obx to reactively rebuild when layout mode changes
        return Obx(() {
          return controller.isDesktopLayout.value 
              ? _buildDesktopLayout() 
              : _buildMobileLayout(context);
        });
      },
    );
  }

  Widget _buildMobileLayout(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.chats),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              // Show search
              showSearch(
                context: context,
                delegate: ChatSearchDelegate(controller: controller),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.more_vert),
            onPressed: () {
              // Show more options
            },
          ),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value && controller.chats.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        if (controller.chats.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.chat_bubble_outline,
                  size: 80,
                  color: AppColors.textHint,
                ),
                const SizedBox(height: AppValues.paddingM),
                Text(
                  'No chats yet',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                ),
              ],
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: controller.loadChats,
          child: ListView.builder(
            itemCount: controller.chats.length,
            itemBuilder: (context, index) {
              final chat = controller.chats[index];
              return ChatListTile(
                chat: chat,
                onTap: () => controller.openChat(chat),
                onDelete: () => controller.deleteChat(chat),
              );
            },
          ),
        );
      }),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Get.snackbar('Info', 'New chat feature coming soon');
        },
        child: const Icon(Icons.chat),
      ),
      bottomNavigationBar: Obx(() => BottomNavigationBar(
            currentIndex: controller.selectedIndex.value,
            onTap: controller.changeTab,
            items: const [
              BottomNavigationBarItem(
                icon: Icon(Icons.chat_bubble_outline),
                activeIcon: Icon(Icons.chat_bubble),
                label: AppStrings.chats,
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.call_outlined),
                activeIcon: Icon(Icons.call),
                label: AppStrings.calls,
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.contacts_outlined),
                activeIcon: Icon(Icons.contacts),
                label: AppStrings.contacts,
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.settings_outlined),
                activeIcon: Icon(Icons.settings),
                label: AppStrings.settings,
              ),
            ],
          )),
    );
  }

  Widget _buildDesktopLayout() {
    return const Scaffold(
      body: DesktopChatLayout(),
    );
  }
}

class ChatListTile extends StatelessWidget {
  final ChatModel chat;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const ChatListTile({
    super.key,
    required this.chat,
    required this.onTap,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final participant = chat.participants?.first;
    final displayName = chat.isGroup ? chat.name : participant?.name;
    final isOnline = !chat.isGroup && (participant?.isOnline ?? false);

    return Dismissible(
      key: Key(chat.id),
      direction: DismissDirection.endToStart,
      onDismissed: (_) => onDelete(),
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: AppValues.paddingL),
        color: AppColors.error,
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      child: ListTile(
        onTap: onTap,
        leading: Stack(
          children: [
            CircleAvatar(
              radius: 28,
              backgroundColor: AppColors.primary,
              child: Text(
                displayName?.substring(0, 1).toUpperCase() ?? '?',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            if (isOnline)
              Positioned(
                right: 0,
                bottom: 0,
                child: Container(
                  width: 16,
                  height: 16,
                  decoration: BoxDecoration(
                    color: AppColors.online,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Colors.white,
                      width: 2,
                    ),
                  ),
                ),
              ),
          ],
        ),
        title: Row(
          children: [
            Expanded(
              child: Text(
                displayName ?? 'Unknown',
                style: Theme.of(context).textTheme.titleMedium,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (chat.lastMessage != null)
              Text(
                _formatTime(chat.lastMessage!.timestamp),
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: chat.unreadCount > 0
                          ? AppColors.primary
                          : AppColors.textHint,
                      fontWeight: chat.unreadCount > 0
                          ? FontWeight.w600
                          : FontWeight.normal,
                    ),
              ),
          ],
        ),
        subtitle: Row(
          children: [
            Expanded(
              child: Text(
                chat.lastMessage?.content ?? 'No messages yet',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: chat.unreadCount > 0
                          ? AppColors.textPrimary
                          : AppColors.textSecondary,
                      fontWeight: chat.unreadCount > 0
                          ? FontWeight.w600
                          : FontWeight.normal,
                    ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (chat.unreadCount > 0) ...[
              const SizedBox(width: AppValues.paddingS),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 2,
                ),
                decoration: const BoxDecoration(
                  color: AppColors.primary,
                  shape: BoxShape.circle,
                ),
                constraints: const BoxConstraints(
                  minWidth: 20,
                  minHeight: 20,
                ),
                child: Center(
                  child: Text(
                    chat.unreadCount > 99 ? '99+' : '${chat.unreadCount}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppValues.paddingM,
          vertical: AppValues.paddingS,
        ),
      ),
    );
  }

  String _formatTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays == 0) {
      return DateFormat('HH:mm').format(dateTime);
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return DateFormat('EEE').format(dateTime);
    } else {
      return DateFormat('dd/MM/yy').format(dateTime);
    }
  }
}

class ChatSearchDelegate extends SearchDelegate<ChatModel?> {
  final HomeController controller;

  ChatSearchDelegate({required this.controller});

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        icon: const Icon(Icons.clear),
        onPressed: () => query = '',
      ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () => close(context, null),
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    return buildSuggestions(context);
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    final results = controller.chats.where((chat) {
      final displayName = chat.isGroup
          ? chat.name
          : chat.participants?.first.name;
      return displayName?.toLowerCase().contains(query.toLowerCase()) ?? false;
    }).toList();

    return ListView.builder(
      itemCount: results.length,
      itemBuilder: (context, index) {
        final chat = results[index];
        return ChatListTile(
          chat: chat,
          onTap: () {
            close(context, chat);
            controller.openChat(chat);
          },
          onDelete: () => controller.deleteChat(chat),
        );
      },
    );
  }
}
