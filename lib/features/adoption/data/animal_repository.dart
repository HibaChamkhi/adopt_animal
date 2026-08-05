import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:adopt_animal/core/sample_data.dart';

/// Firestore-backed access to the `animals` collection (adoption listings).
class AnimalRepository {
  final CollectionReference<Map<String, dynamic>> _col =
      FirebaseFirestore.instance.collection('animals');

  /// Live stream of available animals, newest first.
  Stream<List<Animal>> watchAvailable() {
    return _col
        .where('status', isEqualTo: 'available')
        .snapshots()
        .map((snap) => snap.docs.map((d) => animalFromMap(d.id, d.data())).toList());
  }

  /// Live stream of the current user's own listings.
  Stream<List<Animal>> watchMyListings(String uid) {
    return _col
        .where('ownerId', isEqualTo: uid)
        .snapshots()
        .map((snap) => snap.docs.map((d) => animalFromMap(d.id, d.data())).toList());
  }

  /// Post a new adoption listing owned by the current user.
  Future<void> addAnimal({
    required String name,
    required String species,
    required String breed,
    required String age,
    required String gender,
    List<String> photoUrls = const [],
  }) async {
    final user = FirebaseAuth.instance.currentUser;
    await _col.add({
      'ownerId': user?.uid ?? 'anonymous',
      'ownerName': user?.displayName ?? 'You',
      'name': name,
      'species': species,
      'breed': breed,
      'age': age,
      'gender': gender,
      'city': 'Cairo',
      'size': 'Medium',
      'weight': '-',
      'description': 'Newly listed for adoption.',
      'health': 'Vaccinated',
      'photoLabel': '$species photo',
      'photoUrls': photoUrls,
      'status': 'available',
      'createdAt': FieldValue.serverTimestamp(),
    });
  }
}
