import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ChatMessage {
  final bool me;
  final String text;
  final String? imageUrl;
  final String time;
  ChatMessage({required this.me, required this.text, this.imageUrl, this.time = ""});
}

class ChatRepository {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  String get _uid => FirebaseAuth.instance.currentUser?.uid ?? 'anonymous';

  String chatIdFor(String vetKey) {
    final parts = [_uid, vetKey]..sort();
    return parts.join('_');
  }

  Stream<List<ChatMessage>> watch(String chatId) {
    return _db
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .orderBy('createdAt')
        .snapshots()
        .map((snap) => snap.docs.map((d) {
              final m = d.data();
              return ChatMessage(
                me: (m['senderId'] ?? '') == _uid,
                text: (m['text'] ?? '') as String,
                imageUrl: m['imageUrl'] as String?,
              );
            }).toList());
  }

  Future<void> send(String chatId, String text) async {
    final chat = _db.collection('chats').doc(chatId);
    await chat.set({
      'participants': [_uid],
      'lastMessage': text,
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
    await chat.collection('messages').add({
      'senderId': _uid,
      'text': text,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }
}
