import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../core/values/app_colors.dart';
import '../../core/values/app_strings.dart';
import '../../core/values/app_values.dart';
import '../../data/models/chat_model.dart';
import 'chat_controller.dart';

class ChatView extends GetView<ChatController> {
  const ChatView({super.key});

  @override
  Widget build(BuildContext context) {
    final participant = controller.chat.participants?.first;
    final displayName = controller.chat.isGroup 
        ? controller.chat.name 
        : participant?.name;
    final isOnline = !controller.chat.isGroup && (participant?.isOnline ?? false);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Get.back(),
        ),
        title: Row(
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
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  Text(
                    isOnline ? AppStrings.online : AppStrings.offline,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: isOnline ? AppColors.online : AppColors.textHint,
                        ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
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
      body: Column(
        children: [
          // Messages List
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value && controller.messages.isEmpty) {
                return const Center(child: CircularProgressIndicator());
              }

              if (controller.messages.isEmpty) {
                return Center(
                  child: Text(
                    'No messages yet',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
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
                  final isSentByMe = message.senderId == controller.currentUserId;
                  final showDate = index == controller.messages.length - 1 ||
                      !_isSameDay(
                        message.timestamp,
                        controller.messages[index + 1].timestamp,
                      );

                  return Column(
                    children: [
                      if (showDate) DateChip(date: message.timestamp),
                      MessageBubble(
                        message: message.content,
                        time: message.timestamp,
                        isSentByMe: isSentByMe,
                        isRead: message.isRead,
                      ),
                    ],
                  );
                },
              );
            }),
          ),
          
          // Message Input
          Container(
            padding: const EdgeInsets.all(AppValues.paddingM),
            decoration: BoxDecoration(
              color: AppColors.background,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: SafeArea(
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.add_circle_outline),
                    color: AppColors.primary,
                    onPressed: () {
                      _showAttachmentOptions(context);
                    },
                  ),
                  Expanded(
                    child: TextField(
                      controller: controller.messageController,
                      decoration: InputDecoration(
                        hintText: AppStrings.typeMessage,
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
                        suffixIcon: IconButton(
                          icon: const Icon(Icons.emoji_emotions_outlined),
                          onPressed: () {},
                        ),
                      ),
                      maxLines: null,
                      textCapitalization: TextCapitalization.sentences,
                    ),
                  ),
                  const SizedBox(width: AppValues.paddingS),
                  CircleAvatar(
                    backgroundColor: AppColors.primary,
                    child: IconButton(
                      icon: const Icon(Icons.send, color: Colors.white),
                      onPressed: controller.sendMessage,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  bool _isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
        date1.month == date2.month &&
        date1.day == date2.day;
  }

  void _showAttachmentOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(AppValues.paddingL),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _AttachmentOption(
                  icon: Icons.image,
                  label: 'Gallery',
                  color: Colors.purple,
                  onTap: () => Get.back(),
                ),
                _AttachmentOption(
                  icon: Icons.camera_alt,
                  label: 'Camera',
                  color: Colors.pink,
                  onTap: () => Get.back(),
                ),
                _AttachmentOption(
                  icon: Icons.insert_drive_file,
                  label: 'Document',
                  color: Colors.blue,
                  onTap: () => Get.back(),
                ),
                _AttachmentOption(
                  icon: Icons.location_on,
                  label: 'Location',
                  color: Colors.green,
                  onTap: () => Get.back(),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class MessageBubble extends StatelessWidget {
  final String message;
  final DateTime time;
  final bool isSentByMe;
  final bool isRead;

  const MessageBubble({
    super.key,
    required this.message,
    required this.time,
    required this.isSentByMe,
    required this.isRead,
  });

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: isSentByMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: AppValues.paddingS),
        padding: const EdgeInsets.symmetric(
          horizontal: AppValues.paddingM,
          vertical: AppValues.paddingS,
        ),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.7,
        ),
        decoration: BoxDecoration(
          color: isSentByMe ? AppColors.sentMessageBg : AppColors.receivedMessageBg,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(AppValues.radiusM),
            topRight: const Radius.circular(AppValues.radiusM),
            bottomLeft: Radius.circular(isSentByMe ? AppValues.radiusM : 0),
            bottomRight: Radius.circular(isSentByMe ? 0 : AppValues.radiusM),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              message,
              style: TextStyle(
                color: isSentByMe 
                    ? AppColors.sentMessageText 
                    : AppColors.receivedMessageText,
                fontSize: 15,
              ),
            ),
            const SizedBox(height: 4),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  DateFormat('HH:mm').format(time),
                  style: TextStyle(
                    color: isSentByMe
                        ? AppColors.sentMessageText.withOpacity(0.7)
                        : AppColors.textHint,
                    fontSize: 11,
                  ),
                ),
                if (isSentByMe) ...[
                  const SizedBox(width: 4),
                  Icon(
                    isRead ? Icons.done_all : Icons.done,
                    size: 14,
                    color: isRead ? AppColors.info : Colors.white.withOpacity(0.7),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class DateChip extends StatelessWidget {
  final DateTime date;

  const DateChip({super.key, required this.date});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: AppValues.paddingM),
      padding: const EdgeInsets.symmetric(
        horizontal: AppValues.paddingM,
        vertical: AppValues.paddingS,
      ),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(AppValues.radiusM),
      ),
      child: Text(
        _formatDate(date),
        style: Theme.of(context).textTheme.bodySmall,
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      return 'Today';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return DateFormat('EEEE').format(date);
    } else {
      return DateFormat('MMM dd, yyyy').format(date);
    }
  }
}

class _AttachmentOption extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _AttachmentOption({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 28),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ),
    );
  }
}
