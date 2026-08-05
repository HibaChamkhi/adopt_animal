import 'package:flutter/material.dart';
import 'package:adopt_animal/core/app_icons.dart';
import 'package:adopt_animal/core/app_theme.dart';
import 'package:adopt_animal/core/widgets/settings_widgets.dart';

class _Notif {
  final String icon, boldPart, rest, time;
  final bool unread;
  _Notif(this.icon, this.boldPart, this.rest, this.time, {this.unread = false});
}

class NotificationsPage extends StatefulWidget {
  const NotificationsPage({super.key});

  @override
  State<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  late List<_Notif> _items = [
    _Notif(AppIcons.pets, "Adoption request accepted! ", "Omar approved your request for Luna.", "5 min ago", unread: true),
    _Notif(AppIcons.chat, "Dr. Ahmed ", "replied to your message.", "22 min ago", unread: true),
    _Notif(AppIcons.shipping, "Order #1042 ", "has shipped — arriving Thursday.", "2 h ago"),
    _Notif(AppIcons.event, "Reminder: ", "appointment with Dr. Ahmed tomorrow at 3:00 PM.", "Yesterday"),
    _Notif(AppIcons.favorite, "Milo, ", "a cat you saved, was just adopted.", "2 days ago"),
  ];

  void _markAllRead() {
    setState(() {
      _items = _items
          .map((n) => _Notif(n.icon, n.boldPart, n.rest, n.time, unread: false))
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
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
                      const Text("Notifications", style: AppText.title),
                    ],
                  ),
                  GestureDetector(
                    onTap: _markAllRead,
                    child: const Text("Mark all read",
                        style: TextStyle(
                            color: AppColors.primary, fontWeight: FontWeight.w600, fontSize: 14)),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Expanded(
                child: ListView.separated(
                  padding: const EdgeInsets.only(bottom: 16),
                  itemCount: _items.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (context, i) => _card(_items[i]),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _card(_Notif n) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: n.unread ? AppColors.surface : AppColors.surface.withOpacity(0.7),
        borderRadius: BorderRadius.circular(18),
        boxShadow: const [
          BoxShadow(color: Color(0x0A1F2A44), blurRadius: 10, offset: Offset(0, 3)),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          IconBadge(child: AppIcon(n.icon, size: 20, color: AppColors.primary)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text.rich(TextSpan(children: [
                  TextSpan(text: n.boldPart,
                      style: const TextStyle(
                          fontWeight: FontWeight.w700, fontSize: 14.5, color: AppColors.primaryDark)),
                  TextSpan(text: n.rest,
                      style: const TextStyle(fontSize: 14.5, color: AppColors.primaryDark, height: 1.3)),
                ])),
                const SizedBox(height: 4),
                Text(n.time, style: AppText.secondary),
              ],
            ),
          ),
          if (n.unread)
            Container(
              margin: const EdgeInsets.only(left: 8, top: 4),
              width: 9, height: 9,
              decoration: const BoxDecoration(color: AppColors.primary, shape: BoxShape.circle),
            ),
        ],
      ),
    );
  }
}
