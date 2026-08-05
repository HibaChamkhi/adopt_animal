import 'package:flutter/material.dart';
import 'package:adopt_animal/core/app_theme.dart';
import 'package:adopt_animal/core/widgets/app_widgets.dart';
import 'package:adopt_animal/features/vet/data/appointment_repository.dart';
import 'package:firebase_auth/firebase_auth.dart';

class _Appt {
  final String day, month, vet, time, clinic, reason;
  final String status; // Confirmed / Requested
  _Appt(this.day, this.month, this.vet, this.time, this.clinic, this.reason, this.status);
}

class AppointmentsPage extends StatefulWidget {
  const AppointmentsPage({super.key});

  @override
  State<AppointmentsPage> createState() => _AppointmentsPageState();
}

class _AppointmentsPageState extends State<AppointmentsPage> {
  int _tab = 0;

  final _upcoming = [
    _Appt("21", "JUL", "Dr. Ahmed Hassan", "3:00 PM", "Golden Paws Clinic",
        "Ear irritation follow-up · Luna", "Confirmed"),
    _Appt("28", "JUL", "Dr. Mona Nabil", "11:30 AM", "Whiskers Vet Center",
        "Annual vaccines · Milo", "Requested"),
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
              const Text("Appointments", style: AppText.heading),
              const SizedBox(height: 16),
              _tabs(),
              const SizedBox(height: 16),
              Expanded(
                child: _tab == 0
                    ? StreamBuilder<List<Appointment>>(
                        stream: AppointmentRepository()
                            .watchMine(FirebaseAuth.instance.currentUser?.uid ?? ""),
                        builder: (context, snap) {
                          final list = (snap.hasData && snap.data!.isNotEmpty)
                              ? snap.data!
                                  .map((a) => _Appt(a.day, a.month, a.vetName, a.time,
                                      a.clinic, a.reason, a.status))
                                  .toList()
                              : _upcoming;
                          return ListView.separated(
                            padding: const EdgeInsets.only(bottom: 16),
                            itemCount: list.length,
                            separatorBuilder: (_, __) => const SizedBox(height: 14),
                            itemBuilder: (context, i) => _card(list[i]),
                          );
                        },
                      )
                    : const EmptyState(
                        icon: Icons.event_available_outlined,
                        title: "No past appointments",
                        subtitle: "Your visit history will show up here.",
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _tabs() {
    return Container(
      padding: const EdgeInsets.all(5),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(28),
      ),
      child: Row(
        children: [
          _tabBtn("Upcoming", 0),
          _tabBtn("Past", 1),
        ],
      ),
    );
  }

  Widget _tabBtn(String label, int i) {
    final selected = _tab == i;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _tab = i),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: selected ? AppColors.primary : Colors.transparent,
            borderRadius: BorderRadius.circular(24),
          ),
          child: Text(label,
              style: TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 15,
                  color: selected ? Colors.white : AppColors.textSecondary)),
        ),
      ),
    );
  }

  Widget _card(_Appt a) {
    final requested = a.status == "Requested";
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
        boxShadow: const [
          BoxShadow(color: Color(0x0F1F2A44), blurRadius: 14, offset: Offset(0, 6)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 52, height: 52,
                decoration: BoxDecoration(
                  color: requested ? AppColors.primary.withOpacity(0.12) : AppColors.primary,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(a.day,
                        style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            color: requested ? AppColors.primary : Colors.white)),
                    Text(a.month,
                        style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: requested ? AppColors.primary : Colors.white70)),
                  ],
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(a.vet,
                        style: const TextStyle(
                            fontWeight: FontWeight.w700, fontSize: 15, color: AppColors.primaryDark)),
                    const SizedBox(height: 2),
                    Text("${a.time} · ${a.clinic}", style: AppText.secondary),
                    const SizedBox(height: 2),
                    Text(a.reason, style: AppText.secondary),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              StatusBadge(
                label: a.status,
                type: requested ? BadgeType.warning : BadgeType.success,
              ),
            ],
          ),
          const SizedBox(height: 14),
          if (requested)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                color: AppColors.warningBg,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: const [
                  Icon(Icons.hourglass_top, size: 18, color: AppColors.warning),
                  SizedBox(width: 8),
                  Text("Waiting for the vet to confirm",
                      style: TextStyle(color: AppColors.warning, fontWeight: FontWeight.w600, fontSize: 13)),
                ],
              ),
            )
          else
            Row(
              children: [
                Expanded(child: _actionBtn(context, "Reschedule", AppColors.primary)),
                const SizedBox(width: 12),
                Expanded(child: _actionBtn(context, "Cancel", const Color(0xFFE05B5B))),
              ],
            ),
        ],
      ),
    );
  }

  Widget _actionBtn(BuildContext context, String label, Color color) {
    return SizedBox(
      height: 46,
      child: OutlinedButton(
        onPressed: () => ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text("$label — coming soon"))),
        style: OutlinedButton.styleFrom(
          foregroundColor: color,
          side: BorderSide(color: color.withOpacity(0.4)),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        ),
        child: Text(label, style: const TextStyle(fontWeight: FontWeight.w700)),
      ),
    );
  }
}
