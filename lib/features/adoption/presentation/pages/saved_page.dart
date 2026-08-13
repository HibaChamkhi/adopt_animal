import 'package:flutter/material.dart';
import 'package:adopt_animal/core/app_theme.dart';
import 'package:adopt_animal/core/sample_data.dart';
import 'package:adopt_animal/core/favorites_service.dart';
import 'package:adopt_animal/core/widgets/app_widgets.dart';
import 'package:adopt_animal/features/adoption/data/animal_repository.dart';
import 'package:adopt_animal/features/adoption/presentation/pages/animal_detail_page.dart';

class SavedPage extends StatelessWidget {
  const SavedPage({super.key});

  @override
  Widget build(BuildContext context) {
    final repo = AnimalRepository();
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
          child: AnimatedBuilder(
            animation: favorites,
            builder: (context, _) {
              return StreamBuilder<List<Animal>>(
                stream: repo.watchAll(),
                builder: (context, snap) {
                  final loading =
                      snap.connectionState == ConnectionState.waiting;
                  final saved = (snap.data ?? const <Animal>[])
                      .where((a) => favorites.contains(a.name))
                      .toList();
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text("Saved", style: AppText.heading),
                      const SizedBox(height: 4),
                      Text(
                        saved.isEmpty
                            ? "Animals you save will appear here"
                            : "${saved.length} animal${saved.length == 1 ? '' : 's'} you're keeping an eye on",
                        style: AppText.secondary,
                      ),
                      const SizedBox(height: 16),
                      Expanded(
                        child: loading
                            ? const Center(child: CircularProgressIndicator())
                            : saved.isEmpty
                                ? const EmptyState(
                                    icon: Icons.favorite_border,
                                    title: "No saved animals yet",
                                    subtitle:
                                        "Tap the heart on any animal to save it here.",
                                  )
                                : ListView.separated(
                                    padding: const EdgeInsets.only(bottom: 16),
                                    itemCount: saved.length,
                                    separatorBuilder: (_, __) =>
                                        const SizedBox(height: 14),
                                    itemBuilder: (context, i) =>
                                        _row(context, saved[i]),
                                  ),
                      ),
                    ],
                  );
                },
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _row(BuildContext context, Animal a) {
    final available = a.status.toLowerCase() == "available";
    final sub = [a.breed, a.age, a.city]
        .where((s) => s.trim().isNotEmpty)
        .join(" · ");
    return Opacity(
      opacity: available ? 1 : 0.6,
      child: GestureDetector(
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => AnimalDetailPage(animal: a)),
        ),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(18),
            boxShadow: const [
              BoxShadow(
                  color: Color(0x0F1F2A44), blurRadius: 14, offset: Offset(0, 6)),
            ],
          ),
          child: Row(
            children: [
              SizedBox(
                width: 60,
                height: 60,
                child:
                    photoOrPlaceholder(a.photoBase64, a.photoLabel, radius: 14),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(a.name,
                        style: const TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 16,
                            color: AppColors.primaryDark)),
                    const SizedBox(height: 2),
                    Text(sub, style: AppText.secondary),
                    const SizedBox(height: 4),
                    Text(
                      available ? "Still available" : "Adopted by someone else",
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: available
                            ? AppColors.success
                            : AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              GestureDetector(
                onTap: () => favorites.toggle(a.name),
                child: Icon(
                  Icons.favorite,
                  color: available
                      ? AppColors.primary
                      : AppColors.textSecondary,
                  size: 22,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
