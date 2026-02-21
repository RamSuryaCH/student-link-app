import 'package:equatable/equatable.dart';

abstract class MessagingEvent extends Equatable {
  const MessagingEvent();

  @override
  List<Object?> get props => [];
}

class LoadChatRoomsEvent extends MessagingEvent {
  const LoadChatRoomsEvent();
}

class LoadMessagesEvent extends MessagingEvent {
  final String chatRoomId;

  const LoadMessagesEvent(this.chatRoomId);

  @override
  List<Object?> get props => [chatRoomId];
}

class SendMessageEvent extends MessagingEvent {
  final String chatRoomId;
  final String content;
  final String? imageUrl;

  const SendMessageEvent({
    required this.chatRoomId,
    required this.content,
    this.imageUrl,
  });

  @override
  List<Object?> get props => [chatRoomId, content, imageUrl];
}

class MarkMessagesAsReadEvent extends MessagingEvent {
  final String chatRoomId;

  const MarkMessagesAsReadEvent(this.chatRoomId);

  @override
  List<Object?> get props => [chatRoomId];
}
