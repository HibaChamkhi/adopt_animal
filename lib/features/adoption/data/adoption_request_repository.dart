import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AdoptionRequest {
  final String id;
  final String animalId;
  final String adopterName;
  final String animalName;
  final String message;
  final String status;
  AdoptionRequest({
    required this.id,
    required this.animalId,
    required this.adopterName,
    required this.animalName,
    required this.message,
    required this.status,
  });
}

/// Firestore-backed access to the `adoption_requests` collection.
class AdoptionRequestRepository {
  final CollectionReference<Map<String, dynamic>> _col =
      FirebaseFirestore.instance.collection('adoption_requests');

  Future<void> send({
    required String animalName,
    required String breed,
    required String ownerId,
    required String ownerName,
    required String message,
    required Map<String, bool> home,
    String animalId = '',
  }) async {
    final user = FirebaseAuth.instance.currentUser;
    await _col.add({
      'adopterId': user?.uid ?? 'anonymous',
      'adopterName': user?.displayName ?? 'You',
      'ownerId': ownerId,
      'ownerName': ownerName,
      'animalId': animalId,
      'animalName': animalName,
      'breed': breed,
      'message': message,
      'home': home,
      'status': 'pending',
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Stream<List<AdoptionRequest>> watchForOwner(String ownerId) {
    return _col.where('ownerId', isEqualTo: ownerId).snapshots().map((snap) =>
        snap.docs.map((d) {
          final m = d.data();
          return AdoptionRequest(
            id: d.id,
            animalId: (m['animalId'] ?? '') as String,
            adopterName: (m['adopterName'] ?? 'Someone') as String,
            animalName: (m['animalName'] ?? '') as String,
            message: (m['message'] ?? '') as String,
            status: (m['status'] ?? 'pending') as String,
          );
        }).toList());
  }

  Future<void> updateStatus(String id, String status) async {
    await _col.doc(id).update({'status': status});
  }
}
