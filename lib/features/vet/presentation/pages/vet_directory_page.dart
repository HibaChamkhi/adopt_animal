import 'package:flutter/material.dart';
import 'package:adopt_animal/core/app_icons.dart';
import 'package:adopt_animal/core/app_theme.dart';
import 'package:adopt_animal/core/sample_data.dart';
import 'package:adopt_animal/core/widgets/app_widgets.dart';
import 'package:adopt_animal/features/vet/presentation/pages/vet_profile_page.dart';

class VetDirectoryPage extends StatefulWidget {
  const VetDirectoryPage({super.key});

  @override
  State<VetDirectoryPage> createState() => _VetDirectoryPageState();
}

class _VetDirectoryPageState extends State<VetDirectoryPage> {
  int _category = 0;
  final _categories = const ["All", "Canine", "Feline", "Exotic"];

  List<Vet> get _filtered {
    if (_category == 0) return sampleVets;
    return sampleVets.where((v) => v.category == _categories[_category]).toList();
  }

  @override
  Widget build(BuildContext context) {
    final vets = _filtered;
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Vets", style: AppText.heading),
            const SizedBox(height: 16),
            const AppSearchField(hint: "Search by name or specialty..."),
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
              child: vets.isEmpty
                  ? const EmptyState(icon: Icons.medical_services_outlined, title: "No vets found")
                  : ListView.separated(
                      padding: const EdgeInsets.only(bottom: 16),
                      itemCount: vets.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 14),
                      itemBuilder: (context, i) => _vetCard(vets[i]),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _vetCard(Vet v) {
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => VetProfilePage(vet: v)),
      ),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(18),
          boxShadow: const [
            BoxShadow(color: Color(0x0F1F2A44), blurRadius: 14, offset: Offset(0, 6)),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.12),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Center(
                child: Text(v.initials,
                    style: const TextStyle(
                        color: AppColors.primary, fontWeight: FontWeight.w700, fontSize: 18)),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(v.name,
                            style: const TextStyle(
                                fontWeight: FontWeight.w700, fontSize: 16, color: AppColors.primaryDark)),
                      ),
                      const AppIcon(AppIcons.star, size: 15, color: Color(0xFFF2B21C)),
                      const SizedBox(width: 3),
                      Text("${v.rating}",
                          style: const TextStyle(
                              fontWeight: FontWeight.w700, fontSize: 14, color: AppColors.primaryDark)),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text("${v.specialty} · ${v.clinic}",
                      maxLines: 1, overflow: TextOverflow.ellipsis, style: AppText.secondary),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      const AppIcon(AppIcons.location, size: 15, color: AppColors.primary),
                      const SizedBox(width: 3),
                      Expanded(
                        child: Text(v.city,
                            style: const TextStyle(
                                color: AppColors.primary, fontWeight: FontWeight.w600, fontSize: 13)),
                      ),
                      StatusBadge(
                        label: v.availability,
                        type: v.availableToday ? BadgeType.success : BadgeType.neutral,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
