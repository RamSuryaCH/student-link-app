import 'package:equatable/equatable.dart';

class UserEntity extends Equatable {
  final String id;
  final String name;
  final String email;
  final String department;
  final String role; // 'Student', 'Alumni', 'Admin'
  final DateTime createdAt;
  final String? profilePhotoUrl;
  final String? bio;
  final List<String> interests;

  const UserEntity({
    required this.id,
    required this.name,
    required this.email,
    required this.department,
    required this.role,
    required this.createdAt,
    this.profilePhotoUrl,
    this.bio,
    this.interests = const [],
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'department': department,
      'role': role,
      'createdAt': createdAt.toIso8601String(),
      'profilePhotoUrl': profilePhotoUrl,
      'bio': bio,
      'interests': interests,
    };
  }

  factory UserEntity.fromMap(Map<String, dynamic> map) {
    return UserEntity(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      email: map['email'] ?? '',
      department: map['department'] ?? '',
      role: map['role'] ?? 'Student',
      createdAt: DateTime.parse(map['createdAt']),
      profilePhotoUrl: map['profilePhotoUrl'],
      bio: map['bio'],
      interests: List<String>.from(map['interests'] ?? []),
    );
  }

  @override
  List<Object?> get props => [id, name, email, department, role, profilePhotoUrl, bio, interests];
}
