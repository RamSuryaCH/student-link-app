import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:student_link_app/core/constants/colors.dart';
import 'package:student_link_app/presentation/common/widgets/glass_container.dart';
import 'package:get_it/get_it.dart';
import '../../../data/datasources/anonymous_post_service.dart';
import '../../../data/datasources/firebase_auth_service.dart';
import '../../../domain/entities/anonymous_post.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:timeago/timeago.dart' as timeago;

class AnonySpaceScreen extends StatefulWidget {
  const AnonySpaceScreen({Key? key}) : super(key: key);

  @override
  State<AnonySpaceScreen> createState() => _AnonySpaceScreenState();
}

class _AnonySpaceScreenState extends State<AnonySpaceScreen> {
  final anonymousPostService = GetIt.I<AnonymousPostService>();
  final authService = GetIt.I<FirebaseAuthService>();
  final TextEditingController _postController = TextEditingController();

  @override
  void dispose() {
    _postController.dispose();
    super.dispose();
  }

  void _showCreatePostDialog() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: GlassContainer(
          margin: const EdgeInsets.all(16),
          height: null,
          borderRadius: 24,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Post Anonymously',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(CupertinoIcons.xmark_circle,  color: AppColors.secondaryText),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.background.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    const Icon(CupertinoIcons.info_circle, color: AppColors.warning, size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Your identity is hidden, but content is moderated',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontSize: 12),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _postController,
                maxLines: 5,
                maxLength: 500,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: 'Share your thoughts anonymously...',
                  filled: true,
                  fillColor: AppColors.surface.withOpacity(0.5),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Container(
                decoration: BoxDecoration(
                  gradient: AppColors.primaryGradient,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ElevatedButton(
                  onPressed: () async {
                    if (_postController.text.trim().isEmpty) return;

                    final currentUser = authService.currentUser;
                    if (currentUser != null) {
                      try {
                        await anonymousPostService.createAnonymousPost(
                          userId: currentUser.uid,
                          content: _postController.text.trim(),
                        );
                        _postController.clear();
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Post created successfully!'),
                            backgroundColor: AppColors.success,
                          ),
                        );
                      } catch (e) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Error: $e'),
                            backgroundColor: AppColors.error,
                          ),
                        );
                      }
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: const Text(
                    'POST ANONYMOUSLY',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('AnonySpace'),
        actions: [
          IconButton(
            icon: const Icon(CupertinoIcons.info_circle),
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  backgroundColor: AppColors.surface,
                  title: const Text('About AnonySpace'),
                  content: const Text(
                    'AnonySpace allows you to share thoughts anonymously. '
                    'Your identity is protected, but all content is moderated. '
                    'Abusive content will be removed and may result in account suspension.',
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Got it', style: TextStyle(color: AppColors.primary)),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
      body: StreamBuilder<List<AnonymousPost>>(
        stream: anonymousPostService.getAnonymousPostsFeed(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(CupertinoIcons.eye_slash, size: 64, color: AppColors.secondaryText),
                  const SizedBox(height: 16),
                  Text(
                    'No anonymous posts yet',
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Be the first to share something',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            color: AppColors.primary,
            onRefresh: () async {
              setState(() {});
            },
            child: ListView.builder(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              itemCount: snapshot.data!.length,
              itemBuilder: (context, index) {
                final post = snapshot.data![index];
                return _buildAnonymousPostCard(post)
                    .animate()
                    .fadeIn(delay: (index * 50).ms)
                    .slideY(begin: 0.1, end: 0);
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showCreatePostDialog,
        icon: const Icon(CupertinoIcons.eye_slash_fill),
        label: const Text('Post Anonymously'),
      ).animate().scale(delay: 400.ms, duration: 300.ms),
    );
  }

  Widget _buildAnonymousPostCard(AnonymousPost post) {
    final currentUser = authService.currentUser;
    final hasUpvoted = currentUser != null && post.upvotedBy.contains(currentUser.uid);
    final hasDownvoted = currentUser != null && post.downvotedBy.contains(currentUser.uid);

    return GlassContainer(
      margin: const EdgeInsets.only(bottom: 16),
      height: null,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: const BoxDecoration(
                  color: AppColors.primary,
                  shape: BoxShape.circle,
                ),
                child: const Icon(CupertinoIcons.person_fill, color: Colors.white, size: 20),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Anonymous',
                    style: TextStyle(
                      color: AppColors.primaryText,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    timeago.format(post.createdAt),
                    style: const TextStyle(
                      color: AppColors.secondaryText,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
              const Spacer(),
              PopupMenuButton(
                icon: const Icon(Icons.more_horiz, color: AppColors.secondaryText),
                color: AppColors.surface,
                itemBuilder: (context) => [
                  const PopupMenuItem(
                    value: 'report',
                    child: Row(
                      children: [
                        Icon(CupertinoIcons.exclamationmark_triangle, color: AppColors.error),
                        SizedBox(width: 8),
                        Text('Report'),
                      ],
                    ),
                  ),
                ],
                onSelected: (value) async {
                  if (value == 'report') {
                    await anonymousPostService.reportPost(post.id);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Post reported for moderation'),
                        backgroundColor: AppColors.warning,
                      ),
                    );
                  }
                },
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Content
          Text(
            post.content,
            style: const TextStyle(color: AppColors.primaryText, fontSize: 15),
          ),
          const SizedBox(height: 16),

          // Interaction buttons
          Row(
            children: [
              _buildVoteButton(
                icon: hasUpvoted ? CupertinoIcons.arrow_up_circle_fill : CupertinoIcons.arrow_up_circle,
                count: post.upvotes,
                color: hasUpvoted ? AppColors.success : AppColors.secondaryText,
                onTap: () async {
                  if (currentUser != null) {
                    await anonymousPostService.toggleUpvote(post.id, currentUser.uid);
                  }
                },
              ),
              const SizedBox(width: 16),
              _buildVoteButton(
                icon: hasDownvoted ? CupertinoIcons.arrow_down_circle_fill : CupertinoIcons.arrow_down_circle,
                count: post.downvotes,
                color: hasDownvoted ? AppColors.error : AppColors.secondaryText,
                onTap: () async {
                  if (currentUser != null) {
                    await anonymousPostService.toggleDownvote(post.id, currentUser.uid);
                  }
                },
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  'Score: ${post.upvotes - post.downvotes}',
                  style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold, fontSize: 12),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildVoteButton({
    required IconData icon,
    required int count,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        child: Row(
          children: [
            Icon(icon, color: color, size: 22),
            const SizedBox(width: 4),
            Text(
              count.toString(),
              style: TextStyle(color: color, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}
