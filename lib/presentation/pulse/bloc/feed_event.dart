import 'package:equatable/equatable.dart';

abstract class FeedEvent extends Equatable {
  const FeedEvent();

  @override
  List<Object?> get props => [];
}

class LoadFeedEvent extends FeedEvent {
  const LoadFeedEvent();
}

class RefreshFeedEvent extends FeedEvent {
  const RefreshFeedEvent();
}

class CreatePostEvent extends FeedEvent {
  final String content;
  final String? imageUrl;

  const CreatePostEvent({required this.content, this.imageUrl});

  @override
  List<Object?> get props => [content, imageUrl];
}

class LikePostEvent extends FeedEvent {
  final String postId;

  const LikePostEvent(this.postId);

  @override
  List<Object?> get props => [postId];
}

class AddCommentEvent extends FeedEvent {
  final String postId;
  final String content;

  const AddCommentEvent({required this.postId, required this.content});

  @override
  List<Object?> get props => [postId, content];
}

class DeletePostEvent extends FeedEvent {
  final String postId;

  const DeletePostEvent(this.postId);

  @override
  List<Object?> get props => [postId];
}
