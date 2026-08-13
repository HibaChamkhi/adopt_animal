import 'package:flutter/material.dart';
import 'package:adopt_animal/core/app_theme.dart';
import 'package:adopt_animal/core/widgets/app_widgets.dart';
import 'package:adopt_animal/features/vet/data/appointment_repository.dart';
import 'package:firebase_auth/firebase_auth.dart';

class _Appt {
  final String id, day, month, vet, time, clinic, reason;
  final String status; // Confirmed / Requested / Cancelled
  _Appt(this.id, this.day, this.month, this.vet, this.time, this.clinic,
      this.reason, this.status);
}

class AppointmentsPage extends StatefulWidget {
  const AppointmentsPage({super.key});

  @override
  State<AppointmentsPage> createState() => _AppointmentsPageState();
}

class _AppointmentsPageState extends State<AppointmentsPage> {
  int _tab = 0;

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
                          if (snap.connectionState == ConnectionState.waiting) {
                            return const Center(child: CircularProgressIndicator());
                          }
                          final list = (snap.data ?? const <Appointment>[])
                              .where((a) => a.status != 'Cancelled')
                              .map((a) => _Appt(a.id, a.day, a.month, a.vetName,
                                  a.time, a.clinic, a.reason, a.status))
                              .toList();
                          if (list.isEmpty) {
                            return const EmptyState(
                              icon: Icons.event_outlined,
                              title: "No upcoming appointments",
                              subtitle: "Book a vet visit and it'll show up here.",
                            );
                          }
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
          if (requested) ...[
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
            ),
            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              child: _actionBtn("Cancel", const Color(0xFFE05B5B), () => _cancel(a)),
            ),
          ] else
            Row(
              children: [
                Expanded(
                    child: _actionBtn(
                        "Reschedule", AppColors.primary, () => _reschedule(a))),
                const SizedBox(width: 12),
                Expanded(
                    child: _actionBtn(
                        "Cancel", const Color(0xFFE05B5B), () => _cancel(a))),
              ],
            ),
        ],
      ),
    );
  }

  Widget _actionBtn(String label, Color color, VoidCallback onPressed) {
    return SizedBox(
      height: 46,
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          foregroundColor: color,
          side: BorderSide(color: color.withOpacity(0.4)),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        ),
        child: Text(label, style: const TextStyle(fontWeight: FontWeight.w700)),
      ),
    );
  }

  void _snack(String m) =>
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(m)));

  Future<void> _cancel(_Appt a) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Cancel appointment?"),
        content: Text("Cancel your appointment with ${a.vet}?"),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text("Keep")),
          TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text("Cancel it")),
        ],
      ),
    );
    if (ok != true) return;
    try {
      await AppointmentRepository().updateStatus(a.id, 'cancelled');
      if (mounted) _snack("Appointment cancelled");
    } catch (_) {
      if (mounted) _snack("Couldn't cancel — try again");
    }
  }

  Future<void> _reschedule(_Appt a) async {
    final now = DateTime.now();
    final date = await showDatePicker(
      context: context,
      initialDate: now.add(const Duration(days: 1)),
      firstDate: now,
      lastDate: now.add(const Duration(days: 365)),
    );
    if (date == null || !mounted) return;
    final time = await showTimePicker(
      context: context,
      initialTime: const TimeOfDay(hour: 10, minute: 0),
    );
    if (time == null || !mounted) return;
    const months = [
      "JAN", "FEB", "MAR", "APR", "MAY", "JUN",
      "JUL", "AUG", "SEP", "OCT", "NOV", "DEC"
    ];
    try {
      await AppointmentRepository().reschedule(
        a.id,
        day: date.day.toString(),
        month: months[date.month - 1],
        time: time.format(context),
      );
      if (mounted) _snack("Rescheduled — awaiting vet confirmation");
    } catch (_) {
      if (mounted) _snack("Couldn't reschedule — try again");
    }
  }
}
