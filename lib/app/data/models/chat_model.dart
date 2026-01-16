import 'user_model.dart';

class MessageModel {
  final String id;
  final String chatId;
  final String senderId;
  final String content;
  final MessageType type;
  final DateTime timestamp;
  final bool isRead;
  final String? replyToId;

  MessageModel({
    required this.id,
    required this.chatId,
    required this.senderId,
    required this.content,
    required this.type,
    required this.timestamp,
    this.isRead = false,
    this.replyToId,
  });

  factory MessageModel.fromJson(Map<String, dynamic> json) {
    return MessageModel(
      id: json['id'] ?? '',
      chatId: json['chatId'] ?? '',
      senderId: json['senderId'] ?? '',
      content: json['content'] ?? '',
      type: MessageType.values.firstWhere(
        (e) => e.toString() == 'MessageType.${json['type']}',
        orElse: () => MessageType.text,
      ),
      timestamp: DateTime.parse(json['timestamp']),
      isRead: json['isRead'] ?? false,
      replyToId: json['replyToId'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'chatId': chatId,
      'senderId': senderId,
      'content': content,
      'type': type.toString().split('.').last,
      'timestamp': timestamp.toIso8601String(),
      'isRead': isRead,
      'replyToId': replyToId,
    };
  }
}

enum MessageType {
  text,
  image,
  video,
  audio,
  file,
  location,
}

class ChatModel {
  final String id;
  final String? name;
  final List<String> participantIds;
  final List<UserModel>? participants;
  final MessageModel? lastMessage;
  final int unreadCount;
  final bool isGroup;
  final String? groupImageUrl;
  final DateTime? createdAt;

  ChatModel({
    required this.id,
    this.name,
    required this.participantIds,
    this.participants,
    this.lastMessage,
    this.unreadCount = 0,
    this.isGroup = false,
    this.groupImageUrl,
    this.createdAt,
  });

  factory ChatModel.fromJson(Map<String, dynamic> json) {
    return ChatModel(
      id: json['id'] ?? '',
      name: json['name'],
      participantIds: List<String>.from(json['participantIds'] ?? []),
      participants: json['participants'] != null
          ? (json['participants'] as List)
              .map((e) => UserModel.fromJson(e))
              .toList()
          : null,
      lastMessage: json['lastMessage'] != null
          ? MessageModel.fromJson(json['lastMessage'])
          : null,
      unreadCount: json['unreadCount'] ?? 0,
      isGroup: json['isGroup'] ?? false,
      groupImageUrl: json['groupImageUrl'],
      createdAt: json['createdAt'] != null 
          ? DateTime.parse(json['createdAt']) 
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'participantIds': participantIds,
      'participants': participants?.map((e) => e.toJson()).toList(),
      'lastMessage': lastMessage?.toJson(),
      'unreadCount': unreadCount,
      'isGroup': isGroup,
      'groupImageUrl': groupImageUrl,
      'createdAt': createdAt?.toIso8601String(),
    };
  }
}
