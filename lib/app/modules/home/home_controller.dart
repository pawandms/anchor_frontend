import 'package:get/get.dart';
import '../../data/models/chat_model.dart';
import '../../data/models/user_model.dart';
import '../../routes/app_routes.dart';

class HomeController extends GetxController {
  final selectedIndex = 0.obs;
  final searchQuery = ''.obs;
  final chats = <ChatModel>[].obs;
  final isLoading = false.obs;
  final selectedChat = Rx<ChatModel?>(null); // For desktop layout
  final isDesktopLayout = false.obs; // Track if using desktop layout

  @override
  void onInit() {
    super.onInit();
    loadChats();
  }

  void changeTab(int index) {
    selectedIndex.value = index;
    
    // Navigate based on tab
    switch (index) {
      case 0:
        // Already on Chats
        break;
      case 1:
        Get.toNamed(AppRoutes.calls);
        break;
      case 2:
        Get.toNamed(AppRoutes.contacts);
        break;
      case 3:
        Get.toNamed(AppRoutes.settings);
        break;
    }
  }

  Future<void> loadChats() async {
    try {
      isLoading.value = true;
      
      // Simulate API call - Replace with actual data
      await Future.delayed(const Duration(seconds: 1));
      
      chats.value = _getDummyChats();
    } catch (e) {
      Get.snackbar('Error', 'Failed to load chats');
    } finally {
      isLoading.value = false;
    }
  }

  void updateLayoutMode(bool isDesktop) {
    if (isDesktopLayout.value != isDesktop) {
      isDesktopLayout.value = isDesktop;
      print('Layout mode changed to: ${isDesktop ? "Desktop" : "Mobile"}');
      
      // If switching from desktop to mobile, clear selected chat
      if (!isDesktop && selectedChat.value != null) {
        selectedChat.value = null;
      }
    }
  }
  
  void openChat(ChatModel chat) {
    print('OpenChat called - isDesktopLayout: ${isDesktopLayout.value}'); // Debug log
    
    if (isDesktopLayout.value) {
      // On desktop, show chat in right panel
      selectedChat.value = chat;
    } else {
      // On mobile, navigate to new screen
      Get.toNamed(AppRoutes.chat, arguments: chat);
    }
  }

  void closeChat() {
    selectedChat.value = null;
  }

  void deleteChat(ChatModel chat) {
    chats.remove(chat);
    Get.snackbar('Success', 'Chat deleted');
  }

  void searchChats(String query) {
    searchQuery.value = query;
    // Implement search logic
  }

  List<ChatModel> _getDummyChats() {
    return [
      ChatModel(
        id: '1',
        participantIds: ['user1'],
        participants: [
          UserModel(
            id: 'user1',
            name: 'John Doe',
            email: 'john@example.com',
            isOnline: true,
            avatarUrl: null,
          ),
        ],
        lastMessage: MessageModel(
          id: 'msg1',
          chatId: '1',
          senderId: 'user1',
          content: 'Hey! How are you?',
          type: MessageType.text,
          timestamp: DateTime.now().subtract(const Duration(minutes: 5)),
        ),
        unreadCount: 2,
      ),
      ChatModel(
        id: '2',
        participantIds: ['user2'],
        participants: [
          UserModel(
            id: 'user2',
            name: 'Jane Smith',
            email: 'jane@example.com',
            isOnline: false,
            lastSeen: DateTime.now().subtract(const Duration(hours: 2)),
            avatarUrl: null,
          ),
        ],
        lastMessage: MessageModel(
          id: 'msg2',
          chatId: '2',
          senderId: 'user2',
          content: 'See you tomorrow!',
          type: MessageType.text,
          timestamp: DateTime.now().subtract(const Duration(hours: 1)),
        ),
        unreadCount: 0,
      ),
      ChatModel(
        id: '3',
        name: 'Flutter Developers',
        participantIds: ['user3', 'user4', 'user5'],
        participants: [
          UserModel(
            id: 'user3',
            name: 'Alice Johnson',
            email: 'alice@example.com',
            isOnline: true,
          ),
        ],
        lastMessage: MessageModel(
          id: 'msg3',
          chatId: '3',
          senderId: 'user3',
          content: 'Check out this new package!',
          type: MessageType.text,
          timestamp: DateTime.now().subtract(const Duration(minutes: 30)),
        ),
        unreadCount: 5,
        isGroup: true,
      ),
    ];
  }
}
