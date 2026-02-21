import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:logger/logger.dart';
import '../../domain/entities/user.dart';
import '../../domain/entities/post.dart';
import '../../domain/entities/anonymous_post.dart';
import '../../domain/entities/club.dart';

class AdminService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final Logger _logger = Logger();

  // Get all users
  Stream<List<UserEntity>> getAllUsers() {
    try {
      return _firestore
          .collection('users')
          .orderBy('createdAt', descending: true)
          .snapshots()
          .map((snapshot) {
        return snapshot.docs.map((doc) => UserEntity.fromMap(doc.data())).toList();
      });
    } catch (e) {
      _logger.e('Error getting all users: $e');
      rethrow;
    }
  }

  // Ban/Unban user
  Future<void> toggleBanUser(String userId, bool isBanned) async {
    try {
      await _firestore.collection('users').doc(userId).update({
        'isBanned': isBanned,
      });
    } catch (e) {
      _logger.e('Error toggling ban user: $e');
      rethrow;
    }
  }

  // Delete user account
  Future<void> deleteUser(String userId) async {
    try {
      // Delete user's posts
      final posts = await _firestore.collection('posts').where('userId', isEqualTo: userId).get();
      for (var doc in posts.docs) {
        await doc.reference.delete();
      }

      // Delete user's connection requests
      final requests = await _firestore
          .collection('connection_requests')
          .where('senderId', isEqualTo: userId)
          .get();
      for (var doc in requests.docs) {
        await doc.reference.delete();
      }

      // Delete user document
      await _firestore.collection('users').doc(userId).delete();
    } catch (e) {
      _logger.e('Error deleting user: $e');
      rethrow;
    }
  }

  // Get reported posts
  Stream<List<Post>> getReportedPosts() {
    try {
      return _firestore
          .collection('posts')
          .where('isReported', isEqualTo: true)
          .orderBy('createdAt', descending: true)
          .snapshots()
          .map((snapshot) {
        return snapshot.docs.map((doc) => Post.fromMap(doc.data())).toList();
      });
    } catch (e) {
      _logger.e('Error getting reported posts: $e');
      rethrow;
    }
  }

  // Get reported anonymous posts
  Stream<List<AnonymousPost>> getReportedAnonymousPosts() {
    try {
      return _firestore
          .collection('anonymous_posts')
          .where('isReported', isEqualTo: true)
          .orderBy('reportCount', descending: true)
          .snapshots()
          .map((snapshot) {
        return snapshot.docs.map((doc) => AnonymousPost.fromMap(doc.data())).toList();
      });
    } catch (e) {
      _logger.e('Error getting reported anonymous posts: $e');
      rethrow;
    }
  }

  // Remove reported post
  Future<void> removePost(String postId) async {
    try {
      await _firestore.collection('posts').doc(postId).delete();
    } catch (e) {
      _logger.e('Error removing post: $e');
      rethrow;
    }
  }

  // Remove reported anonymous post
  Future<void> removeAnonymousPost(String postId) async {
    try {
      await _firestore.collection('anonymous_posts').doc(postId).delete();
    } catch (e) {
      _logger.e('Error removing anonymous post: $e');
      rethrow;
    }
  }

  // Approve reported post (mark as safe)
  Future<void> approvePost(String postId) async {
    try {
      await _firestore.collection('posts').doc(postId).update({
        'isReported': false,
      });
    } catch (e) {
      _logger.e('Error approving post: $e');
      rethrow;
    }
  }

  // Approve reported anonymous post
  Future<void> approveAnonymousPost(String postId) async {
    try {
      await _firestore.collection('anonymous_posts').doc(postId).update({
        'isReported': false,
        'reportCount': 0,
      });
    } catch (e) {
      _logger.e('Error approving anonymous post: $e');
      rethrow;
    }
  }

  // Get pending clubs for approval
  Stream<List<Club>> getPendingClubs() {
    try {
      return _firestore
          .collection('clubs')
          .where('isApproved', isEqualTo: false)
          .orderBy('createdAt', descending: true)
          .snapshots()
          .map((snapshot) {
        return snapshot.docs.map((doc) => Club.fromMap(doc.data())).toList();
      });
    } catch (e) {
      _logger.e('Error getting pending clubs: $e');
      rethrow;
    }
  }

  // Approve club
  Future<void> approveClub(String clubId) async {
    try {
      await _firestore.collection('clubs').doc(clubId).update({
        'isApproved': true,
      });
    } catch (e) {
      _logger.e('Error approving club: $e');
      rethrow;
    }
  }

  // Reject club
  Future<void> rejectClub(String clubId) async {
    try {
      await _firestore.collection('clubs').doc(clubId).delete();
    } catch (e) {
      _logger.e('Error rejecting club: $e');
      rethrow;
    }
  }

  // Get analytics data
  Future<Map<String, dynamic>> getAnalytics() async {
    try {
      final usersCount = await _firestore.collection('users').count().get();
      final postsCount = await _firestore.collection('posts').count().get();
      final clubsCount = await _firestore.collection('clubs').count().get();
      final anonymousPostsCount = await _firestore.collection('anonymous_posts').count().get();

      return {
        'totalUsers': usersCount.count,
        'totalPosts': postsCount.count,
        'totalClubs': clubsCount.count,
        'totalAnonymousPosts': anonymousPostsCount.count,
      };
    } catch (e) {
      _logger.e('Error getting analytics: $e');
      return {};
    }
  }

  // Make user admin
  Future<void> makeUserAdmin(String userId) async {
    try {
      await _firestore.collection('users').doc(userId).update({
        'role': 'Admin',
      });
    } catch (e) {
      _logger.e('Error making user admin: $e');
      rethrow;
    }
  }

  // Remove admin role
  Future<void> removeAdminRole(String userId) async {
    try {
      await _firestore.collection('users').doc(userId).update({
        'role': 'Student',
      });
    } catch (e) {
      _logger.e('Error removing admin role: $e');
      rethrow;
    }
  }
}
