import 'package:equatable/equatable.dart';

enum MessageType {
  text,
  image,
  file,
}

class Message extends Equatable {
  final String id;
  final String chatId;
  final String senderId;
  final String receiverId;
  final String content;
  final MessageType type;
  final DateTime createdAt;
  final bool isRead;
  final String? mediaUrl;

  const Message({
    required this.id,
    required this.chatId,
    required this.senderId,
    required this.receiverId,
    required this.content,
    this.type = MessageType.text,
    required this.createdAt,
    this.isRead = false,
    this.mediaUrl,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'chatId': chatId,
      'senderId': senderId,
      'receiverId': receiverId,
      'content': content,
      'type': type.name,
      'createdAt': createdAt.toIso8601String(),
      'isRead': isRead,
      'mediaUrl': mediaUrl,
    };
  }

  factory Message.fromMap(Map<String, dynamic> map) {
    return Message(
      id: map['id'] ?? '',
      chatId: map['chatId'] ?? '',
      senderId: map['senderId'] ?? '',
      receiverId: map['receiverId'] ?? '',
      content: map['content'] ?? '',
      type: MessageType.values.firstWhere(
        (e) => e.name == map['type'],
        orElse: () => MessageType.text,
      ),
      createdAt: DateTime.parse(map['createdAt']),
      isRead: map['isRead'] ?? false,
      mediaUrl: map['mediaUrl'],
    );
  }

  Message copyWith({
    String? id,
    String? chatId,
    String? senderId,
    String? receiverId,
    String? content,
    MessageType? type,
    DateTime? createdAt,
    bool? isRead,
    String? mediaUrl,
  }) {
    return Message(
      id: id ?? this.id,
      chatId: chatId ?? this.chatId,
      senderId: senderId ?? this.senderId,
      receiverId: receiverId ?? this.receiverId,
      content: content ?? this.content,
      type: type ?? this.type,
      createdAt: createdAt ?? this.createdAt,
      isRead: isRead ?? this.isRead,
      mediaUrl: mediaUrl ?? this.mediaUrl,
    );
  }

  @override
  List<Object?> get props => [
        id,
        chatId,
        senderId,
        receiverId,
        content,
        type,
        createdAt,
        isRead,
        mediaUrl,
      ];

  // Alias for createdAt for backwards compatibility
  DateTime get timestamp => createdAt;
}
