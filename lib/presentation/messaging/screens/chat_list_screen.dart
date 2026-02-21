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
import 'package:student_link_app/core/di/injection.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:cached_network_image/cached_network_image.dart';
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
                return GlassContainer(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: ListTile(
                    leading: Stack(
                      children: [
                        CircleAvatar(
                          radius: 28,
                          backgroundColor: AppColors.primary,
                          backgroundImage: chatRoom.otherUserPhotoUrl != null
                              ? CachedNetworkImageProvider(chatRoom.otherUserPhotoUrl!)
                              : null,
                          child: chatRoom.otherUserPhotoUrl == null
                              ? const Icon(Icons.person, color: Colors.white)
                              : null,
                        ),
                        if (chatRoom.unreadCount > 0)
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
                                chatRoom.unreadCount > 9 ? '9+' : '${chatRoom.unreadCount}',
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
                      chatRoom.otherUserName ?? 'Unknown',
                      style: TextStyle(
                        fontWeight: chatRoom.unreadCount > 0
                            ? FontWeight.bold
                            : FontWeight.normal,
                      ),
                    ),
                    subtitle: Text(
                      chatRoom.lastMessage ?? '',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: chatRoom.unreadCount > 0
                            ? Colors.white
                            : AppColors.secondaryText,
                      ),
                    ),
                    trailing: Text(
                      timeago.format(chatRoom.lastMessageTime ?? DateTime.now()),
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
                            otherUserName: chatRoom.otherUserName ?? 'Unknown',
                            otherUserPhotoUrl: chatRoom.otherUserPhotoUrl,
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
