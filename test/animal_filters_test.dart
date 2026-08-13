import 'package:flutter_test/flutter_test.dart';
import 'package:adopt_animal/core/sample_data.dart';
import 'package:adopt_animal/features/adoption/presentation/pages/filter_sheet.dart';

Animal _a(String name, String species, String age, String city, String size) =>
    Animal(
      name: name,
      species: species,
      breed: "",
      age: age,
      city: city,
      photoLabel: "",
      size: size,
    );

void main() {
  final animals = [
    _a("A", "dog", "2 yr", "Cairo", "Small"),
    _a("B", "cat", "8 mo", "Giza", "Large"),
    _a("C", "dog", "5 yr", "Cairo", "Medium"),
  ];

  List<String> names(List<Animal> l) => l.map((a) => a.name).toList();

  test('species filter is case-insensitive', () {
    expect(names(applyAnimalFilters(animals, species: "Dog")), ["A", "C"]);
  });

  test('size filter', () {
    expect(names(applyAnimalFilters(animals, size: "Small")), ["A"]);
  });

  test('city filter', () {
    expect(names(applyAnimalFilters(animals, city: "Cairo")), ["A", "C"]);
  });

  test('age buckets', () {
    expect(names(applyAnimalFilters(animals, age: "<1 yr")), ["B"]);
    expect(names(applyAnimalFilters(animals, age: "1-3 yr")), ["A"]);
    expect(names(applyAnimalFilters(animals, age: "3+ yr")), ["C"]);
  });

  test('no filters returns everything', () {
    expect(applyAnimalFilters(animals).length, 3);
  });
}
