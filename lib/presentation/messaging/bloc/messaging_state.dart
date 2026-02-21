import 'package:equatable/equatable.dart';
import 'package:student_link_app/domain/entities/chat_room.dart';
import 'package:student_link_app/domain/entities/message.dart';

abstract class MessagingState extends Equatable {
  const MessagingState();

  @override
  List<Object?> get props => [];
}

class MessagingInitial extends MessagingState {
  const MessagingInitial();
}

class ChatRoomsLoading extends MessagingState {
  const ChatRoomsLoading();
}

class ChatRoomsLoaded extends MessagingState {
  final List<ChatRoom> chatRooms;

  const ChatRoomsLoaded(this.chatRooms);

  @override
  List<Object?> get props => [chatRooms];
}

class MessagesLoading extends MessagingState {
  const MessagesLoading();
}

class MessagesLoaded extends MessagingState {
  final List<Message> messages;

  const MessagesLoaded(this.messages);

  @override
  List<Object?> get props => [messages];
}

class MessagingError extends MessagingState {
  final String message;

  const MessagingError(this.message);

  @override
  List<Object?> get props => [message];
}
