import 'package:equatable/equatable.dart';

class AnonymousPost extends Equatable {
  final String id;
  final String hashedUserId; // Hashed for moderation purposes only
  final String content;
  final int upvotes;
  final int downvotes;
  final List<String> upvotedBy;
  final List<String> downvotedBy;
  final DateTime createdAt;
  final bool isReported;
  final int reportCount;

  const AnonymousPost({
    required this.id,
    required this.hashedUserId,
    required this.content,
    this.upvotes = 0,
    this.downvotes = 0,
    this.upvotedBy = const [],
    this.downvotedBy = const [],
    required this.createdAt,
    this.isReported = false,
    this.reportCount = 0,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'hashedUserId': hashedUserId,
      'content': content,
      'upvotes': upvotes,
      'downvotes': downvotes,
      'upvotedBy': upvotedBy,
      'downvotedBy': downvotedBy,
      'createdAt': createdAt.toIso8601String(),
      'isReported': isReported,
      'reportCount': reportCount,
    };
  }

  factory AnonymousPost.fromMap(Map<String, dynamic> map) {
    return AnonymousPost(
      id: map['id'] ?? '',
      hashedUserId: map['hashedUserId'] ?? '',
      content: map['content'] ?? '',
      upvotes: map['upvotes'] ?? 0,
      downvotes: map['downvotes'] ?? 0,
      upvotedBy: List<String>.from(map['upvotedBy'] ?? []),
      downvotedBy: List<String>.from(map['downvotedBy'] ?? []),
      createdAt: DateTime.parse(map['createdAt']),
      isReported: map['isReported'] ?? false,
      reportCount: map['reportCount'] ?? 0,
    );
  }

  AnonymousPost copyWith({
    String? id,
    String? hashedUserId,
    String? content,
    int? upvotes,
    int? downvotes,
    List<String>? upvotedBy,
    List<String>? downvotedBy,
    DateTime? createdAt,
    bool? isReported,
    int? reportCount,
  }) {
    return AnonymousPost(
      id: id ?? this.id,
      hashedUserId: hashedUserId ?? this.hashedUserId,
      content: content ?? this.content,
      upvotes: upvotes ?? this.upvotes,
      downvotes: downvotes ?? this.downvotes,
      upvotedBy: upvotedBy ?? this.upvotedBy,
      downvotedBy: downvotedBy ?? this.downvotedBy,
      createdAt: createdAt ?? this.createdAt,
      isReported: isReported ?? this.isReported,
      reportCount: reportCount ?? this.reportCount,
    );
  }

  @override
  List<Object?> get props => [
        id,
        hashedUserId,
        content,
        upvotes,
        downvotes,
        upvotedBy,
        downvotedBy,
        createdAt,
        isReported,
        reportCount,
      ];
}
