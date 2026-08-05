import 'package:flutter/material.dart';
import 'package:adopt_animal/core/app_theme.dart';
import 'package:adopt_animal/core/widgets/app_widgets.dart';

class _Saved {
  final String name, sub, photo;
  final bool available;
  _Saved(this.name, this.sub, this.photo, this.available);
}

class SavedPage extends StatelessWidget {
  const SavedPage({super.key});

  static final _items = [
    _Saved("Milo", "Tabby · 8 mo · Giza", "cat photo", true),
    _Saved("Kiwi", "Cockatiel · 1 yr · Alexandria", "bird photo", true),
    _Saved("Rocky", "Beagle · 3 yr · Cairo", "dog photo", false),
    _Saved("Nala", "Siamese · 2 yr · Cairo", "cat photo", true),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("Saved", style: AppText.heading),
              const SizedBox(height: 4),
              Text("${_items.length} animals you're keeping an eye on", style: AppText.secondary),
              const SizedBox(height: 16),
              Expanded(
                child: ListView.separated(
                  padding: const EdgeInsets.only(bottom: 16),
                  itemCount: _items.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 14),
                  itemBuilder: (context, i) => _row(_items[i]),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _row(_Saved s) {
    return Opacity(
      opacity: s.available ? 1 : 0.6,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(18),
          boxShadow: const [
            BoxShadow(color: Color(0x0F1F2A44), blurRadius: 14, offset: Offset(0, 6)),
          ],
        ),
        child: Row(
          children: [
            SizedBox(
              width: 60, height: 60,
              child: StripedPlaceholder(label: s.photo, borderRadius: 14),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(s.name,
                      style: const TextStyle(
                          fontWeight: FontWeight.w700, fontSize: 16, color: AppColors.primaryDark)),
                  const SizedBox(height: 2),
                  Text(s.sub, style: AppText.secondary),
                  const SizedBox(height: 4),
                  Text(
                    s.available ? "Still available" : "Adopted by someone else",
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: s.available ? AppColors.success : AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.favorite,
              color: s.available ? AppColors.primary : AppColors.textSecondary,
              size: 22,
            ),
          ],
        ),
      ),
    );
  }
}
