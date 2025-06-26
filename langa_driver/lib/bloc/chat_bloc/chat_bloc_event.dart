import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart' show immutable;
import 'package:langas_driver/models/chat_model.dart';

@immutable
abstract class ChatEvent extends Equatable {
  const ChatEvent();
  @override
  List<Object?> get props => [];
}

class LoadChat extends ChatEvent {
  final String deliveryId;
  final String driverId;
  final String customerId;

  const LoadChat({
    required this.deliveryId,
    required this.driverId,
    required this.customerId,
  });

  @override
  List<Object?> get props => [deliveryId, driverId, customerId];
}

class SendMessage extends ChatEvent {
  final String text;

  const SendMessage({required this.text});

  @override
  List<Object?> get props => [text];
}

/// Internal event to push updates from the stream to the state
class MessagesUpdated extends ChatEvent {
  final List<ChatMessage> messages;

  const MessagesUpdated(this.messages);

  @override
  List<Object?> get props => [messages];
}
