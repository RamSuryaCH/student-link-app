import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:logger/logger.dart';
import '../../domain/entities/message.dart';
import '../../domain/entities/chat_room.dart';
import 'dart:io';

class MessagingService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final Logger _logger = Logger();

  // Get current user ID
  String? get currentUserId => _auth.currentUser?.uid;

  // Get chat rooms for current user
  Stream<List<ChatRoom>> getChatRooms() {
    final userId = currentUserId;
    if (userId == null) {
      return Stream.value([]);
    }
    return getUserChatRooms(userId);
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
        final ref = _storage.ref().child(
            'chats/$chatId/${DateTime.now().millisecondsSinceEpoch}.jpg');
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
  Future<void> markMessagesAsRead(String chatId, [String? userId]) async {
    final actualUserId = userId ?? currentUserId;
    if (actualUserId == null) return;

    try {
      // Update all unread messages
      final unreadMessages = await _firestore
          .collection('chat_rooms')
          .doc(chatId)
          .collection('messages')
          .where('receiverId', isEqualTo: actualUserId)
          .where('isRead', isEqualTo: false)
          .get();

      for (var doc in unreadMessages.docs) {
        await doc.reference.update({'isRead': true});
      }

      // Reset unread count
      await _firestore.collection('chat_rooms').doc(chatId).update({
        'unreadCounts.$actualUserId': 0,
      });
    } catch (e) {
      _logger.e('Error marking messages as read: $e');
      rethrow;
    }
  }

  // Get user's chat rooms with user info populated
  Stream<List<ChatRoom>> getUserChatRooms(String userId) {
    try {
      return _firestore
          .collection('chat_rooms')
          .where('participantIds', arrayContains: userId)
          .orderBy('lastMessageTime', descending: true)
          .snapshots()
          .asyncMap((snapshot) async {
        List<ChatRoom> chatRooms = [];
        for (var doc in snapshot.docs) {
          var chatRoom = ChatRoom.fromMap(doc.data());
          // Get the other user's info
          final otherUserId = chatRoom.participantIds.firstWhere(
            (id) => id != userId,
            orElse: () => '',
          );
          if (otherUserId.isNotEmpty) {
            try {
              final userDoc =
                  await _firestore.collection('users').doc(otherUserId).get();
              if (userDoc.exists) {
                final userData = userDoc.data()!;
                chatRoom = chatRoom.copyWith(
                  otherUserId: otherUserId,
                  otherUserName: userData['name'] ?? 'Unknown User',
                  otherUserPhotoUrl: userData['photoUrl'],
                );
              }
            } catch (e) {
              _logger.w('Could not fetch user info: $e');
            }
          }
          chatRooms.add(chatRoom);
        }
        return chatRooms;
      });
    } catch (e) {
      _logger.e('Error getting user chat rooms: $e');
      rethrow;
    }
  }

  // Delete message (sender only within 5 minutes)
  Future<void> deleteMessage(
      String chatId, String messageId, DateTime messageTime) async {
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
