import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:logger/logger.dart';
import '../../domain/entities/club.dart';
import 'dart:io';

class ClubService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final Logger _logger = Logger();

  // Create new club
  Future<Club> createClub({
    required String name,
    required String description,
    required String category,
    required String creatorId,
    File? logoFile,
    File? coverImageFile,
  }) async {
    try {
      String? logoUrl;
      String? coverImageUrl;

      // Upload logo if provided
      if (logoFile != null) {
        final logoRef = _storage.ref().child('clubs/logos/${DateTime.now().millisecondsSinceEpoch}.jpg');
        await logoRef.putFile(logoFile);
        logoUrl = await logoRef.getDownloadURL();
      }

      // Upload cover image if provided
      if (coverImageFile != null) {
        final coverRef = _storage.ref().child('clubs/covers/${DateTime.now().millisecondsSinceEpoch}.jpg');
        await coverRef.putFile(coverImageFile);
        coverImageUrl = await coverRef.getDownloadURL();
      }

      final clubRef = _firestore.collection('clubs').doc();
      final club = Club(
        id: clubRef.id,
        name: name,
        description: description,
        category: category,
        logoUrl: logoUrl,
        coverImageUrl: coverImageUrl,
        creatorId: creatorId,
        memberIds: [creatorId],
        adminIds: [creatorId],
        createdAt: DateTime.now(),
        isApproved: false, // Needs admin approval
      );

      await clubRef.set(club.toMap());
      return club;
    } catch (e) {
      _logger.e('Error creating club: $e');
      rethrow;
    }
  }

  // Get all approved clubs
  Stream<List<Club>> getApprovedClubs() {
    try {
      return _firestore
          .collection('clubs')
          .where('isApproved', isEqualTo: true)
          .orderBy('createdAt', descending: true)
          .snapshots()
          .map((snapshot) {
        return snapshot.docs.map((doc) => Club.fromMap(doc.data())).toList();
      });
    } catch (e) {
      _logger.e('Error getting clubs: $e');
      rethrow;
    }
  }

  // Get clubs by category
  Stream<List<Club>> getClubsByCategory(String category) {
    try {
      return _firestore
          .collection('clubs')
          .where('isApproved', isEqualTo: true)
          .where('category', isEqualTo: category)
          .orderBy('createdAt', descending: true)
          .snapshots()
          .map((snapshot) {
        return snapshot.docs.map((doc) => Club.fromMap(doc.data())).toList();
      });
    } catch (e) {
      _logger.e('Error getting clubs by category: $e');
      rethrow;
    }
  }

  // Request to join club
  Future<void> requestToJoinClub(String clubId, String userId) async {
    try {
      await _firestore.collection('clubs').doc(clubId).update({
        'pendingMemberIds': FieldValue.arrayUnion([userId]),
      });
    } catch (e) {
      _logger.e('Error requesting to join club: $e');
      rethrow;
    }
  }

  // Approve member request
  Future<void> approveMember(String clubId, String userId) async {
    try {
      final clubRef = _firestore.collection('clubs').doc(clubId);
      await clubRef.update({
        'pendingMemberIds': FieldValue.arrayRemove([userId]),
        'memberIds': FieldValue.arrayUnion([userId]),
      });
    } catch (e) {
      _logger.e('Error approving member: $e');
      rethrow;
    }
  }

  // Reject member request
  Future<void> rejectMember(String clubId, String userId) async {
    try {
      await _firestore.collection('clubs').doc(clubId).update({
        'pendingMemberIds': FieldValue.arrayRemove([userId]),
      });
    } catch (e) {
      _logger.e('Error rejecting member: $e');
      rethrow;
    }
  }

  // Leave club
  Future<void> leaveClub(String clubId, String userId) async {
    try {
      await _firestore.collection('clubs').doc(clubId).update({
        'memberIds': FieldValue.arrayRemove([userId]),
      });
    } catch (e) {
      _logger.e('Error leaving club: $e');
      rethrow;
    }
  }

  // Get user's clubs
  Stream<List<Club>> getUserClubs(String userId) {
    try {
      return _firestore
          .collection('clubs')
          .where('memberIds', arrayContains: userId)
          .orderBy('createdAt', descending: true)
          .snapshots()
          .map((snapshot) {
        return snapshot.docs.map((doc) => Club.fromMap(doc.data())).toList();
      });
    } catch (e) {
      _logger.e('Error getting user clubs: $e');
      rethrow;
    }
  }

  // Get club by ID
  Future<Club?> getClubById(String clubId) async {
    try {
      final doc = await _firestore.collection('clubs').doc(clubId).get();
      if (doc.exists) {
        return Club.fromMap(doc.data()!);
      }
      return null;
    } catch (e) {
      _logger.e('Error getting club by ID: $e');
      rethrow;
    }
  }

  // Search clubs
  Stream<List<Club>> searchClubs(String query) {
    try {
      return _firestore
          .collection('clubs')
          .where('isApproved', isEqualTo: true)
          .orderBy('name')
          .startAt([query])
          .endAt([query + '\uf8ff'])
          .snapshots()
          .map((snapshot) {
        return snapshot.docs.map((doc) => Club.fromMap(doc.data())).toList();
      });
    } catch (e) {
      _logger.e('Error searching clubs: $e');
      rethrow;
    }
  }

  // Admin: Approve club
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

  // Admin: Get pending clubs
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
}
