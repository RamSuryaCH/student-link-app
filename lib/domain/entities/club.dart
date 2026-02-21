import 'package:equatable/equatable.dart';

class Club extends Equatable {
  final String id;
  final String name;
  final String description;
  final String category;
  final String? logoUrl;
  final String? coverImageUrl;
  final String creatorId;
  final List<String> memberIds;
  final List<String> pendingMemberIds;
  final List<String> adminIds;
  final DateTime createdAt;
  final bool isApproved;

  const Club({
    required this.id,
    required this.name,
    required this.description,
    required this.category,
    this.logoUrl,
    this.coverImageUrl,
    required this.creatorId,
    this.memberIds = const [],
    this.pendingMemberIds = const [],
    this.adminIds = const [],
    required this.createdAt,
    this.isApproved = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'category': category,
      'logoUrl': logoUrl,
      'coverImageUrl': coverImageUrl,
      'creatorId': creatorId,
      'memberIds': memberIds,
      'pendingMemberIds': pendingMemberIds,
      'adminIds': adminIds,
      'createdAt': createdAt.toIso8601String(),
      'isApproved': isApproved,
    };
  }

  factory Club.fromMap(Map<String, dynamic> map) {
    return Club(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      description: map['description'] ?? '',
      category: map['category'] ?? '',
      logoUrl: map['logoUrl'],
      coverImageUrl: map['coverImageUrl'],
      creatorId: map['creatorId'] ?? '',
      memberIds: List<String>.from(map['memberIds'] ?? []),
      pendingMemberIds: List<String>.from(map['pendingMemberIds'] ?? []),
      adminIds: List<String>.from(map['adminIds'] ?? []),
      createdAt: DateTime.parse(map['createdAt']),
      isApproved: map['isApproved'] ?? false,
    );
  }

  Club copyWith({
    String? id,
    String? name,
    String? description,
    String? category,
    String? logoUrl,
    String? coverImageUrl,
    String? creatorId,
    List<String>? memberIds,
    List<String>? pendingMemberIds,
    List<String>? adminIds,
    DateTime? createdAt,
    bool? isApproved,
  }) {
    return Club(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      category: category ?? this.category,
      logoUrl: logoUrl ?? this.logoUrl,
      coverImageUrl: coverImageUrl ?? this.coverImageUrl,
      creatorId: creatorId ?? this.creatorId,
      memberIds: memberIds ?? this.memberIds,
      pendingMemberIds: pendingMemberIds ?? this.pendingMemberIds,
      adminIds: adminIds ?? this.adminIds,
      createdAt: createdAt ?? this.createdAt,
      isApproved: isApproved ?? this.isApproved,
    );
  }

  @override
  List<Object?> get props => [
        id,
        name,
        description,
        category,
        logoUrl,
        coverImageUrl,
        creatorId,
        memberIds,
        pendingMemberIds,
        adminIds,
        createdAt,
        isApproved,
      ];
}
