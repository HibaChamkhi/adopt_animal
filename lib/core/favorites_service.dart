import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

/// Tracks the user's favorited animals, synced to
/// users/{uid}/favorites/{key} in Firestore.
class FavoritesService extends ChangeNotifier {
  final Set<String> _keys = {};

  bool contains(String key) => _keys.contains(key);

  CollectionReference<Map<String, dynamic>>? get _col {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return null;
    return FirebaseFirestore.instance.collection('users').doc(uid).collection('favorites');
  }

  Future<void> load() async {
    try {
      final c = _col;
      if (c == null) return;
      final snap = await c.get();
      _keys
        ..clear()
        ..addAll(snap.docs.map((d) => d.id));
      notifyListeners();
    } catch (_) {}
  }

  Future<void> toggle(String key) async {
    final was = _keys.contains(key);
    was ? _keys.remove(key) : _keys.add(key);
    notifyListeners();
    try {
      final c = _col;
      if (c == null) return;
      if (was) {
        await c.doc(key).delete();
      } else {
        await c.doc(key).set({'addedAt': FieldValue.serverTimestamp()});
      }
    } catch (_) {}
  }
}

final favorites = FavoritesService();
