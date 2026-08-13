import 'package:flutter_test/flutter_test.dart';
import 'package:adopt_animal/core/sample_data.dart';

void main() {
  group('animalFromMap', () {
    test('parses fields and carries the id', () {
      final a = animalFromMap('id1', {
        'name': 'Bella',
        'species': 'dog',
        'breed': 'Labrador',
        'age': '3 yr',
        'city': 'Cairo',
        'status': 'available',
        'photoBase64': 'abc',
      });
      expect(a.id, 'id1');
      expect(a.name, 'Bella');
      expect(a.species, 'dog');
      expect(a.photoBase64, 'abc');
    });

    test('applies defaults for missing fields', () {
      final a = animalFromMap('x', {});
      expect(a.name, '');
      expect(a.species, 'dog');
      expect(a.status, 'available');
      expect(a.photoBase64, '');
    });
  });

  group('productFromMap', () {
    test('parses numbers and id', () {
      final p = productFromMap({
        'name': 'Food',
        'price': 450,
        'rating': 4.8,
        'reviews': 10,
        'inStock': false,
      }, id: 'p1');
      expect(p.id, 'p1');
      expect(p.price, 450);
      expect(p.rating, 4.8);
      expect(p.inStock, false);
    });

    test('defaults: price 0, inStock true', () {
      final p = productFromMap({});
      expect(p.price, 0);
      expect(p.inStock, true);
    });
  });

  group('vetFromMap', () {
    test('parses id and price, defaults initials', () {
      final v = vetFromMap({'name': 'Dr X', 'price': 250}, id: 'v1');
      expect(v.id, 'v1');
      expect(v.price, 250);
      expect(v.initials, '?');
    });
  });
}
