import 'dart:async';

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:adopt_animal/core/app_icons.dart';
import 'package:adopt_animal/core/app_theme.dart';
import 'package:adopt_animal/core/widgets/app_widgets.dart';
import 'package:adopt_animal/core/widgets/settings_widgets.dart';
import 'package:adopt_animal/features/adoption/data/adoption_request_repository.dart';
import 'package:adopt_animal/features/vet/data/appointment_repository.dart';
import 'package:adopt_animal/features/shop/data/order_repository.dart';

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
  final String _uid = FirebaseAuth.instance.currentUser?.uid ?? "";
  List<AdoptionRequest> _requests = [];
  List<Appointment> _appts = [];
  List<OrderSummary> _orders = [];
  final List<StreamSubscription> _subs = [];
  bool _ready = false;

  @override
  void initState() {
    super.initState();
    _subs.add(AdoptionRequestRepository().watchForOwner(_uid).listen((v) {
      if (mounted) setState(() { _requests = v; _ready = true; });
    }));
    _subs.add(AppointmentRepository().watchMine(_uid).listen((v) {
      if (mounted) setState(() { _appts = v; _ready = true; });
    }));
    _subs.add(OrderRepository().watchMyOrders(_uid).listen((v) {
      if (mounted) setState(() { _orders = v; _ready = true; });
    }));
  }

  @override
  void dispose() {
    for (final s in _subs) {
      s.cancel();
    }
    super.dispose();
  }

  List<_Notif> _build() {
    final items = <_Notif>[];

    for (final r in _requests) {
      final s = r.status.toLowerCase();
      items.add(_Notif(
        AppIcons.pets,
        "${r.adopterName} ",
        "requested to adopt ${r.animalName}.",
        s == 'pending'
            ? "Adoption request · awaiting your response"
            : "Adoption request · ${r.status}",
        unread: s == 'pending',
      ));
    }

    for (final a in _appts) {
      final s = a.status.toLowerCase();
      if (s == 'cancelled') continue;
      final confirmed = s == 'confirmed';
      items.add(_Notif(
        AppIcons.event,
        "${a.vetName} ",
        confirmed
            ? "confirmed your appointment."
            : "— appointment awaiting confirmation.",
        "${a.day} ${a.month} · ${a.time}",
        unread: !confirmed,
      ));
    }

    for (final o in _orders) {
      items.add(_Notif(
        AppIcons.shipping,
        "Order ",
        "${o.status} — ${o.itemCount} item${o.itemCount == 1 ? '' : 's'}, EGP ${o.total}.",
        "Order #${o.id.substring(0, o.id.length < 6 ? o.id.length : 6)}",
        unread: o.status.toLowerCase() == 'pending',
      ));
    }

    return items;
  }

  @override
  Widget build(BuildContext context) {
    final items = _build();
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: const BoxDecoration(
                          color: Colors.white, shape: BoxShape.circle),
                      child: const AppIcon(AppIcons.arrowBack,
                          size: 20, color: AppColors.primaryDark),
                    ),
                  ),
                  const SizedBox(width: 14),
                  const Text("Notifications", style: AppText.title),
                ],
              ),
              const SizedBox(height: 16),
              Expanded(
                child: !_ready
                    ? const Center(child: CircularProgressIndicator())
                    : items.isEmpty
                        ? const EmptyState(
                            icon: Icons.notifications_none,
                            title: "No notifications yet",
                            subtitle:
                                "Adoption requests, appointments and orders will show up here.",
                          )
                        : ListView.separated(
                            padding: const EdgeInsets.only(bottom: 16),
                            itemCount: items.length,
                            separatorBuilder: (_, __) =>
                                const SizedBox(height: 12),
                            itemBuilder: (context, i) => _card(items[i]),
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
                  TextSpan(
                      text: n.boldPart,
                      style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 14.5,
                          color: AppColors.primaryDark)),
                  TextSpan(
                      text: n.rest,
                      style: const TextStyle(
                          fontSize: 14.5,
                          color: AppColors.primaryDark,
                          height: 1.3)),
                ])),
                const SizedBox(height: 4),
                Text(n.time, style: AppText.secondary),
              ],
            ),
          ),
          if (n.unread)
            Container(
              margin: const EdgeInsets.only(left: 8, top: 4),
              width: 9,
              height: 9,
              decoration: const BoxDecoration(
                  color: AppColors.primary, shape: BoxShape.circle),
            ),
        ],
      ),
    );
  }
}
