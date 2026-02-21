import 'package:equatable/equatable.dart';

class Post extends Equatable {
  final String id;
  final String userId;
  final String userName;
  final String? userPhotoUrl;
  final String content;
  final List<String> imageUrls;
  final int likesCount;
  final int commentsCount;
  final int sharesCount;
  final List<String> likedBy;
  final DateTime createdAt;
  final bool isReported;

  const Post({
    required this.id,
    required this.userId,
    required this.userName,
    this.userPhotoUrl,
    required this.content,
    this.imageUrls = const [],
    this.likesCount = 0,
    this.commentsCount = 0,
    this.sharesCount = 0,
    this.likedBy = const [],
    required this.createdAt,
    this.isReported = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'userName': userName,
      'userPhotoUrl': userPhotoUrl,
      'content': content,
      'imageUrls': imageUrls,
      'likesCount': likesCount,
      'commentsCount': commentsCount,
      'sharesCount': sharesCount,
      'likedBy': likedBy,
      'createdAt': createdAt.toIso8601String(),
      'isReported': isReported,
    };
  }

  factory Post.fromMap(Map<String, dynamic> map) {
    return Post(
      id: map['id'] ?? '',
      userId: map['userId'] ?? '',
      userName: map['userName'] ?? '',
      userPhotoUrl: map['userPhotoUrl'],
      content: map['content'] ?? '',
      imageUrls: List<String>.from(map['imageUrls'] ?? []),
      likesCount: map['likesCount'] ?? 0,
      commentsCount: map['commentsCount'] ?? 0,
      sharesCount: map['sharesCount'] ?? 0,
      likedBy: List<String>.from(map['likedBy'] ?? []),
      createdAt: DateTime.parse(map['createdAt']),
      isReported: map['isReported'] ?? false,
    );
  }

  Post copyWith({
    String? id,
    String? userId,
    String? userName,
    String? userPhotoUrl,
    String? content,
    List<String>? imageUrls,
    int? likesCount,
    int? commentsCount,
    int? sharesCount,
    List<String>? likedBy,
    DateTime? createdAt,
    bool? isReported,
  }) {
    return Post(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      userName: userName ?? this.userName,
      userPhotoUrl: userPhotoUrl ?? this.userPhotoUrl,
      content: content ?? this.content,
      imageUrls: imageUrls ?? this.imageUrls,
      likesCount: likesCount ?? this.likesCount,
      commentsCount: commentsCount ?? this.commentsCount,
      sharesCount: sharesCount ?? this.sharesCount,
      likedBy: likedBy ?? this.likedBy,
      createdAt: createdAt ?? this.createdAt,
      isReported: isReported ?? this.isReported,
    );
  }

  @override
  List<Object?> get props => [
        id,
        userId,
        userName,
        userPhotoUrl,
        content,
        imageUrls,
        likesCount,
        commentsCount,
        sharesCount,
        likedBy,
        createdAt,
        isReported,
      ];
}
