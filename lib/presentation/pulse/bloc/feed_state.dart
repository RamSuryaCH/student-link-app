import 'package:equatable/equatable.dart';
import 'package:student_link_app/domain/entities/post.dart';

abstract class FeedState extends Equatable {
  const FeedState();

  @override
  List<Object?> get props => [];
}

class FeedInitial extends FeedState {
  const FeedInitial();
}

class FeedLoading extends FeedState {
  const FeedLoading();
}

class FeedLoaded extends FeedState {
  final List<Post> posts;

  const FeedLoaded(this.posts);

  @override
  List<Object?> get props => [posts];
}

class FeedError extends FeedState {
  final String message;

  const FeedError(this.message);

  @override
  List<Object?> get props => [message];
}

class PostCreating extends FeedState {
  const PostCreating();
}

class PostCreated extends FeedState {
  const PostCreated();
}
