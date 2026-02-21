import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:firebase_storage/firebase_storage.dart';
import 'package:logger/logger.dart';
import '../../domain/entities/message.dart';
import '../../domain/entities/chat_room.dart';
import 'dart:io';

class MessagingService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final Logger _logger = Logger();

  // Get current user ID
  String? get currentUserId => firebase_auth.FirebaseAuth.instance.currentUser?.uid;

  // Get chat rooms for current user
  Stream<List<ChatRoom>> getChatRooms() {
    final userId = currentUserId ?? '';
    return getUserChatRooms(userId);
  }

  // Mark messages as read for current user
  Future<void> markAsRead(String chatId) {
    final userId = currentUserId ?? '';
    return markMessagesAsRead(chatId, userId);
  }

  // Send a text message in a chat room (automatically resolves sender/receiver)
  Future<Message> sendTextMessage({
    required String chatId,
    required String content,
  }) async {
    try {
      final senderId = currentUserId ?? '';
      final chatRoomDoc = await _firestore.collection('chat_rooms').doc(chatId).get();
      if (!chatRoomDoc.exists) throw Exception('Chat room not found');
      final chatRoom = ChatRoom.fromMap(chatRoomDoc.data()!);
      final receiverId = chatRoom.participantIds.firstWhere(
        (id) => id != senderId,
        orElse: () => '',
      );
      return sendMessage(
        chatId: chatId,
        senderId: senderId,
        receiverId: receiverId,
        content: content,
      );
    } catch (e) {
      _logger.e('Error sending text message: $e');
      rethrow;
    }
  }

  // Get or create chat room between two users
  Future<String> getOrCreateChatRoom(String userId1, String userId2) async {
    try {
      // Sort user IDs to ensure consistent chat room ID
      final List<String> participants = [userId1, userId2]..sort();
      final chatRoomId = '${participants[0]}_${participants[1]}';

      final chatRoomRef = _firestore.collection('chat_rooms').doc(chatRoomId);
      final chatRoomDoc = await chatRoomRef.get();

      if (!chatRoomDoc.exists) {
        final chatRoom = ChatRoom(
          id: chatRoomId,
          participantIds: participants,
          createdAt: DateTime.now(),
        );
        await chatRoomRef.set(chatRoom.toMap());
      }

      return chatRoomId;
    } catch (e) {
      _logger.e('Error getting/creating chat room: $e');
      rethrow;
    }
  }

  // Send text message
  Future<Message> sendMessage({
    required String chatId,
    required String senderId,
    required String receiverId,
    required String content,
    MessageType type = MessageType.text,
    File? mediaFile,
  }) async {
    try {
      String? mediaUrl;

      // Upload media if provided
      if (mediaFile != null && type == MessageType.image) {
        final ref = _storage.ref().child('chats/$chatId/${DateTime.now().millisecondsSinceEpoch}.jpg');
        await ref.putFile(mediaFile);
        mediaUrl = await ref.getDownloadURL();
      }

      final messageRef = _firestore
          .collection('chat_rooms')
          .doc(chatId)
          .collection('messages')
          .doc();

      final message = Message(
        id: messageRef.id,
        chatId: chatId,
        senderId: senderId,
        receiverId: receiverId,
        content: content,
        type: type,
        createdAt: DateTime.now(),
        mediaUrl: mediaUrl,
      );

      await messageRef.set(message.toMap());

      // Update chat room with last message
      await _firestore.collection('chat_rooms').doc(chatId).update({
        'lastMessage': content,
        'lastMessageTime': message.createdAt.toIso8601String(),
        'lastMessageSenderId': senderId,
        'unreadCounts.$receiverId': FieldValue.increment(1),
      });

      return message;
    } catch (e) {
      _logger.e('Error sending message: $e');
      rethrow;
    }
  }

  // Get messages stream
  Stream<List<Message>> getMessages(String chatId) {
    try {
      return _firestore
          .collection('chat_rooms')
          .doc(chatId)
          .collection('messages')
          .orderBy('createdAt', descending: true)
          .limit(50)
          .snapshots()
          .map((snapshot) {
        return snapshot.docs.map((doc) => Message.fromMap(doc.data())).toList();
      });
    } catch (e) {
      _logger.e('Error getting messages: $e');
      rethrow;
    }
  }

  // Mark messages as read
  Future<void> markMessagesAsRead(String chatId, String userId) async {
    try {
      // Update all unread messages
      final unreadMessages = await _firestore
          .collection('chat_rooms')
          .doc(chatId)
          .collection('messages')
          .where('receiverId', isEqualTo: userId)
          .where('isRead', isEqualTo: false)
          .get();

      for (var doc in unreadMessages.docs) {
        await doc.reference.update({'isRead': true});
      }

      // Reset unread count
      await _firestore.collection('chat_rooms').doc(chatId).update({
        'unreadCounts.$userId': 0,
      });
    } catch (e) {
      _logger.e('Error marking messages as read: $e');
      rethrow;
    }
  }

  // Get user's chat rooms
  Stream<List<ChatRoom>> getUserChatRooms(String userId) {
    try {
      return _firestore
          .collection('chat_rooms')
          .where('participantIds', arrayContains: userId)
          .orderBy('lastMessageTime', descending: true)
          .snapshots()
          .map((snapshot) {
        return snapshot.docs.map((doc) => ChatRoom.fromMap(doc.data())).toList();
      });
    } catch (e) {
      _logger.e('Error getting user chat rooms: $e');
      rethrow;
    }
  }

  // Delete message (sender only within 5 minutes)
  Future<void> deleteMessage(String chatId, String messageId, DateTime messageTime) async {
    try {
      final now = DateTime.now();
      final difference = now.difference(messageTime);

      if (difference.inMinutes <= 5) {
        await _firestore
            .collection('chat_rooms')
            .doc(chatId)
            .collection('messages')
            .doc(messageId)
            .delete();
      } else {
        throw Exception('Can only delete messages within 5 minutes');
      }
    } catch (e) {
      _logger.e('Error deleting message: $e');
      rethrow;
    }
  }

  // Get unread message count for user
  Future<int> getUnreadMessageCount(String userId) async {
    try {
      final chatRooms = await _firestore
          .collection('chat_rooms')
          .where('participantIds', arrayContains: userId)
          .get();

      int totalUnread = 0;
      for (var doc in chatRooms.docs) {
        final chatRoom = ChatRoom.fromMap(doc.data());
        totalUnread += chatRoom.unreadCounts[userId] ?? 0;
      }

      return totalUnread;
    } catch (e) {
      _logger.e('Error getting unread count: $e');
      return 0;
    }
  }
}
