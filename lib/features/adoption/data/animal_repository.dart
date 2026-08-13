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

  /// Live stream of every animal (any status) — used by Saved.
  Stream<List<Animal>> watchAll() {
    return _col.snapshots().map(
        (snap) => snap.docs.map((d) => animalFromMap(d.id, d.data())).toList());
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
    String size = 'Medium',
    String weight = '-',
    String city = 'Cairo',
    String area = '',
    String description = '',
    String health = 'Vaccinated',
    List<String> photoUrls = const [],
    String photoBase64 = '',
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
      'city': city,
      'size': size,
      'weight': weight,
      'area': area,
      'description':
          description.trim().isEmpty ? 'Newly listed for adoption.' : description,
      'health': health.trim().isEmpty ? 'Vaccinated' : health,
      'photoLabel': '$species photo',
      'photoUrls': photoUrls,
      'photoBase64': photoBase64,
      'status': 'available',
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  /// Update a listing's status (e.g. 'adopted').
  Future<void> setStatus(String id, String status) async {
    await _col.doc(id).update({'status': status});
  }

  /// Edit an existing listing (owner only, enforced by security rules).
  Future<void> updateAnimal(
    String id, {
    required String name,
    required String species,
    required String breed,
    required String age,
    required String gender,
    String size = 'Medium',
    String weight = '-',
    String city = 'Cairo',
    String area = '',
    String description = '',
    String health = 'Vaccinated',
    String? photoBase64,
  }) async {
    final data = <String, dynamic>{
      'name': name,
      'species': species,
      'breed': breed,
      'age': age,
      'gender': gender,
      'size': size,
      'weight': weight,
      'city': city,
      'area': area,
      'description': description,
      'health': health,
      'photoLabel': '$species photo',
    };
    if (photoBase64 != null) data['photoBase64'] = photoBase64;
    await _col.doc(id).update(data);
  }

  /// Delete a listing (owner only, enforced by security rules).
  Future<void> delete(String id) async {
    await _col.doc(id).delete();
  }
}
