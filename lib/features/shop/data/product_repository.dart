import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:adopt_animal/core/sample_data.dart';

class ProductRepository {
  final CollectionReference<Map<String, dynamic>> _col =
      FirebaseFirestore.instance.collection('products');

  Stream<List<Product>> watch() {
    return _col.snapshots().map(
        (snap) => snap.docs.map((d) => productFromMap(d.data(), id: d.id)).toList());
  }

  Future<void> add({
    required String name,
    required String category,
    required String description,
    required int price,
    bool inStock = true,
  }) async {
    await _col.add({
      'name': name,
      'category': category,
      'description': description,
      'price': price,
      'rating': 0,
      'reviews': 0,
      'inStock': inStock,
      'photoLabel': 'product',
    });
  }

  Future<void> delete(String id) async {
    await _col.doc(id).delete();
  }
}
