import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:student_link_app/core/constants/colors.dart';
import 'package:student_link_app/presentation/common/widgets/glass_container.dart';
import 'package:student_link_app/presentation/messaging/bloc/messaging_bloc.dart';
import 'package:student_link_app/presentation/messaging/bloc/messaging_event.dart';
import 'package:student_link_app/presentation/messaging/bloc/messaging_state.dart';
import 'package:student_link_app/data/datasources/messaging_service.dart';
import 'package:student_link_app/core/di/injection.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class ChatDetailScreen extends StatelessWidget {
  final String chatRoomId;
  final String otherUserName;
  final String? otherUserPhotoUrl;

  const ChatDetailScreen({
    Key? key,
    required this.chatRoomId,
    required this.otherUserName,
    this.otherUserPhotoUrl,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => MessagingBloc(messagingService: getIt<MessagingService>())
        ..add(LoadMessagesEvent(chatRoomId))
        ..add(MarkMessagesAsReadEvent(chatRoomId)),
      child: _ChatDetailContent(
        chatRoomId: chatRoomId,
        otherUserName: otherUserName,
        otherUserPhotoUrl: otherUserPhotoUrl,
      ),
    );
  }
}

class _ChatDetailContent extends StatefulWidget {
  final String chatRoomId;
  final String otherUserName;
  final String? otherUserPhotoUrl;

  const _ChatDetailContent({
    required this.chatRoomId,
    required this.otherUserName,
    this.otherUserPhotoUrl,
  });

  @override
  State<_ChatDetailContent> createState() => _ChatDetailContentState();
}

class _ChatDetailContentState extends State<_ChatDetailContent> {
  final _messageController = TextEditingController();
  final _scrollController = ScrollController();
  final _imagePicker = ImagePicker();
  File? _selectedImage;

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final pickedFile = await _imagePicker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
      });
    }
  }

  void _sendMessage() {
    if (_messageController.text.trim().isEmpty && _selectedImage == null) {
      return;
    }

    String? imageUrl;
    // Upload image would happen here
    if (_selectedImage != null) {
      // imageUrl = await uploadImage(_selectedImage!);
    }

    context.read<MessagingBloc>().add(SendMessageEvent(
          chatRoomId: widget.chatRoomId,
          content: _messageController.text.trim(),
          imageUrl: imageUrl,
        ));

    _messageController.clear();
    setState(() => _selectedImage = null);
    
    // Scroll to bottom
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          0,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            CircleAvatar(
              radius: 16,
              backgroundColor: AppColors.accent,
              backgroundImage: widget.otherUserPhotoUrl != null
                  ? CachedNetworkImageProvider(widget.otherUserPhotoUrl!)
                  : null,
              child: widget.otherUserPhotoUrl == null
                  ? const Icon(Icons.person, size: 16, color: Colors.white)
                  : null,
            ),
            const SizedBox(width: 12),
            Text(widget.otherUserName),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(CupertinoIcons.video_camera),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(CupertinoIcons.phone),
            onPressed: () {},
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: BlocBuilder<MessagingBloc, MessagingState>(
              builder: (context, state) {
                if (state is MessagesLoading) {
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
                      ],
                    ),
                  );
                }

                if (state is MessagesLoaded) {
                  if (state.messages.isEmpty) {
                    return const Center(
                      child: Text('No messages yet. Start the conversation!'),
                    );
                  }

                  final currentUserId = getIt<MessagingService>().currentUserId ?? '';

                  return ListView.builder(
                    controller: _scrollController,
                    reverse: true,
                    padding: const EdgeInsets.all(16),
                    itemCount: state.messages.length,
                    itemBuilder: (context, index) {
                      final message = state.messages[index];
                      final isMe = message.senderId == currentUserId;
                      final showTimestamp = index == state.messages.length - 1 ||
                          state.messages[index + 1].senderId != message.senderId;

                      return Column(
                        crossAxisAlignment:
                            isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                        children: [
                          Align(
                            alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
                            child: ConstrainedBox(
                              constraints: BoxConstraints(
                                maxWidth: MediaQuery.of(context).size.width * 0.75,
                              ),
                              child: GlassContainer(
                                margin: const EdgeInsets.only(bottom: 4),
                                borderRadius: 16,
                                color: isMe
                                    ? AppColors.primary.withOpacity(0.3)
                                    : AppColors.surface.withOpacity(0.5),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    if (message.imageUrl != null) ...[
                                      ClipRRect(
                                        borderRadius: BorderRadius.circular(12),
                                        child: CachedNetworkImage(
                                          imageUrl: message.imageUrl!,
                                          fit: BoxFit.cover,
                                          width: double.infinity,
                                        ),
                                      ),
                                      if (message.content.isNotEmpty)
                                        const SizedBox(height: 8),
                                    ],
                                    if (message.content.isNotEmpty)
                                      Text(
                                        message.content,
                                        style: const TextStyle(color: Colors.white),
                                      ),
                                  ],
                                ),
                              ),
                            )
                                .animate()
                                .slideX(
                                  begin: isMe ? 0.2 : -0.2,
                                  duration: 300.ms,
                                  curve: Curves.easeOutCubic,
                                )
                                .fade(),
                          ),
                          if (showTimestamp)
                            Padding(
                              padding: const EdgeInsets.only(bottom: 8),
                              child: Text(
                                timeago.format(message.timestamp),
                                style: const TextStyle(
                                  fontSize: 11,
                                  color: AppColors.secondaryText,
                                ),
                              ),
                            ),
                        ],
                      );
                    },
                  );
                }

                return const SizedBox.shrink();
              },
            ),
          ),

          // Image Preview
          if (_selectedImage != null)
            Container(
              padding: const EdgeInsets.all(8),
              color: AppColors.surface,
              child: Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.file(
                      _selectedImage!,
                      height: 80,
                      width: 80,
                      fit: BoxFit.cover,
                    ),
                  ),
                  Positioned(
                    top: 0,
                    right: 0,
                    child: GestureDetector(
                      onTap: () => setState(() => _selectedImage = null),
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(
                          color: Colors.black54,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.close, color: Colors.white, size: 16),
                      ),
                    ),
                  ),
                ],
              ),
            ),

          // Chat Input Footer
          Container(
            padding: EdgeInsets.only(
              left: 16,
              right: 16,
              top: 8,
              bottom: MediaQuery.of(context).padding.bottom + 8,
            ),
            decoration: BoxDecoration(
              color: AppColors.surface,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.3),
                  blurRadius: 10,
                  offset: const Offset(0, -5),
                ),
              ],
            ),
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(
                    CupertinoIcons.photo,
                    color: AppColors.secondaryText,
                  ),
                  onPressed: _pickImage,
                ),
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    style: const TextStyle(color: Colors.white),
                    maxLines: null,
                    textInputAction: TextInputAction.newline,
                    decoration: InputDecoration(
                      hintText: "Type a message...",
                      filled: true,
                      fillColor: AppColors.background,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding:
                          const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                CircleAvatar(
                  backgroundColor: AppColors.primary,
                  child: IconButton(
                    icon: const Icon(
                      Icons.send,
                      color: Colors.white,
                      size: 20,
                    ),
                    onPressed: _sendMessage,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
