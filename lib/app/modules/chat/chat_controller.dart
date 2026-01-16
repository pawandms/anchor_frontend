import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../data/models/chat_model.dart';
import '../../data/models/user_model.dart';

class ChatController extends GetxController {
  final messageController = TextEditingController();
  final messages = <MessageModel>[].obs;
  final isLoading = false.obs;
  late ChatModel chat;
  final String currentUserId = 'currentUser'; // Replace with actual user ID
  bool _isInitialized = false;

  @override
  void onInit() {
    super.onInit();
    // Only load from Get.arguments if chat hasn't been set manually
    if (!_isInitialized && Get.arguments != null) {
      chat = Get.arguments as ChatModel;
      _isInitialized = true;
      loadMessages();
    }
  }
  
  // Method to manually initialize the chat (for desktop mode)
  void initializeWithChat(ChatModel chatModel) {
    chat = chatModel;
    _isInitialized = true;
    loadMessages();
  }

  @override
  void onClose() {
    messageController.dispose();
    super.onClose();
  }

  Future<void> loadMessages() async {
    try {
      isLoading.value = true;
      await Future.delayed(const Duration(seconds: 1));
      
      // Load dummy messages
      messages.value = _getDummyMessages();
    } catch (e) {
      Get.snackbar('Error', 'Failed to load messages');
    } finally {
      isLoading.value = false;
    }
  }

  void sendMessage() {
    if (messageController.text.trim().isEmpty) return;

    final newMessage = MessageModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      chatId: chat.id,
      senderId: currentUserId,
      content: messageController.text.trim(),
      type: MessageType.text,
      timestamp: DateTime.now(),
      isRead: false,
    );

    messages.insert(0, newMessage);
    messageController.clear();
  }

  List<MessageModel> _getDummyMessages() {
    final otherUserId = chat.participants?.first.id ?? 'other';
    return [
      MessageModel(
        id: '1',
        chatId: chat.id,
        senderId: currentUserId,
        content: 'Hey! How are you doing?',
        type: MessageType.text,
        timestamp: DateTime.now().subtract(const Duration(minutes: 10)),
        isRead: true,
      ),
      MessageModel(
        id: '2',
        chatId: chat.id,
        senderId: otherUserId,
        content: 'I\'m doing great! Thanks for asking 😊',
        type: MessageType.text,
        timestamp: DateTime.now().subtract(const Duration(minutes: 9)),
        isRead: true,
      ),
      MessageModel(
        id: '3',
        chatId: chat.id,
        senderId: otherUserId,
        content: 'How about you?',
        type: MessageType.text,
        timestamp: DateTime.now().subtract(const Duration(minutes: 9)),
        isRead: true,
      ),
      MessageModel(
        id: '4',
        chatId: chat.id,
        senderId: currentUserId,
        content: 'All good here! Just working on a Flutter project',
        type: MessageType.text,
        timestamp: DateTime.now().subtract(const Duration(minutes: 5)),
        isRead: true,
      ),
      MessageModel(
        id: '5',
        chatId: chat.id,
        senderId: otherUserId,
        content: 'That sounds exciting! What kind of project?',
        type: MessageType.text,
        timestamp: DateTime.now().subtract(const Duration(minutes: 2)),
        isRead: false,
      ),
    ];
  }
}
