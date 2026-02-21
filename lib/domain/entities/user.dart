import 'package:equatable/equatable.dart';

class UserEntity extends Equatable {
  final String id;
  final String name;
  final String email;
  final String department;
  final String role; // 'Student', 'Alumni', 'Admin'
  final String? yearOfStudy;
  final DateTime createdAt;
  final String? profilePhotoUrl;
  final String? coverPhotoUrl;
  final String? bio;
  final List<String> interests;
  final List<String> connectionIds;
  final List<String> galleryUrls;
  final bool isAlumni;
  final bool isBanned;
  final String? fcmToken;

  const UserEntity({
    required this.id,
    required this.name,
    required this.email,
    required this.department,
    required this.role,
    this.yearOfStudy,
    required this.createdAt,
    this.profilePhotoUrl,
    this.coverPhotoUrl,
    this.bio,
    this.interests = const [],
    this.connectionIds = const [],
    this.galleryUrls = const [],
    this.isAlumni = false,
    this.isBanned = false,
    this.fcmToken,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'department': department,
      'role': role,
      'yearOfStudy': yearOfStudy,
      'createdAt': createdAt.toIso8601String(),
      'profilePhotoUrl': profilePhotoUrl,
      'coverPhotoUrl': coverPhotoUrl,
      'bio': bio,
      'interests': interests,
      'connectionIds': connectionIds,
      'galleryUrls': galleryUrls,
      'isAlumni': isAlumni,
      'isBanned': isBanned,
      'fcmToken': fcmToken,
    };
  }

  factory UserEntity.fromMap(Map<String, dynamic> map) {
    return UserEntity(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      email: map['email'] ?? '',
      department: map['department'] ?? '',
      role: map['role'] ?? 'Student',
      yearOfStudy: map['yearOfStudy'],
      createdAt: DateTime.parse(map['createdAt']),
      profilePhotoUrl: map['profilePhotoUrl'],
      coverPhotoUrl: map['coverPhotoUrl'],
      bio: map['bio'],
      interests: List<String>.from(map['interests'] ?? []),
      connectionIds: List<String>.from(map['connectionIds'] ?? []),
      galleryUrls: List<String>.from(map['galleryUrls'] ?? []),
      isAlumni: map['isAlumni'] ?? false,
      isBanned: map['isBanned'] ?? false,
      fcmToken: map['fcmToken'],
    );
  }

  UserEntity copyWith({
    String? id,
    String? name,
    String? email,
    String? department,
    String? role,
    String? yearOfStudy,
    DateTime? createdAt,
    String? profilePhotoUrl,
    String? coverPhotoUrl,
    String? bio,
    List<String>? interests,
    List<String>? connectionIds,
    List<String>? galleryUrls,
    bool? isAlumni,
    bool? isBanned,
    String? fcmToken,
  }) {
    return UserEntity(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      department: department ?? this.department,
      role: role ?? this.role,
      yearOfStudy: yearOfStudy ?? this.yearOfStudy,
      createdAt: createdAt ?? this.createdAt,
      profilePhotoUrl: profilePhotoUrl ?? this.profilePhotoUrl,
      coverPhotoUrl: coverPhotoUrl ?? this.coverPhotoUrl,
      bio: bio ?? this.bio,
      interests: interests ?? this.interests,
      connectionIds: connectionIds ?? this.connectionIds,
      galleryUrls: galleryUrls ?? this.galleryUrls,
      isAlumni: isAlumni ?? this.isAlumni,
      isBanned: isBanned ?? this.isBanned,
      fcmToken: fcmToken ?? this.fcmToken,
    );
  }

  @override
  List<Object?> get props => [
        id,
        name,
        email,
        department,
        role,
        yearOfStudy,
        profilePhotoUrl,
        coverPhotoUrl,
        bio,
        interests,
        connectionIds,
        galleryUrls,
        isAlumni,
        isBanned,
        fcmToken,
      ];
}
