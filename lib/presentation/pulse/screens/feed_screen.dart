import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:student_link_app/core/constants/colors.dart';
import 'package:student_link_app/presentation/common/widgets/glass_container.dart';
import 'package:student_link_app/core/utils/motion_utils.dart';
import 'package:flutter_animate/flutter_animate.dart';

class FeedScreen extends StatelessWidget {
  const FeedScreen({Key? key}) : super(key: key);

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
      body: RefreshIndicator(
        color: AppColors.primary,
        onRefresh: () async {
          // Add refresh logic connected to Firestore stream here
          await Future.delayed(const Duration(seconds: 1));
        },
        child: ListView.builder(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          itemCount: 10,
          itemBuilder: (context, index) {
            return MotionUtils.listLoadEffect(
              const PostCard(),
              index,
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        child: const Icon(CupertinoIcons.pencil),
      ).animate().scale(delay: 400.ms, duration: 300.ms),
    );
  }
}

class PostCard extends StatelessWidget {
  const PostCard({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GlassContainer(
      margin: const EdgeInsets.only(bottom: 16),
      height: 250, // dynamic in real app
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const CircleAvatar(
                backgroundColor: AppColors.primary,
                child: Icon(Icons.person, color: Colors.white),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("John Doe", style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold)),
                  Text("2 hours ago", style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontSize: 12)),
                ],
              ),
              const Spacer(),
              const Icon(Icons.more_horiz, color: AppColors.secondaryText),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            "Just finished my finals! What a crazy semester. Anyone heading down to the café later?",
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const Spacer(),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildInteractionButton(CupertinoIcons.heart, "124", context),
              _buildInteractionButton(CupertinoIcons.chat_bubble, "45", context),
              _buildInteractionButton(CupertinoIcons.share, "Share", context),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildInteractionButton(IconData icon, String label, BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: AppColors.secondaryText, size: 20),
        const SizedBox(width: 6),
        Text(label, style: Theme.of(context).textTheme.bodyMedium),
      ],
    );
  }
}
