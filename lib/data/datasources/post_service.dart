import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:firebase_storage/firebase_storage.dart';
import 'package:logger/logger.dart';
import '../../domain/entities/post.dart';
import '../../domain/entities/comment.dart';
import 'dart:io';

class PostService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final Logger _logger = Logger();

  // Alias for getPostsFeed for backward compatibility
  Stream<List<Post>> getFeedPosts({int limit = 20}) => getPostsFeed(limit: limit);

  // Like a post (uses current user ID)
  Future<void> likePost(String postId) {
    final userId = firebase_auth.FirebaseAuth.instance.currentUser?.uid ?? '';
    return toggleLike(postId, userId);
  }

  // Get current user ID
  String? get currentUserId => firebase_auth.FirebaseAuth.instance.currentUser?.uid;

  // Create a new post
  Future<Post> createPost({
    required String userId,
    required String userName,
    String? userPhotoUrl,
    required String content,
    List<File>? images,
  }) async {
    try {
      List<String> imageUrls = [];

      // Upload images if any
      if (images != null && images.isNotEmpty) {
        for (int i = 0; i < images.length; i++) {
          final ref = _storage.ref().child('posts/${DateTime.now().millisecondsSinceEpoch}_$i.jpg');
          await ref.putFile(images[i]);
          final url = await ref.getDownloadURL();
          imageUrls.add(url);
        }
      }

      final postRef = _firestore.collection('posts').doc();
      final post = Post(
        id: postRef.id,
        userId: userId,
        userName: userName,
        userPhotoUrl: userPhotoUrl,
        content: content,
        imageUrls: imageUrls,
        createdAt: DateTime.now(),
      );

      await postRef.set(post.toMap());
      return post;
    } catch (e) {
      _logger.e('Error creating post: $e');
      rethrow;
    }
  }

  // Get posts feed (with pagination)
  Stream<List<Post>> getPostsFeed({int limit = 20, DocumentSnapshot? lastDocument}) {
    try {
      Query query = _firestore
          .collection('posts')
          .where('isReported', isEqualTo: false)
          .orderBy('createdAt', descending: true)
          .limit(limit);

      if (lastDocument != null) {
        query = query.startAfterDocument(lastDocument);
      }

      return query.snapshots().map((snapshot) {
        return snapshot.docs.map((doc) => Post.fromMap(doc.data() as Map<String, dynamic>)).toList();
      });
    } catch (e) {
      _logger.e('Error getting posts feed: $e');
      rethrow;
    }
  }

  // Like/Unlike post
  Future<void> toggleLike(String postId, String userId) async {
    try {
      final postRef = _firestore.collection('posts').doc(postId);
      final postDoc = await postRef.get();
      
      if (!postDoc.exists) return;
      
      final post = Post.fromMap(postDoc.data()!);
      final likedBy = List<String>.from(post.likedBy);

      if (likedBy.contains(userId)) {
        likedBy.remove(userId);
        await postRef.update({
          'likedBy': likedBy,
          'likesCount': FieldValue.increment(-1),
        });
      } else {
        likedBy.add(userId);
        await postRef.update({
          'likedBy': likedBy,
          'likesCount': FieldValue.increment(1),
        });
      }
    } catch (e) {
      _logger.e('Error toggling like: $e');
      rethrow;
    }
  }

  // Add comment to post
  Future<Comment> addComment({
    required String postId,
    required String userId,
    required String userName,
    String? userPhotoUrl,
    required String content,
  }) async {
    try {
      final commentRef = _firestore.collection('posts').doc(postId).collection('comments').doc();
      final comment = Comment(
        id: commentRef.id,
        postId: postId,
        userId: userId,
        userName: userName,
        userPhotoUrl: userPhotoUrl,
        content: content,
        createdAt: DateTime.now(),
      );

      await commentRef.set(comment.toMap());

      // Update comment count
      await _firestore.collection('posts').doc(postId).update({
        'commentsCount': FieldValue.increment(1),
      });

      return comment;
    } catch (e) {
      _logger.e('Error adding comment: $e');
      rethrow;
    }
  }

  // Get comments for a post
  Stream<List<Comment>> getComments(String postId) {
    try {
      return _firestore
          .collection('posts')
          .doc(postId)
          .collection('comments')
          .orderBy('createdAt', descending: false)
          .snapshots()
          .map((snapshot) {
        return snapshot.docs.map((doc) => Comment.fromMap(doc.data())).toList();
      });
    } catch (e) {
      _logger.e('Error getting comments: $e');
      rethrow;
    }
  }

  // Report post
  Future<void> reportPost(String postId) async {
    try {
      await _firestore.collection('posts').doc(postId).update({
        'isReported': true,
      });
    } catch (e) {
      _logger.e('Error reporting post: $e');
      rethrow;
    }
  }

  // Delete post (user or admin)
  Future<void> deletePost(String postId) async {
    try {
      // Delete all comments first
      final comments = await _firestore
          .collection('posts')
          .doc(postId)
          .collection('comments')
          .get();

      for (var doc in comments.docs) {
        await doc.reference.delete();
      }

      // Delete the post
      await _firestore.collection('posts').doc(postId).delete();
    } catch (e) {
      _logger.e('Error deleting post: $e');
      rethrow;
    }
  }

  // Share post
  Future<void> sharePost(String postId) async {
    try {
      await _firestore.collection('posts').doc(postId).update({
        'sharesCount': FieldValue.increment(1),
      });
    } catch (e) {
      _logger.e('Error sharing post: $e');
      rethrow;
    }
  }
}
