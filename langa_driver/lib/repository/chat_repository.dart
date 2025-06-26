import 'package:cloud_firestore/cloud_firestore.dart';

class ChatRepository {
  final FirebaseFirestore _firestore;

  // Make firestore a required named parameter in the constructor
  ChatRepository({required FirebaseFirestore firestore})
      : _firestore = firestore;

  /// Generates a unique and consistent chat room ID from two user IDs.
  String getChatRoomId(String driverId, String customerId) {
    if (driverId.hashCode <= customerId.hashCode) {
      return '${driverId}_${customerId}';
    } else {
      return '${customerId}_${driverId}';
    }
  }

  /// Sends a message to a specific chat room.
  Future<void> sendMessage({
    required String chatRoomId,
    required String deliveryId,
    required String senderId,
    required String text,
    required List<String> participants,
  }) async {
    if (text.trim().isEmpty) {
      return; // Do not send empty messages
    }

    final DocumentReference chatDocRef =
        _firestore.collection('chats').doc(chatRoomId);
    final CollectionReference messagesRef = chatDocRef.collection('messages');
    final Timestamp timestamp = Timestamp.now();

    // The data for the new message
    final Map<String, dynamic> messageData = {
      'senderId': senderId,
      'text': text,
      'timestamp': timestamp,
    };

    // The data to update the main chat document
    final Map<String, dynamic> chatData = {
      'deliveryId': deliveryId,
      'participants': participants,
      'lastMessageText': text,
      'lastMessageTimestamp': timestamp,
      'lastMessageSenderId': senderId,
    };

    // Use a batched write to perform both operations atomically
    final WriteBatch batch = _firestore.batch();

    // 1. Set/update the chat room document
    batch.set(chatDocRef, chatData, SetOptions(merge: true));

    // 2. Add the new message to the messages subcollection
    batch.set(messagesRef.doc(), messageData);

    await batch.commit();
  }

  /// Returns a real-time stream of messages for a given chat room.
  Stream<QuerySnapshot> getChatMessagesStream(String chatRoomId,
      {int limit = 20}) {
    return _firestore
        .collection('chats')
        .doc(chatRoomId)
        .collection('messages')
        .orderBy('timestamp', descending: true)
        .limit(limit)
        .snapshots();
  }
}
