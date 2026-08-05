import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:adopt_animal/core/cart_service.dart';

class OrderSummary {
  final String id;
  final String status;
  final int itemCount;
  final int total;
  OrderSummary({required this.id, required this.status, required this.itemCount, required this.total});
}

class OrderRepository {
  final CollectionReference<Map<String, dynamic>> _col =
      FirebaseFirestore.instance.collection('orders');

  Future<void> placeOrder({
    required List<CartItem> items,
    required int subtotal,
    required int delivery,
    required int total,
  }) async {
    final uid = FirebaseAuth.instance.currentUser?.uid ?? 'anonymous';
    await _col.add({
      'userId': uid,
      'items': items
          .map((e) => {
                'productId': e.product.name,
                'name': e.product.name,
                'price': e.product.price,
                'qty': e.qty,
              })
          .toList(),
      'itemCount': items.fold<int>(0, (s, e) => s + e.qty),
      'subtotal': subtotal,
      'deliveryFee': delivery,
      'total': total,
      'paymentMethod': 'cod',
      'status': 'pending',
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Stream<List<OrderSummary>> watchMyOrders(String uid) {
    return _col.where('userId', isEqualTo: uid).snapshots().map((snap) =>
        snap.docs.map((d) {
          final m = d.data();
          return OrderSummary(
            id: d.id,
            status: (m['status'] ?? 'pending') as String,
            itemCount: (m['itemCount'] ?? 0) as int,
            total: (m['total'] ?? 0) as int,
          );
        }).toList());
  }
}
