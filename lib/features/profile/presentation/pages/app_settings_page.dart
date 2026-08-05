import 'package:flutter/material.dart';
import 'package:adopt_animal/core/app_icons.dart';
import 'package:adopt_animal/core/app_theme.dart';
import 'package:adopt_animal/core/widgets/settings_widgets.dart';
import 'package:adopt_animal/features/profile/presentation/pages/personal_info_page.dart';
import 'package:adopt_animal/features/profile/presentation/pages/notifications_settings_page.dart';

class AppSettingsPage extends StatefulWidget {
  const AppSettingsPage({super.key});

  @override
  State<AppSettingsPage> createState() => _AppSettingsPageState();
}

class _AppSettingsPageState extends State<AppSettingsPage> {
  bool _dark = false;
  bool _location = true;

  void _push(Widget page) =>
      Navigator.push(context, MaterialPageRoute(builder: (_) => page));

  static const _chevron = AppIcon(AppIcons.chevronRight, size: 18, color: AppColors.textSecondary);

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
              const SubPageHeader("Settings"),
              const SizedBox(height: 24),
              const SectionLabel("Preferences"),
              CardGroup(
                children: [
                  SettingsRow(
                    leading: const AppIcon(AppIcons.notifications, size: 22, color: AppColors.primary),
                    title: "Notifications",
                    onTap: () => _push(const NotificationsSettingsPage()),
                  ),
                  SettingsRow(
                    leading: const Icon(Icons.language, size: 22, color: AppColors.primary),
                    title: "Language",
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: const [
                        Text("English", style: AppText.secondary),
                        SizedBox(width: 6),
                        _chevron,
                      ],
                    ),
                    onTap: () => _push(const ComingSoonPage(title: "Language")),
                  ),
                  SettingsRow(
                    leading: const Icon(Icons.dark_mode_outlined, size: 22, color: AppColors.primary),
                    title: "Dark mode",
                    trailing: AppSwitch(value: _dark, onChanged: (v) => setState(() => _dark = v)),
                  ),
                  SettingsRow(
                    leading: const AppIcon(AppIcons.location, size: 22, color: AppColors.primary),
                    title: "Location services",
                    trailing: AppSwitch(value: _location, onChanged: (v) => setState(() => _location = v)),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              const SectionLabel("Account"),
              CardGroup(
                children: [
                  SettingsRow(
                    leading: const AppIcon(AppIcons.person, size: 22, color: AppColors.primary),
                    title: "Personal information",
                    onTap: () => _push(const PersonalInfoPage()),
                  ),
                  SettingsRow(
                    leading: const AppIcon(AppIcons.home, size: 22, color: AppColors.primary),
                    title: "Saved addresses",
                    onTap: () => _push(const ComingSoonPage(title: "Saved addresses")),
                  ),
                  SettingsRow(
                    leading: const Icon(Icons.lock_outline, size: 22, color: AppColors.primary),
                    title: "Change password",
                    onTap: () => _push(const ComingSoonPage(title: "Change password")),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              const SectionLabel("Support"),
              CardGroup(
                children: [
                  SettingsRow(
                    leading: const Icon(Icons.help_outline, size: 22, color: AppColors.primary),
                    title: "Help center",
                    onTap: () => _push(const ComingSoonPage(title: "Help center")),
                  ),
                  SettingsRow(
                    leading: const Icon(Icons.privacy_tip_outlined, size: 22, color: AppColors.primary),
                    title: "Privacy policy",
                    onTap: () => _push(const ComingSoonPage(title: "Privacy policy")),
                  ),
                  SettingsRow(
                    leading: const AppIcon(AppIcons.delete, size: 22, color: Color(0xFFE05B5B)),
                    badgeColor: const Color(0xFFE05B5B),
                    title: "Delete account",
                    titleColor: const Color(0xFFE05B5B),
                    trailing: const AppIcon(AppIcons.chevronRight, size: 18, color: Color(0xFFE05B5B)),
                    onTap: () => ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Delete account — coming soon")),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              const Center(
                child: Text("Adopt Animal v1.0.0", style: AppText.secondary),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
