import 'package:flutter/material.dart';
import 'package:adopt_animal/core/app_icons.dart';
import 'package:adopt_animal/core/app_theme.dart';
import 'package:adopt_animal/core/sample_data.dart';
import 'package:adopt_animal/core/favorites_service.dart';
import 'package:adopt_animal/core/widgets/app_widgets.dart';
import 'package:adopt_animal/injection.dart' as di;
import 'package:adopt_animal/features/auth/domain/entities/user_entity.dart';
import 'package:adopt_animal/features/auth/domain/useCases/get_current_user_use_case.dart';
import 'package:adopt_animal/features/adoption/presentation/pages/animal_detail_page.dart';
import 'package:adopt_animal/features/notifications/presentation/pages/notifications_page.dart';
import 'package:adopt_animal/features/search/presentation/pages/search_page.dart';

class HomeScreen extends StatefulWidget {
  final void Function(int index)? onSelectTab;
  const HomeScreen({super.key, this.onSelectTab});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String _name = "";
  int _category = 0;
  final _categories = const ["All", "Dogs", "Cats", "Birds"];

  @override
  void initState() {
    super.initState();
    favorites.addListener(_onFav);
    di.sl<GetCurrentUserUseCase>().call().then((UserEntity u) {
      if (!mounted) return;
      final n = u.name;
      setState(() => _name = (n != null && n.trim().isNotEmpty) ? n : "there");
    }).catchError((_) {
      if (mounted) setState(() => _name = "there");
    });
  }

  @override
  @override
  void dispose() {
    favorites.removeListener(_onFav);
    super.dispose();
  }

  void _onFav() {
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("Good morning", style: AppText.secondary),
                    const SizedBox(height: 2),
                    Text("Hi, $_name", style: AppText.heading),
                  ],
                ),
                _bell(),
              ],
            ),
            const SizedBox(height: 20),
            GestureDetector(
              onTap: () => Navigator.push(
                  context, MaterialPageRoute(builder: (_) => const SearchPage())),
              child: const AbsorbPointer(
                child: AppSearchField(hint: "Search animals, products, vets..."),
              ),
            ),
            const SizedBox(height: 20),
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
            const SizedBox(height: 24),
            SectionHeader(
              title: "Adopt near you",
              actionText: "See all",
              onAction: () => widget.onSelectTab?.call(1),
            ),
            const SizedBox(height: 14),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(child: _petCard(sampleAnimals[0])),
                const SizedBox(width: 14),
                Expanded(child: _petCard(sampleAnimals[1])),
              ],
            ),
            const SizedBox(height: 24),
            const SectionHeader(title: "Pet care"),
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: _careCard(
                    icon: AppIcons.storefront,
                    label: "Shop supplies",
                    filled: true,
                    onTap: () => widget.onSelectTab?.call(2),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: _careCard(
                    icon: AppIcons.stethoscope,
                    label: "Talk to a vet",
                    filled: false,
                    onTap: () => widget.onSelectTab?.call(3),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _petCard(Animal a) {
    return PetCard(
      name: a.name,
      subtitle: "${a.breed} · ${a.age}",
      placeholderLabel: a.photoLabel,
      imageUrl: a.photoUrl,
      isFavorite: favorites.contains(a.name),
      onFavorite: () => favorites.toggle(a.name),
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => AnimalDetailPage(animal: a)),
      ).then((_) => setState(() {})),
    );
  }

  Widget _bell() {
    return GestureDetector(
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const NotificationsPage())),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          boxShadow: const [
            BoxShadow(color: Color(0x0F1F2A44), blurRadius: 12, offset: Offset(0, 4)),
          ],
        ),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            const AppIcon(AppIcons.notifications, size: 24, color: AppColors.primaryDark),
            Positioned(
              right: -1,
              top: -1,
              child: Container(
                width: 9,
                height: 9,
                decoration: const BoxDecoration(color: AppColors.primary, shape: BoxShape.circle),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _careCard({
    required String icon,
    required String label,
    required bool filled,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 110,
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: filled ? AppColors.primary : AppColors.surface,
          borderRadius: BorderRadius.circular(20),
          boxShadow: const [
            BoxShadow(color: Color(0x0F1F2A44), blurRadius: 14, offset: Offset(0, 6)),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            AppIcon(icon, size: 28, color: filled ? Colors.white : AppColors.primary),
            Text(
              label,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: filled ? Colors.white : AppColors.primaryDark,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
