import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:logger/logger.dart';
import '../../domain/entities/user.dart';
import 'dart:io';

class UserProfileService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final Logger _logger = Logger();

  // Get user by ID
  Future<UserEntity?> getUserById(String userId) async {
    try {
      final doc = await _firestore.collection('users').doc(userId).get();
      if (doc.exists) {
        return UserEntity.fromMap(doc.data()!);
      }
      return null;
    } catch (e) {
      _logger.e('Error getting user by ID: $e');
      return null;
    }
  }

  // Get user stream
  Stream<UserEntity?> getUserStream(String userId) {
    try {
      return _firestore.collection('users').doc(userId).snapshots().map((doc) {
        if (doc.exists) {
          return UserEntity.fromMap(doc.data()!);
        }
        return null;
      });
    } catch (e) {
      _logger.e('Error getting user stream: $e');
      rethrow;
    }
  }

  // Update user profile
  Future<void> updateUserProfile({
    required String userId,
    String? name,
    String? department,
    String? yearOfStudy,
    String? bio,
    List<String>? interests,
    bool? isAlumni,
  }) async {
    try {
      final Map<String, dynamic> updates = {};

      if (name != null) updates['name'] = name;
      if (department != null) updates['department'] = department;
      if (yearOfStudy != null) updates['yearOfStudy'] = yearOfStudy;
      if (bio != null) updates['bio'] = bio;
      if (interests != null) updates['interests'] = interests;
      if (isAlumni != null) updates['isAlumni'] = isAlumni;

      if (updates.isNotEmpty) {
        await _firestore.collection('users').doc(userId).update(updates);
      }
    } catch (e) {
      _logger.e('Error updating user profile: $e');
      rethrow;
    }
  }

  // Upload profile photo
  Future<String> uploadProfilePhoto(String userId, File imageFile) async {
    try {
      final ref = _storage.ref().child('users/$userId/profile.jpg');
      await ref.putFile(imageFile);
      final url = await ref.getDownloadURL();

      await _firestore.collection('users').doc(userId).update({
        'profilePhotoUrl': url,
      });

      return url;
    } catch (e) {
      _logger.e('Error uploading profile photo: $e');
      rethrow;
    }
  }

  // Upload cover photo
  Future<String> uploadCoverPhoto(String userId, File imageFile) async {
    try {
      final ref = _storage.ref().child('users/$userId/cover.jpg');
      await ref.putFile(imageFile);
      final url = await ref.getDownloadURL();

      await _firestore.collection('users').doc(userId).update({
        'coverPhotoUrl': url,
      });

      return url;
    } catch (e) {
      _logger.e('Error uploading cover photo: $e');
      rethrow;
    }
  }

  // Add image to gallery
  Future<void> addGalleryImage(String userId, File imageFile) async {
    try {
      final ref = _storage.ref().child('users/$userId/gallery/${DateTime.now().millisecondsSinceEpoch}.jpg');
      await ref.putFile(imageFile);
      final url = await ref.getDownloadURL();

      await _firestore.collection('users').doc(userId).update({
        'galleryUrls': FieldValue.arrayUnion([url]),
      });
    } catch (e) {
      _logger.e('Error adding gallery image: $e');
      rethrow;
    }
  }

  // Remove gallery image
  Future<void> removeGalleryImage(String userId, String imageUrl) async {
    try {
      await _firestore.collection('users').doc(userId).update({
        'galleryUrls': FieldValue.arrayRemove([imageUrl]),
      });

      // Delete from storage
      final ref = _storage.refFromURL(imageUrl);
      await ref.delete();
    } catch (e) {
      _logger.e('Error removing gallery image: $e');
      rethrow;
    }
  }

  // Update FCM token
  Future<void> updateFCMToken(String userId, String token) async {
    try {
      await _firestore.collection('users').doc(userId).update({
        'fcmToken': token,
      });
    } catch (e) {
      _logger.e('Error updating FCM token: $e');
      rethrow;
    }
  }

  // Get users by department
  Future<List<UserEntity>> getUsersByDepartment(String department) async {
    try {
      final snapshot = await _firestore
          .collection('users')
          .where('department', isEqualTo: department)
          .where('isBanned', isEqualTo: false)
          .get();

      return snapshot.docs.map((doc) => UserEntity.fromMap(doc.data())).toList();
    } catch (e) {
      _logger.e('Error getting users by department: $e');
      return [];
    }
  }

  // Search users by interests
  Future<List<UserEntity>> searchUsersByInterests(List<String> interests) async {
    try {
      final snapshot = await _firestore
          .collection('users')
          .where('interests', arrayContainsAny: interests)
          .where('isBanned', isEqualTo: false)
          .limit(20)
          .get();

      return snapshot.docs.map((doc) => UserEntity.fromMap(doc.data())).toList();
    } catch (e) {
      _logger.e('Error searching users by interests: $e');
      return [];
    }
  }
}
