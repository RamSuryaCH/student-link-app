import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:logger/logger.dart';
import '../../domain/entities/connection_request.dart';
import '../../domain/entities/user.dart';

class ConnectionService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final Logger _logger = Logger();

  // Send connection request
  Future<ConnectionRequest> sendConnectionRequest({
    required String senderId,
    required String receiverId,
  }) async {
    try {
      final requestRef = _firestore.collection('connection_requests').doc();
      final request = ConnectionRequest(
        id: requestRef.id,
        senderId: senderId,
        receiverId: receiverId,
        status: ConnectionStatus.pending,
        createdAt: DateTime.now(),
      );

      await requestRef.set(request.toMap());
      return request;
    } catch (e) {
      _logger.e('Error sending connection request: $e');
      rethrow;
    }
  }

  // Get received connection requests
  Stream<List<ConnectionRequest>> getReceivedRequests(String userId) {
    try {
      return _firestore
          .collection('connection_requests')
          .where('receiverId', isEqualTo: userId)
          .where('status', isEqualTo: ConnectionStatus.pending.name)
          .orderBy('createdAt', descending: true)
          .snapshots()
          .map((snapshot) {
        return snapshot.docs.map((doc) => ConnectionRequest.fromMap(doc.data())).toList();
      });
    } catch (e) {
      _logger.e('Error getting received requests: $e');
      rethrow;
    }
  }

  // Get sent connection requests
  Stream<List<ConnectionRequest>> getSentRequests(String userId) {
    try {
      return _firestore
          .collection('connection_requests')
          .where('senderId', isEqualTo: userId)
          .where('status', isEqualTo: ConnectionStatus.pending.name)
          .orderBy('createdAt', descending: true)
          .snapshots()
          .map((snapshot) {
        return snapshot.docs.map((doc) => ConnectionRequest.fromMap(doc.data())).toList();
      });
    } catch (e) {
      _logger.e('Error getting sent requests: $e');
      rethrow;
    }
  }

  // Accept connection request
  Future<void> acceptConnectionRequest(String requestId, String senderId, String receiverId) async {
    try {
      // Update request status
      await _firestore.collection('connection_requests').doc(requestId).update({
        'status': ConnectionStatus.accepted.name,
      });

      // Add to both users' connection lists
      await _firestore.collection('users').doc(senderId).update({
        'connectionIds': FieldValue.arrayUnion([receiverId]),
      });

      await _firestore.collection('users').doc(receiverId).update({
        'connectionIds': FieldValue.arrayUnion([senderId]),
      });
    } catch (e) {
      _logger.e('Error accepting connection request: $e');
      rethrow;
    }
  }

  // Reject connection request
  Future<void> rejectConnectionRequest(String requestId) async {
    try {
      await _firestore.collection('connection_requests').doc(requestId).update({
        'status': ConnectionStatus.rejected.name,
      });
    } catch (e) {
      _logger.e('Error rejecting connection request: $e');
      rethrow;
    }
  }

  // Remove connection
  Future<void> removeConnection(String userId, String connectionId) async {
    try {
      await _firestore.collection('users').doc(userId).update({
        'connectionIds': FieldValue.arrayRemove([connectionId]),
      });

      await _firestore.collection('users').doc(connectionId).update({
        'connectionIds': FieldValue.arrayRemove([userId]),
      });
    } catch (e) {
      _logger.e('Error removing connection: $e');
      rethrow;
    }
  }

  // Get user's connections
  Future<List<UserEntity>> getUserConnections(String userId) async {
    try {
      final userDoc = await _firestore.collection('users').doc(userId).get();
      if (!userDoc.exists) return [];

      final user = UserEntity.fromMap(userDoc.data()!);
      if (user.connectionIds.isEmpty) return [];

      final connections = <UserEntity>[];
      for (final connectionId in user.connectionIds) {
        final doc = await _firestore.collection('users').doc(connectionId).get();
        if (doc.exists) {
          connections.add(UserEntity.fromMap(doc.data()!));
        }
      }

      return connections;
    } catch (e) {
      _logger.e('Error getting user connections: $e');
      rethrow;
    }
  }

  // Get suggested connections (users not connected and not requested)
  Future<List<UserEntity>> getSuggestedConnections(String userId, {int limit = 20}) async {
    try {
      // Get current user
      final userDoc = await _firestore.collection('users').doc(userId).get();
      if (!userDoc.exists) return [];

      final currentUser = UserEntity.fromMap(userDoc.data()!);
      
      // Get all users
      final usersSnapshot = await _firestore
          .collection('users')
          .where('isBanned', isEqualTo: false)
          .limit(limit * 2)
          .get();

      final suggestions = <UserEntity>[];
      
      for (final doc in usersSnapshot.docs) {
        final user = UserEntity.fromMap(doc.data());
        
        // Skip self and already connected users
        if (user.id == userId || currentUser.connectionIds.contains(user.id)) {
          continue;
        }

        // Prioritize users from same department
        suggestions.add(user);
        
        if (suggestions.length >= limit) break;
      }

      return suggestions;
    } catch (e) {
      _logger.e('Error getting suggested connections: $e');
      rethrow;
    }
  }

  // Search users
  Future<List<UserEntity>> searchUsers(String query, String currentUserId) async {
    try {
      final snapshot = await _firestore
          .collection('users')
          .where('isBanned', isEqualTo: false)
          .orderBy('name')
          .startAt([query])
          .endAt([query + '\uf8ff'])
          .get();

      return snapshot.docs
          .map((doc) => UserEntity.fromMap(doc.data()))
          .where((user) => user.id != currentUserId)
          .toList();
    } catch (e) {
      _logger.e('Error searching users: $e');
      rethrow;
    }
  }

  // Check if connection request exists
  Future<bool> hasConnectionRequest(String senderId, String receiverId) async {
    try {
      final snapshot = await _firestore
          .collection('connection_requests')
          .where('senderId', isEqualTo: senderId)
          .where('receiverId', isEqualTo: receiverId)
          .where('status', isEqualTo: ConnectionStatus.pending.name)
          .get();

      return snapshot.docs.isNotEmpty;
    } catch (e) {
      _logger.e('Error checking connection request: $e');
      return false;
    }
  }
}
