import 'package:flutter/material.dart';
import 'package:adopt_animal/core/app_icons.dart';
import 'package:adopt_animal/core/app_theme.dart';
import 'package:adopt_animal/core/widgets/settings_widgets.dart';

class NotificationsSettingsPage extends StatefulWidget {
  const NotificationsSettingsPage({super.key});

  @override
  State<NotificationsSettingsPage> createState() => _NotificationsSettingsPageState();
}

class _NotificationsSettingsPageState extends State<NotificationsSettingsPage> {
  bool _push = true;
  bool _requests = true;
  bool _messages = true;
  bool _orders = true;
  bool _appointments = true;
  bool _offers = false;

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
              const SubPageHeader("Notifications"),
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(18),
                  boxShadow: const [
                    BoxShadow(color: Color(0x0F1F2A44), blurRadius: 14, offset: Offset(0, 6)),
                  ],
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Text("Push notifications",
                              style: TextStyle(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 15,
                                  color: AppColors.primaryDark)),
                          SizedBox(height: 2),
                          Text("Master switch for all alerts", style: AppText.secondary),
                        ],
                      ),
                    ),
                    AppSwitch(value: _push, onChanged: (v) => setState(() => _push = v)),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              const SectionLabel("Notify me about"),
              CardGroup(
                children: [
                  SettingsRow(
                    leading: const AppIcon(AppIcons.pets, size: 22, color: AppColors.primary),
                    title: "Adoption requests",
                    subtitle: "Accepted, declined, new requests",
                    trailing: AppSwitch(value: _requests, onChanged: (v) => setState(() => _requests = v)),
                  ),
                  SettingsRow(
                    leading: const AppIcon(AppIcons.chat, size: 22, color: AppColors.primary),
                    title: "Messages",
                    subtitle: "Chats with vets and owners",
                    trailing: AppSwitch(value: _messages, onChanged: (v) => setState(() => _messages = v)),
                  ),
                  SettingsRow(
                    leading: const AppIcon(AppIcons.shipping, size: 22, color: AppColors.primary),
                    title: "Order updates",
                    subtitle: "Confirmations, shipping, delivery",
                    trailing: AppSwitch(value: _orders, onChanged: (v) => setState(() => _orders = v)),
                  ),
                  SettingsRow(
                    leading: const AppIcon(AppIcons.event, size: 22, color: AppColors.primary),
                    title: "Appointment reminders",
                    subtitle: "24h and 1h before visits",
                    trailing: AppSwitch(value: _appointments, onChanged: (v) => setState(() => _appointments = v)),
                  ),
                  SettingsRow(
                    leading: const Icon(Icons.campaign_outlined, size: 22, color: AppColors.primary),
                    title: "Offers & tips",
                    subtitle: "Promotions and pet care tips",
                    trailing: AppSwitch(value: _offers, onChanged: (v) => setState(() => _offers = v)),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
