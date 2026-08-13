import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:adopt_animal/core/app_icons.dart';
import 'package:adopt_animal/core/app_theme.dart';
import 'package:adopt_animal/core/widgets/app_widgets.dart';
import 'package:adopt_animal/core/widgets/settings_widgets.dart';
import 'package:adopt_animal/features/adoption/data/animal_repository.dart';
import 'package:adopt_animal/core/sample_data.dart';

class ListForAdoptionPage extends StatefulWidget {
  final Animal? existing;
  const ListForAdoptionPage({super.key, this.existing});

  @override
  State<ListForAdoptionPage> createState() => _ListForAdoptionPageState();
}

class _ListForAdoptionPageState extends State<ListForAdoptionPage> {
  int _step = 0;
  int _species = 0;
  int _gender = 0;
  int _size = 1;
  String _breed = "";

  final _species_ = const ["Dog", "Cat", "Bird", "Other"];
  final _sizes = const ["Small", "Medium", "Large"];
  final Map<String, List<String>> _breeds = const {
    "Dog": [
      "Labrador", "Beagle", "German Shepherd", "Golden Retriever", "Poodle",
      "Bulldog", "Husky", "Chihuahua", "Mixed breed", "Other"
    ],
    "Cat": [
      "Persian", "Siamese", "Tabby", "Maine Coon", "Bengal", "Sphynx",
      "British Shorthair", "Mixed breed", "Other"
    ],
    "Bird": [
      "Cockatiel", "Budgerigar", "Canary", "Lovebird", "Parrot", "Finch", "Other"
    ],
    "Other": ["Rabbit", "Hamster", "Guinea Pig", "Turtle", "Other"],
  };

  final _name = TextEditingController();
  final _age = TextEditingController();
  final _weight = TextEditingController();
  final _city = TextEditingController();
  final _desc = TextEditingController();
  final _health = TextEditingController();
  final List<File> _photos = [];
  String _existingBase64 = "";
  bool _posting = false;

  bool get _isEdit => widget.existing != null;

  @override
  void initState() {
    super.initState();
    final e = widget.existing;
    if (e != null) {
      _name.text = e.name;
      _age.text = e.age;
      _weight.text = e.weight == "-" ? "" : e.weight;
      _city.text = e.city;
      _desc.text = e.description;
      _health.text = e.health;
      final sp =
          _species_.indexWhere((s) => s.toLowerCase() == e.species.toLowerCase());
      if (sp >= 0) _species = sp;
      final sz =
          _sizes.indexWhere((s) => s.toLowerCase() == e.size.toLowerCase());
      if (sz >= 0) _size = sz;
      _gender = e.gender.toLowerCase() == "male" ? 1 : 0;
      _breed = e.breed;
      _existingBase64 = e.photoBase64;
    }
  }

  @override
  void dispose() {
    _name.dispose();
    _age.dispose();
    _weight.dispose();
    _city.dispose();
    _desc.dispose();
    _health.dispose();
    super.dispose();
  }

  static const _titles = ["Photos & basics", "Details", "About & post"];

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
              SubPageHeader(_isEdit ? "Edit listing" : "List for adoption"),
              const SizedBox(height: 16),
              Row(
                children: [
                  for (int i = 0; i < 3; i++) ...[
                    Expanded(child: _progress(i <= _step)),
                    if (i < 2) const SizedBox(width: 6),
                  ],
                ],
              ),
              const SizedBox(height: 10),
              Text("Step ${_step + 1} of 3 · ${_titles[_step]}",
                  style: AppText.secondary),
              const SizedBox(height: 20),
              _stepContent(),
            ],
          ),
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
          child: Row(
            children: [
              if (_step > 0) ...[
                Expanded(
                  child: SizedBox(
                    height: 56,
                    child: OutlinedButton(
                      onPressed: _posting ? null : () => setState(() => _step--),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.primary,
                        side: const BorderSide(color: AppColors.stroke),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(28)),
                      ),
                      child: const Text("Back",
                          style: TextStyle(fontWeight: FontWeight.w700)),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
              ],
              Expanded(
                child: PrimaryButton(
                  label: _step < 2
                      ? "Next"
                      : (_posting
                          ? (_isEdit ? "Saving..." : "Posting...")
                          : (_isEdit ? "Save changes" : "Post listing")),
                  onTap: _posting
                      ? null
                      : (_step < 2 ? _goNext : _post),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _goNext() {
    if (_step == 0 && _name.text.trim().isEmpty) {
      _snack("Please enter a name");
      return;
    }
    setState(() => _step++);
  }

  void _snack(String m) =>
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(m)));

  Widget _stepContent() {
    switch (_step) {
      case 0:
        return _stepBasics();
      case 1:
        return _stepDetails();
      default:
        return _stepAbout();
    }
  }

  Widget _stepBasics() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("Photos", style: AppText.secondary),
        const SizedBox(height: 10),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            for (int i = 0; i < _photos.length; i++) _preview(i),
            if (_photos.isEmpty && _existingBase64.isNotEmpty) _existingPreview(),
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
                onTap: () => setState(() {
                  _species = i;
                  final list = _breeds[_species_[i]] ?? const [];
                  if (!list.contains(_breed)) _breed = "";
                }),
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
        Align(
          alignment: Alignment.centerLeft,
          child: SizedBox(width: 200, child: _genderField()),
        ),
      ],
    );
  }

  Widget _stepDetails() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(child: _labeledField("Age", _age, "3 years")),
            const SizedBox(width: 14),
            Expanded(child: _labeledField("Weight", _weight, "12 kg")),
          ],
        ),
        const SizedBox(height: 18),
        const Text("Size", style: AppText.secondary),
        const SizedBox(height: 10),
        Row(
          children: [
            for (int i = 0; i < _sizes.length; i++) ...[
              SelectableChip(
                label: _sizes[i],
                selected: _size == i,
                onTap: () => setState(() => _size = i),
              ),
              if (i != _sizes.length - 1) const SizedBox(width: 10),
            ],
          ],
        ),
        const SizedBox(height: 18),
        _labeledField("City", _city, "Cairo"),
      ],
    );
  }

  Widget _stepAbout() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _labeledField("Description", _desc,
            "Friendly, house-trained, good with kids...",
            maxLines: 4),
        const SizedBox(height: 18),
        _labeledField("Health", _health, "Vaccinated · Spayed"),
        const SizedBox(height: 24),
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppColors.neutralBg,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Text(
            "Review: ${_name.text.trim().isEmpty ? 'Unnamed' : _name.text.trim()} · "
            "${_species_[_species]}${_breed.isEmpty ? '' : ' · $_breed'} · "
            "${_sizes[_size]}",
            style: AppText.secondary,
          ),
        ),
      ],
    );
  }

  Widget _progress(bool filled) => Container(
        height: 5,
        decoration: BoxDecoration(
          color: filled ? AppColors.primary : AppColors.stroke,
          borderRadius: BorderRadius.circular(4),
        ),
      );

  Future<void> _pick() async {
    final picker = ImagePicker();
    final x = await picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 40,
        maxWidth: 720,
        maxHeight: 720);
    if (x != null) setState(() => _photos.add(File(x.path)));
  }

  Widget _preview(int i) {
    return SizedBox(
      width: 80,
      height: 80,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(14),
            child: Image.file(_photos[i],
                width: 80, height: 80, fit: BoxFit.cover),
          ),
          Positioned(
            top: -6,
            right: -6,
            child: GestureDetector(
              onTap: () => setState(() => _photos.removeAt(i)),
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: const BoxDecoration(
                    color: AppColors.primary, shape: BoxShape.circle),
                child:
                    const AppIcon(AppIcons.close, size: 12, color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _existingPreview() {
    return SizedBox(
      width: 80,
      height: 80,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          photoOrPlaceholder(_existingBase64, "", radius: 14),
          Positioned(
            top: -6,
            right: -6,
            child: GestureDetector(
              onTap: () => setState(() => _existingBase64 = ""),
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: const BoxDecoration(
                    color: AppColors.primary, shape: BoxShape.circle),
                child:
                    const AppIcon(AppIcons.close, size: 12, color: Colors.white),
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
          width: 80,
          height: 80,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [
              AppIcon(AppIcons.addPhoto, size: 24, color: AppColors.primary),
              SizedBox(height: 4),
              Text("Add",
                  style: TextStyle(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w600,
                      fontSize: 12)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _labeledField(String label, TextEditingController c, String hint,
      {int maxLines = 1}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppText.secondary),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
              color: AppColors.surface, borderRadius: BorderRadius.circular(16)),
          child: TextField(
            controller: c,
            style: AppText.body,
            maxLines: maxLines,
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

  Future<void> _pickBreed() async {
    final list = _breeds[_species_[_species]] ?? const <String>[];
    final picked = await showModalBottomSheet<String>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        decoration: const BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Select ${_species_[_species]} breed", style: AppText.title),
            const SizedBox(height: 12),
            Flexible(
              child: ListView(
                shrinkWrap: true,
                children: [
                  for (final b in list)
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      title: Text(b, style: AppText.body),
                      trailing: _breed == b
                          ? const Icon(Icons.check, color: AppColors.primary)
                          : null,
                      onTap: () => Navigator.pop(context, b),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
    if (picked != null) setState(() => _breed = picked);
  }

  Widget _breedField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("Breed", style: AppText.secondary),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: _pickBreed,
          child: Container(
            height: 54,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(16)),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    _breed.isEmpty ? "Select..." : _breed,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: _breed.isEmpty ? AppText.secondary : AppText.body,
                  ),
                ),
                const Icon(Icons.expand_more, color: AppColors.textSecondary),
              ],
            ),
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
          decoration: BoxDecoration(
              color: AppColors.surface, borderRadius: BorderRadius.circular(16)),
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
      String photoBase64 = _isEdit ? _existingBase64 : "";
      if (_photos.isNotEmpty) {
        try {
          final bytes = await _photos.first.readAsBytes();
          if (bytes.lengthInBytes <= 700 * 1024) {
            photoBase64 = base64Encode(bytes);
          }
        } catch (_) {}
      }
      final name = _name.text.trim().isEmpty ? "Unnamed" : _name.text.trim();
      final breed = _breed.isEmpty ? _species_[_species] : _breed;
      final age = _age.text.trim().isEmpty ? "-" : _age.text.trim();
      final weight = _weight.text.trim().isEmpty ? "-" : _weight.text.trim();
      final city = _city.text.trim().isEmpty ? "Cairo" : _city.text.trim();
      final gender = _gender == 0 ? "Female" : "Male";
      final size = _sizes[_size];
      final desc = _desc.text.trim();
      final health = _health.text.trim();

      if (_isEdit) {
        await AnimalRepository().updateAnimal(
          widget.existing!.id,
          name: name,
          species: species,
          breed: breed,
          age: age,
          gender: gender,
          size: size,
          weight: weight,
          city: city,
          description: desc,
          health: health,
          photoBase64: photoBase64,
        );
      } else {
        await AnimalRepository().addAnimal(
          name: name,
          species: species,
          breed: breed,
          age: age,
          gender: gender,
          size: size,
          weight: weight,
          city: city,
          description: desc,
          health: health,
          photoBase64: photoBase64,
        );
      }
      if (!mounted) return;
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(_isEdit ? "Listing updated!" : "Listing posted!")),
      );
    } catch (_) {
      if (mounted) setState(() => _posting = false);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text("Could not save — check your connection and try again.")),
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
