import 'package:flutter/material.dart';
import 'package:adopt_animal/core/app_icons.dart';
import 'package:adopt_animal/core/app_theme.dart';
import 'package:adopt_animal/core/sample_data.dart';
import 'package:adopt_animal/core/favorites_service.dart';
import 'package:adopt_animal/core/widgets/app_widgets.dart';
import 'package:adopt_animal/features/adoption/data/animal_repository.dart';
import 'package:adopt_animal/features/adoption/presentation/pages/animal_detail_page.dart';
import 'package:adopt_animal/features/adoption/presentation/pages/filter_sheet.dart';
import 'package:adopt_animal/features/adoption/presentation/pages/list_for_adoption_page.dart';

class AdoptPage extends StatefulWidget {
  const AdoptPage({super.key});

  @override
  State<AdoptPage> createState() => _AdoptPageState();
}

class _AdoptPageState extends State<AdoptPage> {
  int _category = 0;
  final _categories = const ["All", "Dogs", "Cats", "Small"];
  final _repo = AnimalRepository();
  final AnimalFilters _filters = AnimalFilters();
  List<Animal> _lastSource = const [];
  String _query = "";

  @override
  void initState() {
    super.initState();
    favorites.addListener(_onFav);
  }

  @override
  void dispose() {
    favorites.removeListener(_onFav);
    super.dispose();
  }

  void _onFav() {
    if (mounted) setState(() {});
  }

  List<Animal> _applyCategory(List<Animal> list) {
    List<Animal> out;
    switch (_category) {
      case 1:
        out = list.where((a) => a.species == "dog").toList();
        break;
      case 2:
        out = list.where((a) => a.species == "cat").toList();
        break;
      case 3:
        out = list.where((a) => a.size == "Small").toList();
        break;
      default:
        out = list;
    }
    var res = applyAnimalFilters(
      out,
      species: _filters.species,
      age: _filters.age,
      size: _filters.size,
      city: _filters.city,
    );
    final q = _query.trim().toLowerCase();
    if (q.isNotEmpty) {
      res = res
          .where((a) =>
              a.name.toLowerCase().contains(q) ||
              a.breed.toLowerCase().contains(q))
          .toList();
    }
    return res;
  }

  Future<void> _openFilters(List<Animal> source) async {
    final res = await showModalBottomSheet<AnimalFilters>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => FilterSheet(current: _filters, source: source),
    );
    if (res != null) {
      setState(() {
        _filters.species = res.species;
        _filters.age = res.age;
        _filters.size = res.size;
        _filters.city = res.city;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text("Adopt", style: AppText.heading),
                GestureDetector(
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => const ListForAdoptionPage()),
                  ),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 10),
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        AppIcon(AppIcons.add, size: 18, color: Colors.white),
                        SizedBox(width: 6),
                        Text("List a pet",
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w700,
                                fontSize: 14)),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: AppSearchField(
                    hint: "Search breed, name...",
                    onChanged: (v) => setState(() => _query = v),
                  ),
                ),
                const SizedBox(width: 12),
                GestureDetector(
                  onTap: () => _openFilters(
                      _lastSource),
                  child: Container(
                    width: 54,
                    height: 54,
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Center(
                      child: AppIcon(AppIcons.tune, size: 24, color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  for (int i = 0; i < _categories.length; i++) ...[
                    SelectableChip(
                      label: _categories[i],
                      selected: _category == i,
                      onTap: () => setState(() => _category = i),
                    ),
                    if (i != _categories.length - 1) const SizedBox(width: 12),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: StreamBuilder<List<Animal>>(
                stream: _repo.watchAvailable(),
                builder: (context, snap) {
                  if (snap.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  final source = snap.data ?? const <Animal>[];
                  _lastSource = source;
                  final animals = _applyCategory(source);
                  if (animals.isEmpty) {
                    return const EmptyState(
                      icon: Icons.pets,
                      title: "No animals yet",
                      subtitle: "Listings will appear here once they're added.",
                    );
                  }
                  return GridView.builder(
                    padding: const EdgeInsets.only(bottom: 16),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      mainAxisSpacing: 14,
                      crossAxisSpacing: 14,
                      childAspectRatio: 0.68,
                    ),
                    itemCount: animals.length,
                    itemBuilder: (context, i) {
                      final a = animals[i];
                      return PetCard(
                        name: a.name,
                        subtitle: "${a.breed} · ${a.age}",
                        city: a.city,
                        placeholderLabel: a.photoLabel,
                        imageUrl: a.photoUrl,
                        imageBase64: a.photoBase64,
                        isFavorite: favorites.contains(a.name),
                        onFavorite: () => favorites.toggle(a.name),
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => AnimalDetailPage(animal: a)),
                        ).then((_) => setState(() {})),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
