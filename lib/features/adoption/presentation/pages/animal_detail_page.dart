import 'package:flutter/material.dart';
import 'package:adopt_animal/core/app_icons.dart';
import 'package:adopt_animal/core/app_theme.dart';
import 'package:adopt_animal/core/sample_data.dart';
import 'package:adopt_animal/core/favorites_service.dart';
import 'package:adopt_animal/core/widgets/app_widgets.dart';
import 'package:adopt_animal/features/adoption/presentation/pages/adoption_request_page.dart';

class AnimalDetailPage extends StatefulWidget {
  final Animal animal;
  const AnimalDetailPage({super.key, required this.animal});

  @override
  State<AnimalDetailPage> createState() => _AnimalDetailPageState();
}

class _AnimalDetailPageState extends State<AnimalDetailPage> {
  bool get _fav => favorites.contains(widget.animal.name);

  @override
  Widget build(BuildContext context) {
    final a = widget.animal;
    final location = [a.area.isEmpty ? a.city : a.area, if (a.distance.isNotEmpty) a.distance].join(" · ");

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        bottom: false,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _header(a),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(child: Text(a.name, style: AppText.heading)),
                        StatusBadge(label: a.status, type: BadgeType.success),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const AppIcon(AppIcons.location, size: 16, color: AppColors.textSecondary),
                        const SizedBox(width: 4),
                        Text(location, style: AppText.secondary),
                      ],
                    ),
                    const SizedBox(height: 18),
                    Row(
                      children: [
                        Expanded(child: StatTile(value: a.age, label: "Age")),
                        const SizedBox(width: 10),
                        Expanded(child: StatTile(value: a.gender, label: "Gender")),
                        const SizedBox(width: 10),
                        Expanded(child: StatTile(value: a.size, label: "Size")),
                        const SizedBox(width: 10),
                        Expanded(child: StatTile(value: a.weight, label: "Weight")),
                      ],
                    ),
                    const SizedBox(height: 18),
                    Text(a.description, style: AppText.body),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        const AppIcon(AppIcons.verified, size: 20, color: AppColors.success),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            a.health,
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              color: AppColors.primaryDark,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 18),
                    _ownerCard(a),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
          child: PrimaryButton(
            label: "Request adoption",
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => AdoptionRequestPage(animal: a)),
            ),
          ),
        ),
      ),
    );
  }

  Widget _header(Animal a) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
      child: Stack(
        children: [
          StripedPlaceholder(
            label: "${a.species} photo carousel",
            height: 300,
            borderRadius: 24,
          ),
          Positioned(
            top: 12,
            left: 12,
            child: _circleButton(AppIcons.arrowBack, () => Navigator.pop(context)),
          ),
          Positioned(
            top: 12,
            right: 12,
            child: GestureDetector(
              onTap: () async {
                await favorites.toggle(widget.animal.name);
                if (mounted) setState(() {});
              },
              child: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: _fav ? AppColors.primary : Colors.white,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  _fav ? Icons.favorite : Icons.favorite_border,
                  size: 20,
                  color: _fav ? Colors.white : AppColors.primary,
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 14,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(3, (i) {
                return Container(
                  margin: const EdgeInsets.symmetric(horizontal: 3),
                  width: i == 0 ? 18 : 7,
                  height: 7,
                  decoration: BoxDecoration(
                    color: i == 0 ? AppColors.primary : Colors.white,
                    borderRadius: BorderRadius.circular(4),
                  ),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }

  Widget _circleButton(String icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
        child: AppIcon(icon, size: 20, color: AppColors.primaryDark),
      ),
    );
  }

  Widget _ownerCard(Animal a) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
        boxShadow: const [
          BoxShadow(color: Color(0x0F1F2A44), blurRadius: 14, offset: Offset(0, 6)),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: const BoxDecoration(color: AppColors.placeholder, shape: BoxShape.circle),
            child: const Icon(Icons.person, color: AppColors.primary, size: 24),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  a.ownerName,
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                    color: AppColors.primaryDark,
                  ),
                ),
                const SizedBox(height: 2),
                Text("Owner · member since ${a.ownerSince}", style: AppText.secondary),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const AppIcon(AppIcons.chat, size: 20, color: AppColors.primary),
          ),
        ],
      ),
    );
  }
}
