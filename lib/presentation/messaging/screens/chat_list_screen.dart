import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:student_link_app/core/constants/colors.dart';
import 'package:student_link_app/presentation/common/widgets/glass_container.dart';
import 'package:student_link_app/presentation/messaging/bloc/messaging_bloc.dart';
import 'package:student_link_app/presentation/messaging/bloc/messaging_event.dart';
import 'package:student_link_app/presentation/messaging/bloc/messaging_state.dart';
import 'package:student_link_app/presentation/messaging/screens/chat_detail_screen.dart';
import 'package:student_link_app/data/datasources/messaging_service.dart';
import 'package:student_link_app/data/datasources/firebase_auth_service.dart';
import 'package:student_link_app/core/di/injection.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:flutter_animate/flutter_animate.dart';

class ChatListScreen extends StatelessWidget {
  const ChatListScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => MessagingBloc(messagingService: getIt<MessagingService>())
        ..add(const LoadChatRoomsEvent()),
      child: const _ChatListContent(),
    );
  }
}

class _ChatListContent extends StatelessWidget {
  const _ChatListContent();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Messages'),
        actions: [
          IconButton(
            icon: const Icon(CupertinoIcons.search),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(CupertinoIcons.add),
            onPressed: () {},
          ),
        ],
      ),
      body: BlocBuilder<MessagingBloc, MessagingState>(
        builder: (context, state) {
          if (state is ChatRoomsLoading) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            );
          }

          if (state is MessagingError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 48, color: AppColors.error),
                  const SizedBox(height: 16),
                  Text(state.message),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () =>
                        context.read<MessagingBloc>().add(const LoadChatRoomsEvent()),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          if (state is ChatRoomsLoaded) {
            if (state.chatRooms.isEmpty) {
              return const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(CupertinoIcons.chat_bubble_2, size: 64, color: AppColors.secondaryText),
                    SizedBox(height: 16),
                    Text('No messages yet'),
                    Text(
                      'Connect with people to start chatting',
                      style: TextStyle(color: AppColors.secondaryText),
                    ),
                  ],
                ),
              );
            }

            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: state.chatRooms.length,
              itemBuilder: (context, index) {
                final chatRoom = state.chatRooms[index];
                final currentUserId = getIt<FirebaseAuthService>().currentUser?.uid ?? '';
                final unreadCount = chatRoom.unreadCounts[currentUserId] ?? 0;
                final otherUserId = chatRoom.participantIds
                    .where((id) => id != currentUserId)
                    .isNotEmpty
                    ? chatRoom.participantIds.firstWhere((id) => id != currentUserId)
                    : chatRoom.participantIds.first;
                final otherUserName = 'User ${otherUserId.substring(0, 6)}';
                return GlassContainer(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: ListTile(
                    leading: Stack(
                      children: [
                        const CircleAvatar(
                          radius: 28,
                          backgroundColor: AppColors.primary,
                          child: Icon(Icons.person, color: Colors.white),
                        ),
                        if (unreadCount > 0)
                          Positioned(
                            right: 0,
                            top: 0,
                            child: Container(
                              padding: const EdgeInsets.all(4),
                              decoration: const BoxDecoration(
                                color: AppColors.error,
                                shape: BoxShape.circle,
                              ),
                              child: Text(
                                unreadCount > 9 ? '9+' : '$unreadCount',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                    title: Text(
                      otherUserName,
                      style: TextStyle(
                        fontWeight: unreadCount > 0
                            ? FontWeight.bold
                            : FontWeight.normal,
                      ),
                    ),
                    subtitle: Text(
                      chatRoom.lastMessage ?? '',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: unreadCount > 0
                            ? Colors.white
                            : AppColors.secondaryText,
                      ),
                    ),
                    trailing: Text(
                      timeago.format(chatRoom.lastMessageTime ?? chatRoom.createdAt),
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.secondaryText,
                      ),
                    ),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ChatDetailScreen(
                            chatRoomId: chatRoom.id,
                            otherUserName: otherUserName,
                            otherUserPhotoUrl: null,
                          ),
                        ),
                      );
                    },
                  ),
                ).animate().fadeIn(delay: (index * 50).ms);
              },
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }
}
