import 'package:flutter/material.dart';
import 'package:adopt_animal/core/app_icons.dart';
import 'package:adopt_animal/core/app_theme.dart';
import 'package:adopt_animal/core/widgets/app_widgets.dart';
import 'package:adopt_animal/features/home/presentation/pages/home_screen.dart';
import 'package:adopt_animal/features/adoption/presentation/pages/adopt_page.dart';
import 'package:adopt_animal/features/shop/presentation/pages/shop_page.dart';
import 'package:adopt_animal/features/vet/presentation/pages/vet_directory_page.dart';
import 'package:adopt_animal/features/profile/presentation/pages/profile_page.dart';

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _index = 0;

  void _select(int i) => setState(() => _index = i);

  @override
  Widget build(BuildContext context) {
    final pages = [
      HomeScreen(onSelectTab: _select),
      const AdoptPage(),
      const ShopPage(),
      const VetDirectoryPage(),
      const ProfilePage(),
    ];

    return Scaffold(
      backgroundColor: AppColors.background,
      body: IndexedStack(index: _index, children: pages),
      bottomNavigationBar: _BottomNav(index: _index, onTap: _select),
    );
  }
}

class _BottomNav extends StatelessWidget {
  final int index;
  final ValueChanged<int> onTap;

  const _BottomNav({required this.index, required this.onTap});

  static const _items = [
    AppIcons.home,
    AppIcons.pets,
    AppIcons.storefront,
    AppIcons.chat,
    AppIcons.person,
  ];

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        margin: const EdgeInsets.fromLTRB(20, 0, 20, 16),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(32),
          boxShadow: const [
            BoxShadow(color: Color(0x1A1F2A44), blurRadius: 20, offset: Offset(0, 8)),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            for (int i = 0; i < _items.length; i++)
              GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () => onTap(i),
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: index == i ? AppColors.primary : Colors.transparent,
                    shape: BoxShape.circle,
                  ),
                  child: AppIcon(
                    _items[i],
                    size: 24,
                    color: index == i ? Colors.white : AppColors.textSecondary,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _ComingSoon extends StatelessWidget {
  final String title;
  const _ComingSoon({required this.title});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
            child: Text(title, style: AppText.heading),
          ),
          const Expanded(
            child: EmptyState(
              icon: Icons.hourglass_empty,
              title: "Coming soon",
              subtitle: "We're building this next.",
            ),
          ),
        ],
      ),
    );
  }
}
