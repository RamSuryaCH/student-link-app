import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:logger/logger.dart';
import '../../domain/entities/anonymous_post.dart';
import 'dart:convert';
import 'package:crypto/crypto.dart';

class AnonymousPostService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final Logger _logger = Logger();

  // Hash user ID for anonymity tracking
  String _hashUserId(String userId) {
    var bytes = utf8.encode(userId + 'SECRET_SALT_KEY'); // Add a secret salt
    var digest = sha256.convert(bytes);
    return digest.toString();
  }

  // Create anonymous post
  Future<AnonymousPost> createAnonymousPost({
    required String userId,
    required String content,
  }) async {
    try {
      final postRef = _firestore.collection('anonymous_posts').doc();
      final post = AnonymousPost(
        id: postRef.id,
        hashedUserId: _hashUserId(userId),
        content: content,
        createdAt: DateTime.now(),
      );

      await postRef.set(post.toMap());
      return post;
    } catch (e) {
      _logger.e('Error creating anonymous post: $e');
      rethrow;
    }
  }

  // Get anonymous posts feed
  Stream<List<AnonymousPost>> getAnonymousPostsFeed({int limit = 20}) {
    try {
      return _firestore
          .collection('anonymous_posts')
          .where('isReported', isEqualTo: false)
          .orderBy('createdAt', descending: true)
          .limit(limit)
          .snapshots()
          .map((snapshot) {
        return snapshot.docs.map((doc) => AnonymousPost.fromMap(doc.data())).toList();
      });
    } catch (e) {
      _logger.e('Error getting anonymous posts: $e');
      rethrow;
    }
  }

  // Toggle upvote
  Future<void> toggleUpvote(String postId, String userId) async {
    try {
      final postRef = _firestore.collection('anonymous_posts').doc(postId);
      final postDoc = await postRef.get();
      
      if (!postDoc.exists) return;
      
      final post = AnonymousPost.fromMap(postDoc.data()!);
      final upvotedBy = List<String>.from(post.upvotedBy);
      final downvotedBy = List<String>.from(post.downvotedBy);

      // Remove from downvotes if exists
      if (downvotedBy.contains(userId)) {
        downvotedBy.remove(userId);
        await postRef.update({
          'downvotedBy': downvotedBy,
          'downvotes': FieldValue.increment(-1),
        });
      }

      // Toggle upvote
      if (upvotedBy.contains(userId)) {
        upvotedBy.remove(userId);
        await postRef.update({
          'upvotedBy': upvotedBy,
          'upvotes': FieldValue.increment(-1),
        });
      } else {
        upvotedBy.add(userId);
        await postRef.update({
          'upvotedBy': upvotedBy,
          'upvotes': FieldValue.increment(1),
        });
      }
    } catch (e) {
      _logger.e('Error toggling upvote: $e');
      rethrow;
    }
  }

  // Toggle downvote
  Future<void> toggleDownvote(String postId, String userId) async {
    try {
      final postRef = _firestore.collection('anonymous_posts').doc(postId);
      final postDoc = await postRef.get();
      
      if (!postDoc.exists) return;
      
      final post = AnonymousPost.fromMap(postDoc.data()!);
      final upvotedBy = List<String>.from(post.upvotedBy);
      final downvotedBy = List<String>.from(post.downvotedBy);

      // Remove from upvotes if exists
      if (upvotedBy.contains(userId)) {
        upvotedBy.remove(userId);
        await postRef.update({
          'upvotedBy': upvotedBy,
          'upvotes': FieldValue.increment(-1),
        });
      }

      // Toggle downvote
      if (downvotedBy.contains(userId)) {
        downvotedBy.remove(userId);
        await postRef.update({
          'downvotedBy': downvotedBy,
          'downvotes': FieldValue.increment(-1),
        });
      } else {
        downvotedBy.add(userId);
        await postRef.update({
          'downvotedBy': downvotedBy,
          'downvotes': FieldValue.increment(1),
        });
      }
    } catch (e) {
      _logger.e('Error toggling downvote: $e');
      rethrow;
    }
  }

  // Report anonymous post
  Future<void> reportPost(String postId) async {
    try {
      await _firestore.collection('anonymous_posts').doc(postId).update({
        'isReported': true,
        'reportCount': FieldValue.increment(1),
      });
    } catch (e) {
      _logger.e('Error reporting anonymous post: $e');
      rethrow;
    }
  }

  // Delete anonymous post (admin only)
  Future<void> deletePost(String postId) async {
    try {
      await _firestore.collection('anonymous_posts').doc(postId).delete();
    } catch (e) {
      _logger.e('Error deleting anonymous post: $e');
      rethrow;
    }
  }
}
