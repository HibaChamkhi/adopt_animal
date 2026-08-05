import 'package:flutter/material.dart';
import 'package:adopt_animal/core/app_icons.dart';
import 'package:adopt_animal/core/app_theme.dart';
import 'package:adopt_animal/core/widgets/app_widgets.dart';
import 'package:adopt_animal/features/shop/data/order_repository.dart';
import 'package:firebase_auth/firebase_auth.dart';

class _Order {
  final String id, meta, status;
  final int step; // -1 none, else 0..2 for tracker
  final String? arriving;
  _Order(this.id, this.meta, this.status, {this.step = -1, this.arriving});
}

class OrdersPage extends StatefulWidget {
  const OrdersPage({super.key});

  @override
  State<OrdersPage> createState() => _OrdersPageState();
}

class _OrdersPageState extends State<OrdersPage> {
  int _tab = 0;

  final _active = [
    _Order("Order #1042", "3 items · EGP 640 · placed July 16", "Shipped",
        step: 1, arriving: "Arriving Thursday, July 23"),
    _Order("Order #1039", "1 item · EGP 120 · placed July 19", "Pending"),
    _Order("Order #1024", "2 items · EGP 310 · delivered June 30", "Delivered"),
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
              const Text("My orders", style: AppText.heading),
              const SizedBox(height: 16),
              _tabs(),
              const SizedBox(height: 16),
              Expanded(
                child: _tab == 0
                    ? StreamBuilder<List<OrderSummary>>(
                        stream: OrderRepository()
                            .watchMyOrders(FirebaseAuth.instance.currentUser?.uid ?? ""),
                        builder: (context, snap) {
                          final orders = (snap.hasData && snap.data!.isNotEmpty)
                              ? snap.data!
                                  .map((o) => _Order(
                                        "Order #${o.id.substring(0, o.id.length < 4 ? o.id.length : 4).toUpperCase()}",
                                        "${o.itemCount} item(s) · EGP ${o.total}",
                                        o.status[0].toUpperCase() + o.status.substring(1),
                                      ))
                                  .toList()
                              : _active;
                          return ListView.separated(
                            padding: const EdgeInsets.only(bottom: 16),
                            itemCount: orders.length,
                            separatorBuilder: (_, __) => const SizedBox(height: 14),
                            itemBuilder: (context, i) => _card(orders[i]),
                          );
                        },
                      )
                    : const EmptyState(
                        icon: Icons.receipt_long_outlined,
                        title: "No past orders",
                        subtitle: "Completed orders will move here.",
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
      decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(28)),
      child: Row(children: [_tabBtn("Active", 0), _tabBtn("Past", 1)]),
    );
  }

  Widget _tabBtn(String label, int i) {
    final sel = _tab == i;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _tab = i),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: sel ? AppColors.primary : Colors.transparent,
            borderRadius: BorderRadius.circular(24),
          ),
          child: Text(label,
              style: TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 15,
                  color: sel ? Colors.white : AppColors.textSecondary)),
        ),
      ),
    );
  }

  Widget _statusBadge(String status) {
    Color bg, fg;
    if (status == "Delivered") {
      bg = AppColors.successBg; fg = AppColors.success;
    } else if (status == "Pending") {
      bg = AppColors.warningBg; fg = AppColors.warning;
    } else {
      bg = AppColors.primary.withOpacity(0.12); fg = AppColors.primary;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(20)),
      child: Text(status, style: TextStyle(color: fg, fontWeight: FontWeight.w600, fontSize: 13)),
    );
  }

  Widget _card(_Order o) {
    return Container(
      padding: const EdgeInsets.all(16),
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
            children: [
              Expanded(
                child: Text(o.id,
                    style: const TextStyle(
                        fontWeight: FontWeight.w800, fontSize: 17, color: AppColors.primaryDark)),
              ),
              _statusBadge(o.status),
            ],
          ),
          const SizedBox(height: 6),
          Text(o.meta, style: AppText.secondary),
          if (o.step >= 0) ...[
            const SizedBox(height: 16),
            _tracker(o.step),
            const SizedBox(height: 14),
            if (o.arriving != null)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.10),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    const AppIcon(AppIcons.shipping, size: 18, color: AppColors.primary),
                    const SizedBox(width: 8),
                    Text(o.arriving!,
                        style: const TextStyle(
                            color: AppColors.primary, fontWeight: FontWeight.w600, fontSize: 13)),
                  ],
                ),
              ),
          ],
        ],
      ),
    );
  }

  Widget _tracker(int step) {
    const labels = ["Confirmed", "Shipped", "Delivered"];
    return Column(
      children: [
        Row(
          children: [
            for (int i = 0; i < 3; i++) ...[
              _node(i <= step),
              if (i != 2) Expanded(child: Container(height: 3, color: i < step ? AppColors.primary : AppColors.stroke)),
            ],
          ],
        ),
        const SizedBox(height: 6),
        Row(
          children: [
            for (int i = 0; i < 3; i++)
              Expanded(
                child: Align(
                  alignment: i == 0
                      ? Alignment.centerLeft
                      : i == 2
                          ? Alignment.centerRight
                          : Alignment.center,
                  child: Text(labels[i],
                      style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: i <= step ? AppColors.primaryDark : AppColors.textSecondary)),
                ),
              ),
          ],
        ),
      ],
    );
  }

  Widget _node(bool done) {
    return Container(
      width: 26, height: 26,
      decoration: BoxDecoration(
        color: done ? AppColors.primary : AppColors.surface,
        shape: BoxShape.circle,
        border: Border.all(color: done ? AppColors.primary : AppColors.stroke, width: 2),
      ),
      child: done ? const Icon(Icons.check, size: 15, color: Colors.white) : null,
    );
  }
}
