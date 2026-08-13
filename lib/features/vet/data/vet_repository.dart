import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:adopt_animal/core/sample_data.dart';

class VetRepository {
  final CollectionReference<Map<String, dynamic>> _col =
      FirebaseFirestore.instance.collection('vets');

  Stream<List<Vet>> watch() {
    return _col.snapshots().map(
        (snap) => snap.docs.map((d) => vetFromMap(d.data(), id: d.id)).toList());
  }

  Future<void> add({
    required String name,
    required String specialty,
    required String clinic,
    required String city,
    required String category,
    required int price,
    String phone = '',
  }) async {
    final initials = name
        .replaceAll(RegExp(r'^Dr\.?\s*', caseSensitive: false), '')
        .trim()
        .split(RegExp(r'\s+'))
        .where((w) => w.isNotEmpty)
        .take(2)
        .map((w) => w[0].toUpperCase())
        .join();
    await _col.add({
      'name': name,
      'specialty': specialty,
      'clinic': clinic,
      'city': city,
      'category': category,
      'price': price,
      'phone': phone,
      'initials': initials.isEmpty ? '?' : initials,
      'rating': 0,
      'availability': 'Available today',
      'about': specialty,
      'experience': '',
      'patients': '',
      'address': clinic,
      'hours': 'Sat-Thu · 10:00 AM - 8:00 PM',
    });
  }

  Future<void> delete(String id) async {
    await _col.doc(id).delete();
  }
}
