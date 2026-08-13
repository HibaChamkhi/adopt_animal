import 'package:flutter_test/flutter_test.dart';
import 'package:adopt_animal/core/cart_service.dart';
import 'package:adopt_animal/core/sample_data.dart';

Product _p(String name, int price) => Product(
      name: name,
      category: "Food",
      photoLabel: "x",
      description: "",
      price: price,
      rating: 0,
      reviews: 0,
    );

void main() {
  group('CartService', () {
    test('adds a new item', () {
      final c = CartService();
      c.add(_p("A", 100));
      expect(c.items.length, 1);
      expect(c.count, 1);
      expect(c.subtotal, 100);
    });

    test('merges quantity for the same product', () {
      final c = CartService();
      c.add(_p("A", 100));
      c.add(_p("A", 100), 2);
      expect(c.items.length, 1);
      expect(c.count, 3);
      expect(c.subtotal, 300);
    });

    test('inc / dec adjust quantity but never below 1', () {
      final c = CartService();
      c.add(_p("A", 100));
      c.inc(c.items.first);
      expect(c.count, 2);
      c.dec(c.items.first);
      expect(c.count, 1);
      c.dec(c.items.first);
      expect(c.count, 1);
    });

    test('delivery fee and total', () {
      final c = CartService();
      expect(c.deliveryFee, 0);
      expect(c.total, 0);
      c.add(_p("A", 100));
      c.add(_p("B", 50));
      expect(c.subtotal, 150);
      expect(c.deliveryFee, 40);
      expect(c.total, 190);
    });

    test('remove and clear', () {
      final c = CartService();
      c.add(_p("A", 100));
      c.removeItem(c.items.first);
      expect(c.items, isEmpty);
      expect(c.deliveryFee, 0);
      c.add(_p("B", 30));
      c.clear();
      expect(c.items, isEmpty);
      expect(c.count, 0);
    });
  });
}
