import 'package:flutter/material.dart';
import 'package:adopt_animal/core/app_theme.dart';
import 'package:adopt_animal/core/sample_data.dart';
import 'package:adopt_animal/core/widgets/app_widgets.dart';

double _years(String age) {
  final n = double.tryParse(age.trim().split(' ').first) ?? 0;
  if (age.contains('mo')) return n / 12.0;
  return n;
}

/// Filter animals by the sheet's selections. Null = no constraint.
List<Animal> applyAnimalFilters(
  List<Animal> list, {
  String? species,
  String? age,
  String? size,
  String? city,
}) {
  return list.where((a) {
    if (species != null && a.species != species.toLowerCase()) return false;
    if (size != null && a.size != size) return false;
    if (city != null && city.isNotEmpty && a.city != city) return false;
    if (age != null) {
      final y = _years(a.age);
      if (age == '<1 yr' && y >= 1) return false;
      if (age == '1-3 yr' && (y < 1 || y > 3)) return false;
      if (age == '3+ yr' && y < 3) return false;
    }
    return true;
  }).toList();
}

class AnimalFilters {
  String? species;
  String? age;
  String? size;
  String? city;
  AnimalFilters({this.species, this.age, this.size, this.city});
  AnimalFilters copy() => AnimalFilters(species: species, age: age, size: size, city: city);
}

class FilterSheet extends StatefulWidget {
  final AnimalFilters current;
  final List<Animal> source;
  const FilterSheet({super.key, required this.current, required this.source});

  @override
  State<FilterSheet> createState() => _FilterSheetState();
}

class _FilterSheetState extends State<FilterSheet> {
  late AnimalFilters _f = widget.current.copy();
  final _cities = const ["Any", "Cairo", "Giza", "Alexandria"];

  int get _count => applyAnimalFilters(
        widget.source,
        species: _f.species,
        age: _f.age,
        size: _f.size,
        city: _f.city,
      ).length;

  String? _toggle(String? current, String value) => current == value ? null : value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
      decoration: const BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 44, height: 5,
              decoration: BoxDecoration(
                color: AppColors.stroke, borderRadius: BorderRadius.circular(4)),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text("Filters", style: AppText.heading),
              GestureDetector(
                onTap: () => setState(() => _f = AnimalFilters()),
                child: const Text("Reset",
                    style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.w600, fontSize: 15)),
              ),
            ],
          ),
          const SizedBox(height: 20),
          _group("Species", const ["Dog", "Cat", "Bird", "Other"], _f.species,
              (v) => setState(() => _f.species = _toggle(_f.species, v))),
          const SizedBox(height: 20),
          _group("Age", const ["<1 yr", "1-3 yr", "3+ yr"], _f.age,
              (v) => setState(() => _f.age = _toggle(_f.age, v))),
          const SizedBox(height: 20),
          _group("Size", const ["Small", "Medium", "Large"], _f.size,
              (v) => setState(() => _f.size = _toggle(_f.size, v))),
          const SizedBox(height: 20),
          const Text("City", style: AppText.secondary),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(16)),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: _f.city ?? "Any",
                isExpanded: true,
                icon: const Icon(Icons.expand_more, color: AppColors.textSecondary),
                style: AppText.body,
                items: _cities.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
                onChanged: (v) => setState(() => _f.city = (v == null || v == "Any") ? null : v),
              ),
            ),
          ),
          const SizedBox(height: 24),
          PrimaryButton(
            label: "Show $_count result${_count == 1 ? '' : 's'}",
            onTap: () => Navigator.pop(context, _f),
          ),
        ],
      ),
    );
  }

  Widget _group(String title, List<String> options, String? selected, ValueChanged<String> onTap) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: AppText.secondary),
        const SizedBox(height: 10),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: [
            for (final o in options)
              SelectableChip(label: o, selected: selected == o, onTap: () => onTap(o)),
          ],
        ),
      ],
    );
  }
}
