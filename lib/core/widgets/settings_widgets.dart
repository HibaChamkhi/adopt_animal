import 'package:flutter/material.dart';
import 'package:adopt_animal/core/app_icons.dart';
import 'package:adopt_animal/core/app_theme.dart';
import 'package:adopt_animal/core/widgets/app_widgets.dart';

class SectionLabel extends StatelessWidget {
  final String text;
  const SectionLabel(this.text, {super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 10),
      child: Text(
        text.toUpperCase(),
        style: const TextStyle(
          color: AppColors.primary,
          fontWeight: FontWeight.w700,
          fontSize: 13,
          letterSpacing: 1.0,
        ),
      ),
    );
  }
}

class IconBadge extends StatelessWidget {
  final Widget child;
  final Color color;
  const IconBadge({super.key, required this.child, this.color = AppColors.primary});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Center(child: child),
    );
  }
}

class SettingsRow extends StatelessWidget {
  final Widget leading;
  final Color badgeColor;
  final String title;
  final String? subtitle;
  final Widget? trailing;
  final Color? titleColor;
  final VoidCallback? onTap;

  const SettingsRow({
    super.key,
    required this.leading,
    required this.title,
    this.subtitle,
    this.trailing,
    this.titleColor,
    this.badgeColor = AppColors.primary,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        child: Row(
          children: [
            IconBadge(color: badgeColor, child: leading),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 15,
                      color: titleColor ?? AppColors.primaryDark,
                    ),
                  ),
                  if (subtitle != null) ...[
                    const SizedBox(height: 2),
                    Text(subtitle!, style: AppText.secondary),
                  ],
                ],
              ),
            ),
            trailing ??
                const AppIcon(AppIcons.chevronRight, size: 18, color: AppColors.textSecondary),
          ],
        ),
      ),
    );
  }
}

class CardGroup extends StatelessWidget {
  final List<Widget> children;
  const CardGroup({super.key, required this.children});

  @override
  Widget build(BuildContext context) {
    final rows = <Widget>[];
    for (int i = 0; i < children.length; i++) {
      rows.add(children[i]);
      if (i != children.length - 1) {
        rows.add(const Divider(height: 1, thickness: 1, indent: 68, color: AppColors.stroke));
      }
    }
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
        boxShadow: const [
          BoxShadow(color: Color(0x0F1F2A44), blurRadius: 14, offset: Offset(0, 6)),
        ],
      ),
      child: Column(children: rows),
    );
  }
}

class AppSwitch extends StatelessWidget {
  final bool value;
  final ValueChanged<bool> onChanged;
  const AppSwitch({super.key, required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Switch(
      value: value,
      onChanged: onChanged,
      activeColor: Colors.white,
      activeTrackColor: AppColors.primary,
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
    );
  }
}

class SubPageHeader extends StatelessWidget {
  final String title;
  const SubPageHeader(this.title, {super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
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
        Text(title, style: AppText.title),
      ],
    );
  }
}

class ComingSoonPage extends StatelessWidget {
  final String title;
  const ComingSoonPage({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
              child: SubPageHeader(title),
            ),
            const Expanded(
              child: EmptyState(
                icon: Icons.hourglass_empty,
                title: "Coming soon",
                subtitle: "We're building this next.",
              ),
            ),
          ],
        ),
      ),
    );
  }
}
