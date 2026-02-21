import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:flutter_bloc/flutter_bloc.dart';
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
      _feedSubscription = _postService.getPostsFeed().listen(
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

  Future<void> _onRefreshFeed(RefreshFeedEvent event, Emitter<FeedState> emit) async {
    // Keep current state while refreshing
    add(const LoadFeedEvent());
  }

  Future<void> _onCreatePost(CreatePostEvent event, Emitter<FeedState> emit) async {
    emit(const PostCreating());
    try {
      final user = firebase_auth.FirebaseAuth.instance.currentUser;
      await _postService.createPost(
        userId: user?.uid ?? '',
        userName: user?.displayName ?? user?.email ?? 'User',
        userPhotoUrl: user?.photoURL,
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
      final userId = firebase_auth.FirebaseAuth.instance.currentUser?.uid ?? '';
      await _postService.toggleLike(event.postId, userId);
    } catch (e) {
      // Silent fail - the stream will update anyway
    }
  }

  Future<void> _onAddComment(AddCommentEvent event, Emitter<FeedState> emit) async {
    try {
      final user = firebase_auth.FirebaseAuth.instance.currentUser;
      await _postService.addComment(
        postId: event.postId,
        userId: user?.uid ?? '',
        userName: user?.displayName ?? user?.email ?? 'User',
        userPhotoUrl: user?.photoURL,
        content: event.content,
      );
    } catch (e) {
      emit(FeedError(e.toString()));
    }
  }

  Future<void> _onDeletePost(DeletePostEvent event, Emitter<FeedState> emit) async {
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
