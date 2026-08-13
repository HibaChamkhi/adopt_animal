import 'dart:async';

import 'package:flutter/material.dart';
import 'package:adopt_animal/core/app_icons.dart';
import 'package:adopt_animal/core/app_theme.dart';
import 'package:adopt_animal/core/sample_data.dart';
import 'package:adopt_animal/core/widgets/app_widgets.dart';
import 'package:adopt_animal/features/adoption/data/animal_repository.dart';
import 'package:adopt_animal/features/shop/data/product_repository.dart';
import 'package:adopt_animal/features/vet/data/vet_repository.dart';
import 'package:adopt_animal/features/adoption/presentation/pages/animal_detail_page.dart';
import 'package:adopt_animal/features/shop/presentation/pages/product_detail_page.dart';
import 'package:adopt_animal/features/vet/presentation/pages/vet_profile_page.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final _controller = TextEditingController();
  String _q = "";

  List<Animal> _animals = [];
  List<Product> _products = [];
  List<Vet> _vets = [];
  final List<StreamSubscription> _subs = [];

  @override
  void initState() {
    super.initState();
    _subs.add(AnimalRepository().watchAll().listen((v) {
      if (mounted) setState(() => _animals = v);
    }));
    _subs.add(ProductRepository().watch().listen((v) {
      if (mounted) setState(() => _products = v);
    }));
    _subs.add(VetRepository().watch().listen((v) {
      if (mounted) setState(() => _vets = v);
    }));
  }

  @override
  void dispose() {
    for (final s in _subs) {
      s.cancel();
    }
    _controller.dispose();
    super.dispose();
  }

  bool _m(String s) => _q.isNotEmpty && s.toLowerCase().contains(_q.toLowerCase());

  @override
  Widget build(BuildContext context) {
    final animals = _q.isEmpty
        ? <Animal>[]
        : _animals.where((a) => _m(a.name) || _m(a.breed) || _m(a.city)).toList();
    final products = _q.isEmpty
        ? <Product>[]
        : _products.where((p) => _m(p.name) || _m(p.category)).toList();
    final vets = _q.isEmpty
        ? <Vet>[]
        : _vets
            .where((v) => _m(v.name) || _m(v.specialty) || _m(v.clinic))
            .toList();
    final noResults = animals.isEmpty && products.isEmpty && vets.isEmpty;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: const Padding(
                      padding: EdgeInsets.only(right: 12, top: 8, bottom: 8),
                      child: AppIcon(AppIcons.arrowBack,
                          size: 22, color: AppColors.primaryDark),
                    ),
                  ),
                  Expanded(
                    child: AppSearchField(
                      hint: "Search animals, products, vets...",
                      controller: _controller,
                      showClear: _q.isNotEmpty,
                      onChanged: (v) => setState(() => _q = v),
                      onClear: () => setState(() {
                        _controller.clear();
                        _q = "";
                      }),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Expanded(
                child: _q.isEmpty
                    ? const EmptyState(
                        icon: Icons.search,
                        title: "Search everything",
                        subtitle:
                            "Find animals, products and vets in one place.",
                      )
                    : noResults
                        ? const EmptyState(
                            icon: Icons.search_off,
                            title: "No results",
                            subtitle: "Try a different search.")
                        : ListView(
                            padding: const EdgeInsets.only(bottom: 16),
                            children: [
                              if (animals.isNotEmpty) ...[
                                _label("Animals"),
                                for (final a in animals) _animalRow(a),
                                const SizedBox(height: 12),
                              ],
                              if (products.isNotEmpty) ...[
                                _label("Products"),
                                for (final p in products) _productRow(p),
                                const SizedBox(height: 12),
                              ],
                              if (vets.isNotEmpty) ...[
                                _label("Vets"),
                                for (final v in vets) _vetRow(v),
                              ],
                            ],
                          ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _label(String t) => Padding(
        padding: const EdgeInsets.only(left: 4, bottom: 10, top: 4),
        child: Text(t.toUpperCase(),
            style: const TextStyle(
                color: AppColors.primary,
                fontWeight: FontWeight.w700,
                fontSize: 13,
                letterSpacing: 1)),
      );

  Widget _shell(
      {required Widget leading,
      required String title,
      required String sub,
      required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          boxShadow: const [
            BoxShadow(
                color: Color(0x0A1F2A44), blurRadius: 10, offset: Offset(0, 3))
          ],
        ),
        child: Row(
          children: [
            leading,
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 15,
                          color: AppColors.primaryDark)),
                  const SizedBox(height: 2),
                  Text(sub,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppText.secondary),
                ],
              ),
            ),
            const AppIcon(AppIcons.chevronRight,
                size: 18, color: AppColors.textSecondary),
          ],
        ),
      ),
    );
  }

  Widget _animalRow(Animal a) => _shell(
        leading: SizedBox(
            width: 48,
            height: 48,
            child: photoOrPlaceholder(a.photoBase64, a.photoLabel, radius: 12)),
        title: a.name,
        sub: "${a.breed} · ${a.age} · ${a.city}",
        onTap: () => Navigator.push(context,
            MaterialPageRoute(builder: (_) => AnimalDetailPage(animal: a))),
      );

  Widget _productRow(Product p) => _shell(
        leading: const SizedBox(
            width: 48,
            height: 48,
            child: StripedPlaceholder(label: "", borderRadius: 12)),
        title: p.name,
        sub: "${p.category} · EGP ${p.price}",
        onTap: () => Navigator.push(context,
            MaterialPageRoute(builder: (_) => ProductDetailPage(product: p))),
      );

  Widget _vetRow(Vet v) => _shell(
        leading: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.12),
              shape: BoxShape.circle),
          child: Center(
            child: Text(v.initials,
                style: const TextStyle(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w700,
                    fontSize: 15)),
          ),
        ),
        title: v.name,
        sub: "${v.specialty} · ${v.clinic}",
        onTap: () => Navigator.push(context,
            MaterialPageRoute(builder: (_) => VetProfilePage(vet: v))),
      );
}
