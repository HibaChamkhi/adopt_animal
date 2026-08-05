import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:adopt_animal/core/app_icons.dart';
import 'package:adopt_animal/core/app_theme.dart';
import 'package:adopt_animal/core/widgets/app_widgets.dart';
import 'package:adopt_animal/core/widgets/settings_widgets.dart';
import 'package:adopt_animal/injection.dart' as di;
import 'package:adopt_animal/features/auth/domain/entities/user_entity.dart';
import 'package:adopt_animal/features/auth/domain/useCases/get_current_user_use_case.dart';

class PersonalInfoPage extends StatefulWidget {
  const PersonalInfoPage({super.key});

  @override
  State<PersonalInfoPage> createState() => _PersonalInfoPageState();
}

class _PersonalInfoPageState extends State<PersonalInfoPage> {
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _phone = TextEditingController();
  String _city = "Cairo";
  static const _cities = ["Cairo", "Giza", "Alexandria", "Other"];

  @override
  void initState() {
    super.initState();
    di.sl<GetCurrentUserUseCase>().call().then((UserEntity u) {
      if (!mounted) return;
      setState(() {
        _name.text = u.name ?? "";
        _email.text = u.email ?? "";
        _phone.text = u.phone ?? "";
        if (u.city != null && _cities.contains(u.city)) _city = u.city!;
      });
    }).catchError((_) {});
  }

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _phone.dispose();
    super.dispose();
  }

  String get _initial => _name.text.isNotEmpty ? _name.text[0].toUpperCase() : "?";

  Future<void> _save() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid != null) {
      try {
        await FirebaseFirestore.instance.collection('users').doc(uid).set({
          'name': _name.text.trim(),
          'phone': _phone.text.trim(),
          'city': _city,
        }, SetOptions(merge: true));
      } catch (_) {}
    }
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Changes saved")),
    );
    Navigator.pop(context);
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
              const SubPageHeader("Personal information"),
              const SizedBox(height: 20),
              Center(child: _avatar()),
              const SizedBox(height: 24),
              _field("Full name", _name),
              const SizedBox(height: 16),
              _field("Email", _email),
              const SizedBox(height: 16),
              _field("Phone", _phone),
              const SizedBox(height: 16),
              _cityField(),
            ],
          ),
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
          child: PrimaryButton(
            label: "Save changes",
            onTap: _save,
          ),
        ),
      ),
    );
  }

  Widget _avatar() {
    return SizedBox(
      width: 96,
      height: 96,
      child: Stack(
        children: [
          Container(
            width: 90,
            height: 90,
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.12),
              borderRadius: BorderRadius.circular(24),
            ),
            child: Center(
              child: Text(
                _initial,
                style: const TextStyle(
                    color: AppColors.primary, fontWeight: FontWeight.w700, fontSize: 32),
              ),
            ),
          ),
          Positioned(
            right: 0,
            bottom: 4,
            child: Container(
              padding: const EdgeInsets.all(7),
              decoration: const BoxDecoration(color: AppColors.primary, shape: BoxShape.circle),
              child: const AppIcon(AppIcons.edit, size: 14, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  Widget _field(String label, TextEditingController c) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppText.secondary),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(16),
          ),
          child: TextField(
            controller: c,
            style: AppText.body,
            decoration: const InputDecoration(
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(vertical: 16),
            ),
          ),
        ),
      ],
    );
  }

  Widget _cityField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("City", style: AppText.secondary),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(16),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: _city,
              isExpanded: true,
              icon: const Icon(Icons.expand_more, color: AppColors.textSecondary),
              style: AppText.body,
              items: _cities
                  .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                  .toList(),
              onChanged: (v) => setState(() => _city = v ?? _city),
            ),
          ),
        ),
      ],
    );
  }
}
