import 'package:flutter/material.dart';
import 'package:adopt_animal/core/app_theme.dart';
import 'package:adopt_animal/core/sample_data.dart';
import 'package:adopt_animal/core/widgets/app_widgets.dart';
import 'package:adopt_animal/core/widgets/settings_widgets.dart';
import 'package:adopt_animal/features/vet/data/appointment_repository.dart';

class BookAppointmentPage extends StatefulWidget {
  final Vet vet;
  const BookAppointmentPage({super.key, required this.vet});

  @override
  State<BookAppointmentPage> createState() => _BookAppointmentPageState();
}

class _BookAppointmentPageState extends State<BookAppointmentPage> {
  int _date = 1;
  int _time = 3;
  final _reason = TextEditingController(text: "Ear irritation follow-up");

  final _dates = const [
    ["Mon", "20"], ["Tue", "21"], ["Wed", "22"], ["Thu", "23"], ["Fri", "24"],
  ];
  final _times = const [
    ["10:00 AM", "1"], ["11:30 AM", "1"], ["1:00 PM", "0"],
    ["3:00 PM", "1"], ["4:30 PM", "1"], ["6:00 PM", "1"],
  ];

  @override
  void dispose() {
    _reason.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final v = widget.vet;
    final confirmLabel =
        "Confirm · ${_dates[_date][0]} ${_dates[_date][1]}, ${_times[_time][0]}";
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SubPageHeader("Book appointment"),
              const SizedBox(height: 20),
              Container(
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
                      width: 48, height: 48,
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Center(
                        child: Text(v.initials,
                            style: const TextStyle(
                                color: AppColors.primary, fontWeight: FontWeight.w700, fontSize: 16)),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(v.name,
                              style: const TextStyle(
                                  fontWeight: FontWeight.w700, fontSize: 15, color: AppColors.primaryDark)),
                          const SizedBox(height: 2),
                          Text("${v.clinic} · EGP ${v.price}", style: AppText.secondary),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              const Text("July 2026", style: AppText.secondary),
              const SizedBox(height: 12),
              Row(
                children: [
                  for (int i = 0; i < _dates.length; i++) ...[
                    Expanded(child: _dateCell(i)),
                    if (i != _dates.length - 1) const SizedBox(width: 8),
                  ],
                ],
              ),
              const SizedBox(height: 24),
              const Text("Available times", style: AppText.secondary),
              const SizedBox(height: 12),
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: [
                  for (int i = 0; i < _times.length; i++) _timeChip(i),
                ],
              ),
              const SizedBox(height: 24),
              const Text("Reason for visit", style: AppText.secondary),
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: TextField(
                  controller: _reason,
                  style: AppText.body,
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(vertical: 16),
                  ),
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
            label: confirmLabel,
            onTap: () async {
              try {
                await AppointmentRepository().book(
                  vetId: v.name,
                  vetName: v.name,
                  clinic: v.clinic,
                  day: _dates[_date][1],
                  month: "JUL",
                  time: _times[_time][0],
                  reason: _reason.text.trim(),
                );
              } catch (_) {}
              if (!context.mounted) return;
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text("Appointment requested — $confirmLabel")),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _dateCell(int i) {
    final selected = _date == i;
    return GestureDetector(
      onTap: () => setState(() => _date = i),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: selected ? AppColors.primary : AppColors.surface,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          children: [
            Text(_dates[i][0],
                style: TextStyle(
                    fontSize: 12, color: selected ? Colors.white70 : AppColors.textSecondary)),
            const SizedBox(height: 4),
            Text(_dates[i][1],
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: selected ? Colors.white : AppColors.primaryDark)),
          ],
        ),
      ),
    );
  }

  Widget _timeChip(int i) {
    final enabled = _times[i][1] == "1";
    final selected = _time == i && enabled;
    final width = (MediaQuery.of(context).size.width - 40 - 24) / 3;
    return GestureDetector(
      onTap: enabled ? () => setState(() => _time = i) : null,
      child: Container(
        width: width,
        padding: const EdgeInsets.symmetric(vertical: 14),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: selected ? AppColors.primary : AppColors.surface,
          borderRadius: BorderRadius.circular(24),
        ),
        child: Text(
          _times[i][0],
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 14,
            decoration: enabled ? null : TextDecoration.lineThrough,
            color: !enabled
                ? AppColors.textSecondary
                : selected
                    ? Colors.white
                    : AppColors.primary,
          ),
        ),
      ),
    );
  }
}
