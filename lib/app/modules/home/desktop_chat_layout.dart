import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/values/app_colors.dart';
import '../../core/values/app_values.dart';
import '../../data/models/chat_model.dart';
import '../chat/chat_controller.dart';
import 'home_controller.dart';

class DesktopChatLayout extends GetView<HomeController> {
  const DesktopChatLayout({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // Left side - Chat list
        Container(
          width: 380,
          decoration: BoxDecoration(
            color: AppColors.background,
            border: Border(
              right: BorderSide(
                color: AppColors.divider,
                width: 1,
              ),
            ),
          ),
          child: Column(
            children: [
              // Chat list header
              Container(
                padding: const EdgeInsets.all(AppValues.paddingM),
                decoration: BoxDecoration(
                  color: AppColors.background,
                  border: Border(
                    bottom: BorderSide(
                      color: AppColors.divider,
                      width: 1,
                    ),
                  ),
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: AppColors.primary,
                      child: const Icon(Icons.person, color: Colors.white),
                    ),
                    const SizedBox(width: AppValues.paddingM),
                    Expanded(
                      child: Text(
                        'Chats',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.search),
                      onPressed: () {},
                    ),
                    IconButton(
                      icon: const Icon(Icons.more_vert),
                      onPressed: () {},
                    ),
                  ],
                ),
              ),
              // Chat list
              Expanded(
                child: Obx(() {
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
                            size: 64,
                            color: AppColors.textHint,
                          ),
                          const SizedBox(height: AppValues.paddingM),
                          Text(
                            'No chats yet',
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                  color: AppColors.textSecondary,
                                ),
                          ),
                        ],
                      ),
                    );
                  }

                  return ListView.builder(
                    itemCount: controller.chats.length,
                    itemBuilder: (context, index) {
                      final chat = controller.chats[index];
                      return Obx(() {
                        final isSelected = controller.selectedChat.value?.id == chat.id;
                        return DesktopChatListTile(
                          chat: chat,
                          isSelected: isSelected,
                          onTap: () => controller.openChat(chat),
                        );
                      });
                    },
                  );
                }),
              ),
            ],
          ),
        ),
        
        // Right side - Chat messages
        Expanded(
          child: Obx(() {
            final selectedChat = controller.selectedChat.value;
            
            if (selectedChat == null) {
              return _buildEmptyChatView(context);
            }
            
            return _buildChatView(selectedChat);
          }),
        ),
      ],
    );
  }

  Widget _buildEmptyChatView(BuildContext context) {
    return Container(
      color: AppColors.cardBackground,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.chat_bubble_outline,
              size: 120,
              color: AppColors.textHint.withOpacity(0.5),
            ),
            const SizedBox(height: AppValues.paddingL),
            Text(
              'Select a chat to start messaging',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: AppColors.textSecondary,
                  ),
            ),
            const SizedBox(height: AppValues.paddingS),
            Text(
              'Choose a conversation from the list',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.textHint,
                  ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChatView(ChatModel chat) {
    // Check if chat controller exists and if it's for a different chat
    final existingController = Get.isRegistered<ChatController>() 
        ? Get.find<ChatController>() 
        : null;
    
    if (existingController == null || existingController.chat.id != chat.id) {
      // Delete old controller and create new one
      Get.delete<ChatController>();
      final chatController = Get.put(ChatController(), permanent: false);
      
      // Initialize with the selected chat
      chatController.initializeWithChat(chat);
    }
    
    return _buildChatContent(chat);
  }

  Widget _buildChatContent(ChatModel chat) {
    final controller = Get.find<ChatController>();
    final participant = chat.participants?.first;
    final displayName = chat.isGroup ? chat.name : participant?.name;
    final isOnline = !chat.isGroup && (participant?.isOnline ?? false);

    return Column(
      children: [
        // Chat header
        Container(
          padding: const EdgeInsets.all(AppValues.paddingM),
          decoration: BoxDecoration(
            color: AppColors.background,
            border: Border(
              bottom: BorderSide(
                color: AppColors.divider,
                width: 1,
              ),
            ),
          ),
          child: Row(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundColor: AppColors.primary,
                child: Text(
                  displayName?.substring(0, 1).toUpperCase() ?? '?',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(width: AppValues.paddingM),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      displayName ?? 'Unknown',
                      style: Get.textTheme.titleMedium,
                    ),
                    Text(
                      isOnline ? 'Online' : 'Offline',
                      style: Get.textTheme.bodySmall?.copyWith(
                        color: isOnline ? AppColors.online : AppColors.textHint,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.videocam),
                onPressed: () {
                  Get.snackbar('Info', 'Video call feature coming soon');
                },
              ),
              IconButton(
                icon: const Icon(Icons.call),
                onPressed: () {
                  Get.snackbar('Info', 'Voice call feature coming soon');
                },
              ),
              IconButton(
                icon: const Icon(Icons.more_vert),
                onPressed: () {},
              ),
            ],
          ),
        ),
        // Messages
        Expanded(
          child: Obx(() {
            if (controller.isLoading.value && controller.messages.isEmpty) {
              return const Center(child: CircularProgressIndicator());
            }

            if (controller.messages.isEmpty) {
              return Center(
                child: Text(
                  'No messages yet',
                  style: Get.textTheme.bodyLarge?.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              );
            }

            return ListView.builder(
              reverse: true,
              padding: const EdgeInsets.all(AppValues.paddingM),
              itemCount: controller.messages.length,
              itemBuilder: (context, index) {
                final message = controller.messages[index];
                final isMe = message.senderId == controller.currentUserId;
                final showSenderName = chat.isGroup && !isMe;

                return _buildMessageBubble(
                  message: message,
                  isMe: isMe,
                  showSenderName: showSenderName,
                );
              },
            );
          }),
        ),
        // Message input
        Container(
          padding: const EdgeInsets.all(AppValues.paddingM),
          decoration: BoxDecoration(
            color: AppColors.background,
            border: Border(
              top: BorderSide(
                color: AppColors.divider,
                width: 1,
              ),
            ),
          ),
          child: Row(
            children: [
              IconButton(
                icon: const Icon(Icons.emoji_emotions_outlined),
                onPressed: () {},
              ),
              IconButton(
                icon: const Icon(Icons.attach_file),
                onPressed: () {},
              ),
              Expanded(
                child: TextField(
                  controller: controller.messageController,
                  decoration: InputDecoration(
                    hintText: 'Type a message',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(24),
                      borderSide: BorderSide.none,
                    ),
                    filled: true,
                    fillColor: AppColors.cardBackground,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: AppValues.paddingM,
                      vertical: AppValues.paddingS,
                    ),
                  ),
                  maxLines: null,
                  textCapitalization: TextCapitalization.sentences,
                ),
              ),
              const SizedBox(width: AppValues.paddingS),
              IconButton(
                icon: const Icon(Icons.mic),
                onPressed: () {},
              ),
              IconButton(
                icon: const Icon(Icons.send, color: AppColors.primary),
                onPressed: controller.sendMessage,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMessageBubble({
    required MessageModel message,
    required bool isMe,
    required bool showSenderName,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppValues.paddingS),
      child: Row(
        mainAxisAlignment: isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: [
          if (!isMe)
            const Padding(
              padding: EdgeInsets.only(right: AppValues.paddingS),
              child: CircleAvatar(
                radius: 16,
                backgroundColor: AppColors.primary,
                child: Icon(Icons.person, size: 16, color: Colors.white),
              ),
            ),
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppValues.paddingM,
                vertical: AppValues.paddingS,
              ),
              decoration: BoxDecoration(
                color: isMe ? AppColors.primary : AppColors.cardBackground,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (showSenderName) ...[
                    Text(
                      message.senderId,
                      style: Get.textTheme.bodySmall?.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                  ],
                  Text(
                    message.content,
                    style: Get.textTheme.bodyMedium?.copyWith(
                      color: isMe ? Colors.white : AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        _formatMessageTime(message.timestamp),
                        style: Get.textTheme.bodySmall?.copyWith(
                          color: isMe
                              ? Colors.white.withOpacity(0.7)
                              : AppColors.textHint,
                          fontSize: 10,
                        ),
                      ),
                      if (isMe) ...[
                        const SizedBox(width: 4),
                        Icon(
                          message.isRead ? Icons.done_all : Icons.done,
                          size: 14,
                          color: Colors.white.withOpacity(0.7),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatMessageTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays == 0) {
      final hour = dateTime.hour;
      final minute = dateTime.minute.toString().padLeft(2, '0');
      final period = hour >= 12 ? 'PM' : 'AM';
      final displayHour = hour > 12 ? hour - 12 : (hour == 0 ? 12 : hour);
      return '$displayHour:$minute $period';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else {
      return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
    }
  }
}

class DesktopChatListTile extends StatelessWidget {
  final ChatModel chat;
  final bool isSelected;
  final VoidCallback onTap;

  const DesktopChatListTile({
    super.key,
    required this.chat,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final participant = chat.participants?.first;
    final displayName = chat.isGroup ? chat.name : participant?.name;
    final isOnline = !chat.isGroup && (participant?.isOnline ?? false);

    return Container(
      color: isSelected ? AppColors.primary.withOpacity(0.1) : null,
      child: ListTile(
        onTap: onTap,
        leading: Stack(
          children: [
            CircleAvatar(
              radius: 24,
              backgroundColor: AppColors.primary,
              child: Text(
                displayName?.substring(0, 1).toUpperCase() ?? '?',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            if (isOnline)
              Positioned(
                right: 0,
                bottom: 0,
                child: Container(
                  width: 14,
                  height: 14,
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
        title: Text(
          displayName ?? 'Unknown',
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontWeight: chat.unreadCount > 0 ? FontWeight.w600 : FontWeight.normal,
              ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Text(
          chat.lastMessage?.content ?? 'No messages yet',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: chat.unreadCount > 0
                    ? AppColors.textPrimary
                    : AppColors.textSecondary,
                fontWeight: chat.unreadCount > 0 ? FontWeight.w600 : FontWeight.normal,
              ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        trailing: SizedBox(
          width: 60,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              if (chat.lastMessage != null)
                Text(
                  _formatTime(chat.lastMessage!.timestamp),
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: chat.unreadCount > 0
                            ? AppColors.primary
                            : AppColors.textHint,
                        fontSize: 11,
                      ),
                ),
              if (chat.unreadCount > 0) ...[
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 2,
                  ),
                  decoration: const BoxDecoration(
                    color: AppColors.primary,
                    shape: BoxShape.circle,
                  ),
                  constraints: const BoxConstraints(
                    minWidth: 18,
                    minHeight: 18,
                  ),
                  child: Center(
                    child: Text(
                      chat.unreadCount > 99 ? '99+' : '${chat.unreadCount}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  String _formatTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays == 0) {
      final hour = dateTime.hour;
      final minute = dateTime.minute.toString().padLeft(2, '0');
      final period = hour >= 12 ? 'PM' : 'AM';
      final displayHour = hour > 12 ? hour - 12 : (hour == 0 ? 12 : hour);
      return '$displayHour:$minute $period';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      const days = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];
      return days[dateTime.weekday % 7];
    } else {
      return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
    }
  }
}
