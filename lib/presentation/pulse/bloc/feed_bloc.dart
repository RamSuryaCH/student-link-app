import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:student_link_app/data/datasources/post_service.dart';
import 'package:student_link_app/presentation/pulse/bloc/feed_event.dart';
import 'package:student_link_app/presentation/pulse/bloc/feed_state.dart';

class FeedBloc extends Bloc<FeedEvent, FeedState> {
  final PostService _postService;
  StreamSubscription? _feedSubscription;

  FeedBloc({required PostService postService})
      : _postService = postService,
        super(const FeedInitial()) {
    on<LoadFeedEvent>(_onLoadFeed);
    on<RefreshFeedEvent>(_onRefreshFeed);
    on<CreatePostEvent>(_onCreatePost);
    on<LikePostEvent>(_onLikePost);
    on<AddCommentEvent>(_onAddComment);
    on<DeletePostEvent>(_onDeletePost);
  }

  Future<void> _onLoadFeed(LoadFeedEvent event, Emitter<FeedState> emit) async {
    emit(const FeedLoading());
    try {
      await _feedSubscription?.cancel();
      _feedSubscription = _postService.getFeedPosts().listen(
        (posts) {
          if (!isClosed) {
            emit(FeedLoaded(posts));
          }
        },
        onError: (error) {
          if (!isClosed) {
            emit(FeedError(error.toString()));
          }
        },
      );
    } catch (e) {
      emit(FeedError(e.toString()));
    }
  }

  Future<void> _onRefreshFeed(
      RefreshFeedEvent event, Emitter<FeedState> emit) async {
    // Keep current state while refreshing
    add(const LoadFeedEvent());
  }

  Future<void> _onCreatePost(
      CreatePostEvent event, Emitter<FeedState> emit) async {
    emit(const PostCreating());
    try {
      final currentUserId = _postService.currentUserId;
      if (currentUserId == null) {
        emit(const FeedError('Not authenticated'));
        return;
      }

      // Fetch user info for post
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(currentUserId)
          .get();
      final userData = userDoc.data() ?? {};
      final userName = userData['name'] ?? 'Unknown User';
      final userPhotoUrl = userData['photoUrl'];

      await _postService.createPost(
        userId: currentUserId,
        userName: userName,
        userPhotoUrl: userPhotoUrl,
        content: event.content,
      );
      emit(const PostCreated());
      // Reload feed
      add(const LoadFeedEvent());
    } catch (e) {
      emit(FeedError(e.toString()));
    }
  }

  Future<void> _onLikePost(LikePostEvent event, Emitter<FeedState> emit) async {
    try {
      await _postService.likePost(event.postId);
    } catch (e) {
      // Silent fail - the stream will update anyway
    }
  }

  Future<void> _onAddComment(
      AddCommentEvent event, Emitter<FeedState> emit) async {
    try {
      final currentUserId = _postService.currentUserId;
      if (currentUserId == null) return;

      // Fetch user info for comment
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(currentUserId)
          .get();
      final userData = userDoc.data() ?? {};
      final userName = userData['name'] ?? 'Unknown User';
      final userPhotoUrl = userData['photoUrl'];

      await _postService.addComment(
        postId: event.postId,
        userId: currentUserId,
        userName: userName,
        userPhotoUrl: userPhotoUrl,
        content: event.content,
      );
    } catch (e) {
      emit(FeedError(e.toString()));
    }
  }

  Future<void> _onDeletePost(
      DeletePostEvent event, Emitter<FeedState> emit) async {
    try {
      await _postService.deletePost(event.postId);
    } catch (e) {
      emit(FeedError(e.toString()));
    }
  }

  @override
  Future<void> close() {
    _feedSubscription?.cancel();
    return super.close();
  }
}
