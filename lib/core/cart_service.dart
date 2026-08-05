import 'package:flutter/foundation.dart';
import 'sample_data.dart';

class CartItem {
  final Product product;
  int qty;
  CartItem(this.product, this.qty);
}

/// Simple in-memory cart shared across the shop screens.
class CartService extends ChangeNotifier {
  final List<CartItem> items = [];

  void add(Product p, [int qty = 1]) {
    final idx = items.indexWhere((e) => e.product.name == p.name);
    if (idx >= 0) {
      items[idx].qty += qty;
    } else {
      items.add(CartItem(p, qty));
    }
    notifyListeners();
  }

  void inc(CartItem it) {
    it.qty++;
    notifyListeners();
  }

  void dec(CartItem it) {
    if (it.qty > 1) {
      it.qty--;
      notifyListeners();
    }
  }

  void removeItem(CartItem it) {
    items.remove(it);
    notifyListeners();
  }

  void clear() {
    items.clear();
    notifyListeners();
  }

  int get count => items.fold(0, (s, e) => s + e.qty);
  int get subtotal => items.fold(0, (s, e) => s + e.product.price * e.qty);
  int get deliveryFee => items.isEmpty ? 0 : 40;
  int get total => subtotal + deliveryFee;
}

final cart = CartService();
