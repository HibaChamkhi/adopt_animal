import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:adopt_animal/core/app_icons.dart';
import 'package:adopt_animal/core/app_theme.dart';
import 'package:adopt_animal/core/widgets/app_widgets.dart';
import 'package:adopt_animal/core/widgets/settings_widgets.dart';
import 'package:adopt_animal/features/adoption/data/animal_repository.dart';
import 'package:adopt_animal/core/storage_service.dart';

class ListForAdoptionPage extends StatefulWidget {
  const ListForAdoptionPage({super.key});

  @override
  State<ListForAdoptionPage> createState() => _ListForAdoptionPageState();
}

class _ListForAdoptionPageState extends State<ListForAdoptionPage> {
  int _species = 0;
  int _gender = 0;
  final _species_ = const ["Dog", "Cat", "Bird", "Other"];
  final _name = TextEditingController();
  final _age = TextEditingController();
  final List<File> _photos = [];
  bool _posting = false;

  @override
  void dispose() {
    _name.dispose();
    _age.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SubPageHeader("List for adoption"),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(child: _progress(true)),
                  const SizedBox(width: 6),
                  Expanded(child: _progress(false)),
                  const SizedBox(width: 6),
                  Expanded(child: _progress(false)),
                ],
              ),
              const SizedBox(height: 10),
              const Text("Step 1 of 3 · Photos & basics", style: AppText.secondary),
              const SizedBox(height: 20),
              const Text("Photos", style: AppText.secondary),
              const SizedBox(height: 10),
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: [
                  for (int i = 0; i < _photos.length; i++) _preview(i),
                  _addPhoto(),
                ],
              ),
              const SizedBox(height: 22),
              const Text("Species", style: AppText.secondary),
              const SizedBox(height: 10),
              Row(
                children: [
                  for (int i = 0; i < _species_.length; i++) ...[
                    SelectableChip(
                      label: _species_[i],
                      selected: _species == i,
                      onTap: () => setState(() => _species = i),
                    ),
                    if (i != _species_.length - 1) const SizedBox(width: 10),
                  ],
                ],
              ),
              const SizedBox(height: 22),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(child: _labeledField("Name", _name, "Bella")),
                  const SizedBox(width: 14),
                  Expanded(child: _breedField()),
                ],
              ),
              const SizedBox(height: 18),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(child: _labeledField("Age", _age, "3 years")),
                  const SizedBox(width: 14),
                  Expanded(child: _genderField()),
                ],
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
          child: PrimaryButton(
            label: "Post listing",
            onTap: _post,
          ),
        ),
      ),
    );
  }

  Widget _progress(bool filled) => Container(
        height: 5,
        decoration: BoxDecoration(
          color: filled ? AppColors.primary : AppColors.stroke,
          borderRadius: BorderRadius.circular(4),
        ),
      );

  Widget _photoThumb({required bool removable}) {
    return SizedBox(
      width: 80, height: 80,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          const SizedBox(
            width: 80, height: 80,
            child: StripedPlaceholder(label: "", borderRadius: 14),
          ),
          if (removable)
            Positioned(
              top: -6, right: -6,
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: const BoxDecoration(color: AppColors.primary, shape: BoxShape.circle),
                child: const AppIcon(AppIcons.close, size: 12, color: Colors.white),
              ),
            ),
        ],
      ),
    );
  }

  Future<void> _pick() async {
    final picker = ImagePicker();
    final x = await picker.pickImage(source: ImageSource.gallery, imageQuality: 70);
    if (x != null) setState(() => _photos.add(File(x.path)));
  }

  Widget _preview(int i) {
    return SizedBox(
      width: 80, height: 80,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(14),
            child: Image.file(_photos[i], width: 80, height: 80, fit: BoxFit.cover),
          ),
          Positioned(
            top: -6, right: -6,
            child: GestureDetector(
              onTap: () => setState(() => _photos.removeAt(i)),
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: const BoxDecoration(color: AppColors.primary, shape: BoxShape.circle),
                child: const AppIcon(AppIcons.close, size: 12, color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _addPhoto() {
    return GestureDetector(
      onTap: _pick,
      child: DottedBox(
      child: SizedBox(
        width: 80, height: 80,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            AppIcon(AppIcons.addPhoto, size: 24, color: AppColors.primary),
            SizedBox(height: 4),
            Text("Add", style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.w600, fontSize: 12)),
          ],
        ),
      ),
    ),
    );
  }

  Widget _labeledField(String label, TextEditingController c, String hint) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppText.secondary),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(16)),
          child: TextField(
            controller: c,
            style: AppText.body,
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: AppText.secondary,
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(vertical: 16),
            ),
          ),
        ),
      ],
    );
  }

  Widget _breedField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("Breed", style: AppText.secondary),
        const SizedBox(height: 8),
        Container(
          height: 54,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(16)),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: const [
              Text("Select...", style: AppText.secondary),
              Icon(Icons.expand_more, color: AppColors.textSecondary),
            ],
          ),
        ),
      ],
    );
  }

  Widget _genderField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("Gender", style: AppText.secondary),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.all(5),
          decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(16)),
          child: Row(
            children: [
              _genderOpt("Female", 0),
              _genderOpt("Male", 1),
            ],
          ),
        ),
      ],
    );
  }

  Widget _genderOpt(String label, int i) {
    final sel = _gender == i;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _gender = i),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 11),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: sel ? AppColors.primary : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(label,
              style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                  color: sel ? Colors.white : AppColors.textSecondary)),
        ),
      ),
    );
  }

  Future<void> _post() async {
    if (_posting) return;
    setState(() => _posting = true);
    final species = _species_[_species].toLowerCase();
    try {
      List<String> urls = [];
      if (_photos.isNotEmpty) {
        final uid = FirebaseAuth.instance.currentUser?.uid ?? 'anonymous';
        urls = await StorageService().uploadAnimalPhotos(_photos, uid);
      }
      await AnimalRepository().addAnimal(
        name: _name.text.trim().isEmpty ? "Unnamed" : _name.text.trim(),
        species: species,
        breed: _species_[_species],
        age: _age.text.trim().isEmpty ? "-" : _age.text.trim(),
        gender: _gender == 0 ? "Female" : "Male",
        photoUrls: urls,
      );
      if (!mounted) return;
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Listing posted!")),
      );
    } catch (_) {
      if (mounted) setState(() => _posting = false);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Could not post — check your Firestore rules/connection.")),
      );
    }
  }
}

class DottedBox extends StatelessWidget {
  final Widget child;
  const DottedBox({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _DashPainter(),
      child: child,
    );
  }
}

class _DashPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.primary.withOpacity(0.5)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    final rrect = RRect.fromRectAndRadius(
        Offset.zero & size, const Radius.circular(14));
    final path = Path()..addRRect(rrect);
    const dash = 6.0, gap = 4.0;
    for (final metric in path.computeMetrics()) {
      double d = 0;
      while (d < metric.length) {
        canvas.drawPath(metric.extractPath(d, d + dash), paint);
        d += dash + gap;
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
