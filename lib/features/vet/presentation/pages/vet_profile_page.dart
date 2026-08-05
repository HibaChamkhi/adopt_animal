import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:adopt_animal/core/app_icons.dart';
import 'package:adopt_animal/core/app_theme.dart';
import 'package:adopt_animal/core/sample_data.dart';
import 'package:adopt_animal/core/widgets/settings_widgets.dart';
import 'package:adopt_animal/features/vet/presentation/pages/vet_chat_page.dart';
import 'package:adopt_animal/features/vet/presentation/pages/book_appointment_page.dart';

class VetProfilePage extends StatelessWidget {
  final Vet vet;
  const VetProfilePage({super.key, required this.vet});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                  child: const AppIcon(AppIcons.arrowBack, size: 20, color: AppColors.primaryDark),
                ),
              ),
              const SizedBox(height: 8),
              Center(
                child: Column(
                  children: [
                    Container(
                      width: 88,
                      height: 88,
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: Center(
                        child: Text(vet.initials,
                            style: const TextStyle(
                                color: AppColors.primary, fontWeight: FontWeight.w700, fontSize: 30)),
                      ),
                    ),
                    const SizedBox(height: 14),
                    Text(vet.name, style: AppText.heading),
                    const SizedBox(height: 4),
                    Text("${vet.specialty} · ${vet.experience}", style: AppText.secondary),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(child: _stat("${vet.rating}", "Rating")),
                  _divider(),
                  Expanded(child: _stat(vet.patients, "Patients")),
                  _divider(),
                  Expanded(child: _stat("EGP ${vet.price}", "Per visit")),
                ],
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: _actionCard(context, AppIcons.chat, "Chat", filled: false,
                        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => VetChatPage(vet: vet)))),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _actionCard(context, AppIcons.call, "Call", filled: false,
                        onTap: () => _call(context, vet.phone)),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _actionCard(context, AppIcons.event, "Book", filled: true,
                        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => BookAppointmentPage(vet: vet)))),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              const Text("About", style: AppText.secondary),
              const SizedBox(height: 8),
              Text(vet.about, style: AppText.body),
              const SizedBox(height: 20),
              const Text("Clinic", style: AppText.secondary),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(18),
                  boxShadow: const [
                    BoxShadow(color: Color(0x0F1F2A44), blurRadius: 14, offset: Offset(0, 6)),
                  ],
                ),
                child: Column(
                  children: [
                    _clinicRow(AppIcons.location, vet.address),
                    const SizedBox(height: 12),
                    _clinicRow(AppIcons.schedule, vet.hours),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _call(BuildContext context, String phone) async {
    final uri = Uri(scheme: 'tel', path: phone);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Can't open dialer for $phone")),
      );
    }
  }

  void _stub(BuildContext context, String title) => Navigator.push(
      context, MaterialPageRoute(builder: (_) => ComingSoonPage(title: title)));

  Widget _stat(String value, String label) {
    return Column(
      children: [
        Text(value,
            style: const TextStyle(
                fontSize: 18, fontWeight: FontWeight.w800, color: AppColors.primaryDark)),
        const SizedBox(height: 2),
        Text(label, style: AppText.secondary),
      ],
    );
  }

  Widget _divider() =>
      Container(width: 1, height: 34, color: AppColors.stroke);

  Widget _actionCard(BuildContext context, String icon, String label,
      {required bool filled, VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 78,
        decoration: BoxDecoration(
          color: filled ? AppColors.primary : AppColors.surface,
          borderRadius: BorderRadius.circular(18),
          boxShadow: const [
            BoxShadow(color: Color(0x0F1F2A44), blurRadius: 12, offset: Offset(0, 4)),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AppIcon(icon, size: 24, color: filled ? Colors.white : AppColors.primary),
            const SizedBox(height: 6),
            Text(label,
                style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                    color: filled ? Colors.white : AppColors.primaryDark)),
          ],
        ),
      ),
    );
  }

  Widget _clinicRow(String icon, String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppIcon(icon, size: 20, color: AppColors.primary),
        const SizedBox(width: 12),
        Expanded(
          child: Text(text,
              style: const TextStyle(
                  fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.primaryDark)),
        ),
      ],
    );
  }
}
