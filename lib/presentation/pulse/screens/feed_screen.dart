import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:student_link_app/core/constants/colors.dart';
import 'package:student_link_app/presentation/common/widgets/glass_container.dart';
import 'package:student_link_app/core/utils/motion_utils.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:student_link_app/presentation/pulse/bloc/feed_bloc.dart';
import 'package:student_link_app/presentation/pulse/bloc/feed_event.dart';
import 'package:student_link_app/presentation/pulse/bloc/feed_state.dart';
import 'package:student_link_app/domain/entities/post.dart';
import 'package:student_link_app/data/datasources/post_service.dart';
import 'package:student_link_app/data/datasources/firebase_auth_service.dart';
import 'package:student_link_app/core/di/injection.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:cached_network_image/cached_network_image.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class FeedScreen extends StatelessWidget {
  const FeedScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => FeedBloc(postService: getIt<PostService>())
        ..add(const LoadFeedEvent()),
      child: const _FeedScreenContent(),
    );
  }
}

class _FeedScreenContent extends StatelessWidget {
  const _FeedScreenContent();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Campus Pulse'),
        actions: [
          IconButton(
            icon: const Icon(CupertinoIcons.bell),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(CupertinoIcons.search),
            onPressed: () {},
          )
        ],
      ),
      body: BlocConsumer<FeedBloc, FeedState>(
        listener: (context, state) {
          if (state is PostCreated) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Post created successfully!'),
                backgroundColor: AppColors.success,
              ),
            );
          } else if (state is FeedError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: AppColors.error,
              ),
            );
          }
        },
        builder: (context, state) {
          if (state is FeedLoading) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            );
          }

          if (state is FeedError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline,
                      size: 48, color: AppColors.error),
                  const SizedBox(height: 16),
                  Text(state.message),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () =>
                        context.read<FeedBloc>().add(const LoadFeedEvent()),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          if (state is FeedLoaded) {
            if (state.posts.isEmpty) {
              return const Center(
                child: Text('No posts yet. Be the first to post!'),
              );
            }

            return RefreshIndicator(
              color: AppColors.primary,
              onRefresh: () async {
                context.read<FeedBloc>().add(const RefreshFeedEvent());
                await Future.delayed(const Duration(seconds: 1));
              },
              child: ListView.builder(
                physics: const BouncingScrollPhysics(),
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                itemCount: state.posts.length,
                itemBuilder: (context, index) {
                  return MotionUtils.listLoadEffect(
                    PostCard(post: state.posts[index]),
                    index,
                  );
                },
              ),
            );
          }

          return const SizedBox.shrink();
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showCreatePostDialog(context),
        child: const Icon(CupertinoIcons.pencil),
      ).animate().scale(delay: 400.ms, duration: 300.ms),
    );
  }

  void _showCreatePostDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (modalContext) => BlocProvider.value(
        value: context.read<FeedBloc>(),
        child: const CreatePostSheet(),
      ),
    );
  }
}

class CreatePostSheet extends StatefulWidget {
  const CreatePostSheet({Key? key}) : super(key: key);

  @override
  State<CreatePostSheet> createState() => _CreatePostSheetState();
}

class _CreatePostSheetState extends State<CreatePostSheet> {
  final _contentController = TextEditingController();
  final _imagePicker = ImagePicker();
  File? _selectedImage;
  bool _isUploading = false;

  @override
  void dispose() {
    _contentController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final pickedFile =
        await _imagePicker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
      });
    }
  }

  Future<void> _createPost() async {
    if (_contentController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter some content')),
      );
      return;
    }

    setState(() => _isUploading = true);

    String? imageUrl;
    if (_selectedImage != null) {
      // Upload image would happen here - for now we'll just pass null
      // imageUrl = await uploadImage(_selectedImage!);
    }

    context.read<FeedBloc>().add(CreatePostEvent(
          content: _contentController.text.trim(),
          imageUrl: imageUrl,
        ));

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Create Post',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _contentController,
              maxLines: 5,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                hintText: 'What\'s on your mind?',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            if (_selectedImage != null)
              Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.file(
                      _selectedImage!,
                      height: 150,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    ),
                  ),
                  Positioned(
                    top: 8,
                    right: 8,
                    child: GestureDetector(
                      onTap: () => setState(() => _selectedImage = null),
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(
                          color: Colors.black54,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.close,
                            color: Colors.white, size: 16),
                      ),
                    ),
                  ),
                ],
              ),
            const SizedBox(height: 16),
            Row(
              children: [
                IconButton(
                  icon: const Icon(CupertinoIcons.photo,
                      color: AppColors.primary),
                  onPressed: _pickImage,
                ),
                const Spacer(),
                ElevatedButton(
                  onPressed: _isUploading ? null : _createPost,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 32, vertical: 12),
                  ),
                  child: _isUploading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Text('Post'),
                ),
              ],
            ),
          ],
        ),
      ),
    ).animate().slideY(begin: 1, duration: 300.ms, curve: Curves.easeOutCubic);
  }
}

class PostCard extends StatelessWidget {
  final Post post;

  const PostCard({Key? key, required this.post}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final currentUserId = getIt<FirebaseAuthService>().currentUser?.uid ?? '';
    final hasLiked = post.likedBy.contains(currentUserId);

    return GlassContainer(
      margin: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                backgroundColor: AppColors.primary,
                backgroundImage: post.userPhotoUrl != null
                    ? CachedNetworkImageProvider(post.userPhotoUrl!)
                    : null,
                child: post.userPhotoUrl == null
                    ? const Icon(Icons.person, color: Colors.white)
                    : null,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      post.userName,
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    Text(
                      timeago.format(post.createdAt),
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            fontSize: 12,
                            color: AppColors.secondaryText,
                          ),
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.more_horiz,
                    color: AppColors.secondaryText),
                onPressed: () => _showPostOptions(context),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            post.content,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          if (post.imageUrls.isNotEmpty) ...[
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: CachedNetworkImage(
                imageUrl: post.imageUrls.first,
                fit: BoxFit.cover,
                width: double.infinity,
                height: 200,
                placeholder: (context, url) => Container(
                  height: 200,
                  color: AppColors.surface,
                  child: const Center(
                    child: CircularProgressIndicator(color: AppColors.primary),
                  ),
                ),
                errorWidget: (context, url, error) => Container(
                  height: 200,
                  color: AppColors.surface,
                  child: const Icon(Icons.error),
                ),
              ),
            ),
          ],
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildInteractionButton(
                hasLiked ? CupertinoIcons.heart_fill : CupertinoIcons.heart,
                post.likesCount.toString(),
                context,
                hasLiked ? AppColors.error : AppColors.secondaryText,
                onTap: () =>
                    context.read<FeedBloc>().add(LikePostEvent(post.id)),
              ),
              _buildInteractionButton(
                CupertinoIcons.chat_bubble,
                post.commentsCount.toString(),
                context,
                AppColors.secondaryText,
                onTap: () => _showCommentsSheet(context),
              ),
              _buildInteractionButton(
                CupertinoIcons.paperplane,
                "Share",
                context,
                AppColors.secondaryText,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInteractionButton(
    IconData icon,
    String label,
    BuildContext context,
    Color color, {
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Row(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 6),
          Text(label, style: Theme.of(context).textTheme.bodyMedium),
        ],
      ),
    );
  }

  void _showPostOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.delete, color: AppColors.error),
              title: const Text('Delete Post'),
              onTap: () {
                context.read<FeedBloc>().add(DeletePostEvent(post.id));
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.report, color: AppColors.warning),
              title: const Text('Report Post'),
              onTap: () => Navigator.pop(context),
            ),
          ],
        ),
      ),
    );
  }

  void _showCommentsSheet(BuildContext context) {
    final commentController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (modalContext) => BlocProvider.value(
        value: context.read<FeedBloc>(),
        child: Container(
          height: MediaQuery.of(context).size.height * 0.7,
          decoration: const BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Comments',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(modalContext),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1),
              Expanded(
                child: post.commentsCount == 0
                    ? const Center(child: Text('No comments yet'))
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: post.commentsCount,
                        itemBuilder: (context, index) {
                          return const ListTile(
                            title: Text('Sample comment'),
                            subtitle: Text('2 hours ago'),
                          );
                        },
                      ),
              ),
              const Divider(height: 1),
              Container(
                padding: EdgeInsets.only(
                  left: 16,
                  right: 16,
                  top: 8,
                  bottom: MediaQuery.of(context).viewInsets.bottom + 8,
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: commentController,
                        decoration: const InputDecoration(
                          hintText: 'Add a comment...',
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      icon: const Icon(Icons.send, color: AppColors.primary),
                      onPressed: () {
                        if (commentController.text.trim().isNotEmpty) {
                          context.read<FeedBloc>().add(AddCommentEvent(
                                postId: post.id,
                                content: commentController.text.trim(),
                              ));
                          commentController.clear();
                        }
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
