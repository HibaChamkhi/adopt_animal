import 'package:flutter/material.dart';
import 'package:adopt_animal/core/app_icons.dart';
import 'package:adopt_animal/core/app_theme.dart';
import 'package:adopt_animal/core/sample_data.dart';
import 'package:adopt_animal/core/widgets/app_widgets.dart';
import 'package:adopt_animal/features/adoption/data/adoption_request_repository.dart';

class AdoptionRequestPage extends StatefulWidget {
  final Animal animal;
  const AdoptionRequestPage({super.key, required this.animal});

  @override
  State<AdoptionRequestPage> createState() => _AdoptionRequestPageState();
}

class _AdoptionRequestPageState extends State<AdoptionRequestPage> {
  late final TextEditingController _message;
  bool _outdoor = true;
  bool _ownedBefore = true;
  bool _otherPets = false;

  String get _ownerFirst => widget.animal.ownerName.split(' ').first;

  Future<void> _send() async {
    final a = widget.animal;
    try {
      await AdoptionRequestRepository().send(
        animalId: a.id,
        animalName: a.name,
        breed: a.breed,
        ownerId: a.ownerId,
        ownerName: a.ownerName,
        message: _message.text.trim(),
        home: {
          "outdoor": _outdoor,
          "ownedBefore": _ownedBefore,
          "otherPets": _otherPets,
        },
      );
      if (!mounted) return;
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Request sent to $_ownerFirst")),
      );
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Could not send — check your Firestore rules/connection.")),
      );
    }
  }

  @override
  void initState() {
    super.initState();
    _message = TextEditingController(
      text:
          "Hi $_ownerFirst! We're a family of four with a big garden and we've had ${widget.animal.species}s before. We'd love to give ${widget.animal.name} a home...",
    );
  }

  @override
  void dispose() {
    _message.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final a = widget.animal;
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                      child: const AppIcon(AppIcons.arrowBack, size: 20, color: AppColors.primaryDark),
                    ),
                  ),
                  const SizedBox(width: 14),
                  const Text("Adoption request", style: AppText.title),
                ],
              ),
              const SizedBox(height: 20),
              Container(
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
                      width: 56,
                      height: 56,
                      child: StripedPlaceholder(label: a.species, borderRadius: 14),
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(a.name,
                            style: const TextStyle(
                                fontWeight: FontWeight.w700,
                                fontSize: 16,
                                color: AppColors.primaryDark)),
                        const SizedBox(height: 2),
                        Text("${a.breed} · ${a.ownerName}", style: AppText.secondary),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 22),
              const Text("Message to the owner", style: AppText.secondary),
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: TextField(
                  controller: _message,
                  maxLines: 5,
                  style: AppText.body,
                  decoration: const InputDecoration(border: InputBorder.none),
                ),
              ),
              const SizedBox(height: 22),
              const Text("Your home", style: AppText.secondary),
              const SizedBox(height: 10),
              _toggle("I have a private outdoor space", _outdoor, (v) => setState(() => _outdoor = v)),
              const SizedBox(height: 12),
              _toggle("I've owned a ${a.species} before", _ownedBefore, (v) => setState(() => _ownedBefore = v)),
              const SizedBox(height: 12),
              _toggle("Other pets at home", _otherPets, (v) => setState(() => _otherPets = v)),
            ],
          ),
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              PrimaryButton(
                label: "Send request",
                onTap: _send,
              ),
              const SizedBox(height: 10),
              Text(
                "$_ownerFirst will be notified and can accept or decline.",
                style: AppText.secondary,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _toggle(String label, bool value, ValueChanged<bool> onChanged) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 15,
                color: AppColors.primaryDark,
              ),
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: Colors.white,
            activeTrackColor: AppColors.primary,
          ),
        ],
      ),
    );
  }
}
