import 'package:equatable/equatable.dart';

class ChatRoom extends Equatable {
  final String id;
  final List<String> participantIds;
  final String? lastMessage;
  final DateTime? lastMessageTime;
  final String? lastMessageSenderId;
  final Map<String, int> unreadCounts; // userId -> unreadCount
  final DateTime createdAt;
  // UI helper fields - populated by service
  final String? otherUserName;
  final String? otherUserPhotoUrl;
  final String? otherUserId;

  const ChatRoom({
    required this.id,
    required this.participantIds,
    this.lastMessage,
    this.lastMessageTime,
    this.lastMessageSenderId,
    this.unreadCounts = const {},
    required this.createdAt,
    this.otherUserName,
    this.otherUserPhotoUrl,
    this.otherUserId,
  });

  // Helper to get unread count for a specific user
  int getUnreadCount(String userId) => unreadCounts[userId] ?? 0;

  // Alias for UI that expects unreadCount property
  int get unreadCount {
    // Returns total unread if no specific user context
    return unreadCounts.values.fold(0, (sum, count) => sum + count);
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'participantIds': participantIds,
      'lastMessage': lastMessage,
      'lastMessageTime': lastMessageTime?.toIso8601String(),
      'lastMessageSenderId': lastMessageSenderId,
      'unreadCounts': unreadCounts,
      'createdAt': createdAt.toIso8601String(),
      'otherUserName': otherUserName,
      'otherUserPhotoUrl': otherUserPhotoUrl,
      'otherUserId': otherUserId,
    };
  }

  factory ChatRoom.fromMap(Map<String, dynamic> map) {
    return ChatRoom(
      id: map['id'] ?? '',
      participantIds: List<String>.from(map['participantIds'] ?? []),
      lastMessage: map['lastMessage'],
      lastMessageTime: map['lastMessageTime'] != null
          ? DateTime.parse(map['lastMessageTime'])
          : null,
      lastMessageSenderId: map['lastMessageSenderId'],
      unreadCounts: Map<String, int>.from(map['unreadCounts'] ?? {}),
      createdAt: map['createdAt'] != null
          ? DateTime.parse(map['createdAt'])
          : DateTime.now(),
      otherUserName: map['otherUserName'],
      otherUserPhotoUrl: map['otherUserPhotoUrl'],
      otherUserId: map['otherUserId'],
    );
  }

  ChatRoom copyWith({
    String? id,
    List<String>? participantIds,
    String? lastMessage,
    DateTime? lastMessageTime,
    String? lastMessageSenderId,
    Map<String, int>? unreadCounts,
    DateTime? createdAt,
    String? otherUserName,
    String? otherUserPhotoUrl,
    String? otherUserId,
  }) {
    return ChatRoom(
      id: id ?? this.id,
      participantIds: participantIds ?? this.participantIds,
      lastMessage: lastMessage ?? this.lastMessage,
      lastMessageTime: lastMessageTime ?? this.lastMessageTime,
      lastMessageSenderId: lastMessageSenderId ?? this.lastMessageSenderId,
      unreadCounts: unreadCounts ?? this.unreadCounts,
      createdAt: createdAt ?? this.createdAt,
      otherUserName: otherUserName ?? this.otherUserName,
      otherUserPhotoUrl: otherUserPhotoUrl ?? this.otherUserPhotoUrl,
      otherUserId: otherUserId ?? this.otherUserId,
    );
  }

  @override
  List<Object?> get props => [
        id,
        participantIds,
        lastMessage,
        lastMessageTime,
        lastMessageSenderId,
        unreadCounts,
        createdAt,
        otherUserName,
        otherUserPhotoUrl,
        otherUserId,
      ];
}
