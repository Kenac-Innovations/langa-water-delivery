import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:langas_driver/bloc/chat_bloc/chat_bloc_event.dart';
import 'package:langas_driver/bloc/chat_bloc/chat_bloc_state.dart';
import 'package:langas_driver/models/chat_model.dart';
import 'package:langas_driver/repository/chat_repository.dart';

class ChatBloc extends Bloc<ChatEvent, ChatState> {
  final ChatRepository _chatRepository;
  StreamSubscription? _messagesSubscription;

  String? _chatRoomId;
  String? _deliveryId;
  String? _senderId;
  List<String>? _participants;

  ChatBloc({required ChatRepository chatRepository})
      : _chatRepository = chatRepository,
        super(ChatInitial()) {
    on<LoadChat>(_onLoadChat);
    on<SendMessage>(_onSendMessage);
    on<MessagesUpdated>(_onMessagesUpdated);
  }

  Future<void> _onLoadChat(LoadChat event, Emitter<ChatState> emit) async {
    emit(ChatLoading());
    await _messagesSubscription?.cancel();

    _chatRoomId =
        _chatRepository.getChatRoomId(event.driverId, event.customerId);
    _deliveryId = event.deliveryId;
    _senderId = event
        .driverId; // Assuming the driver is always the sender from this app
    _participants = [event.driverId, event.customerId];

    // FIX: Add a small delay to allow the platform channel to settle
    await Future.delayed(const Duration(milliseconds: 100));

    _messagesSubscription =
        _chatRepository.getChatMessagesStream(_chatRoomId!).listen((snapshot) {
      final messages =
          snapshot.docs.map((doc) => ChatMessage.fromSnapshot(doc)).toList();
      add(MessagesUpdated(messages));
    }, onError: (error) {
      emit(ChatError(message: "Failed to load messages: $error"));
    });
  }

  void _onMessagesUpdated(MessagesUpdated event, Emitter<ChatState> emit) {
    emit(ChatLoaded(messages: event.messages));
  }

  Future<void> _onSendMessage(
      SendMessage event, Emitter<ChatState> emit) async {
    if (_chatRoomId == null ||
        _senderId == null ||
        _deliveryId == null ||
        _participants == null) {
      emit(const ChatError(
          message: "Chat not initialized. Cannot send message."));
      return;
    }

    try {
      await _chatRepository.sendMessage(
        chatRoomId: _chatRoomId!,
        deliveryId: _deliveryId!,
        senderId: _senderId!,
        text: event.text,
        participants: _participants!,
      );
      // No need to emit a new state here, the stream listener will handle it
    } catch (e) {
      // Optionally emit an error state if sending fails
      print("Error sending message: $e");
    }
  }

  @override
  Future<void> close() {
    _messagesSubscription?.cancel();
    return super.close();
  }
}
