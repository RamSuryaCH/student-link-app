import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:student_link_app/data/datasources/messaging_service.dart';
import 'package:student_link_app/presentation/messaging/bloc/messaging_event.dart';
import 'package:student_link_app/presentation/messaging/bloc/messaging_state.dart';

class MessagingBloc extends Bloc<MessagingEvent, MessagingState> {
  final MessagingService _messagingService;
  StreamSubscription? _chatRoomsSubscription;
  StreamSubscription? _messagesSubscription;

  MessagingBloc({required MessagingService messagingService})
      : _messagingService = messagingService,
        super(const MessagingInitial()) {
    on<LoadChatRoomsEvent>(_onLoadChatRooms);
    on<LoadMessagesEvent>(_onLoadMessages);
    on<SendMessageEvent>(_onSendMessage);
    on<MarkMessagesAsReadEvent>(_onMarkMessagesAsRead);
  }

  Future<void> _onLoadChatRooms(
    LoadChatRoomsEvent event,
    Emitter<MessagingState> emit,
  ) async {
    emit(const ChatRoomsLoading());
    try {
      await _chatRoomsSubscription?.cancel();
      final userId = firebase_auth.FirebaseAuth.instance.currentUser?.uid ?? '';
      _chatRoomsSubscription = _messagingService.getUserChatRooms(userId).listen(
        (chatRooms) {
          if (!isClosed) {
            emit(ChatRoomsLoaded(chatRooms));
          }
        },
        onError: (error) {
          if (!isClosed) {
            emit(MessagingError(error.toString()));
          }
        },
      );
    } catch (e) {
      emit(MessagingError(e.toString()));
    }
  }

  Future<void> _onLoadMessages(
    LoadMessagesEvent event,
    Emitter<MessagingState> emit,
  ) async {
    emit(const MessagesLoading());
    try {
      await _messagesSubscription?.cancel();
      _messagesSubscription = _messagingService.getMessages(event.chatRoomId).listen(
        (messages) {
          if (!isClosed) {
            emit(MessagesLoaded(messages));
          }
        },
        onError: (error) {
          if (!isClosed) {
            emit(MessagingError(error.toString()));
          }
        },
      );
    } catch (e) {
      emit(MessagingError(e.toString()));
    }
  }

  Future<void> _onSendMessage(
    SendMessageEvent event,
    Emitter<MessagingState> emit,
  ) async {
    try {
      final currentUserId = firebase_auth.FirebaseAuth.instance.currentUser?.uid ?? '';
      final parts = event.chatRoomId.split('_');
      final receiverId = parts.firstWhere(
        (id) => id != currentUserId,
        orElse: () => parts.last,
      );
      await _messagingService.sendMessage(
        chatId: event.chatRoomId,
        senderId: currentUserId,
        receiverId: receiverId,
        content: event.content,
      );
    } catch (e) {
      emit(MessagingError(e.toString()));
    }
  }

  Future<void> _onMarkMessagesAsRead(
    MarkMessagesAsReadEvent event,
    Emitter<MessagingState> emit,
  ) async {
    try {
      final userId = firebase_auth.FirebaseAuth.instance.currentUser?.uid ?? '';
      await _messagingService.markMessagesAsRead(event.chatRoomId, userId);
    } catch (e) {
      // Silent fail
    }
  }

  @override
  Future<void> close() {
    _chatRoomsSubscription?.cancel();
    _messagesSubscription?.cancel();
    return super.close();
  }
}
