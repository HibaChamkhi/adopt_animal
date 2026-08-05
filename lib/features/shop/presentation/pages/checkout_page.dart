import 'package:flutter/material.dart';
import 'package:adopt_animal/core/app_icons.dart';
import 'package:adopt_animal/core/app_theme.dart';
import 'package:adopt_animal/core/cart_service.dart';
import 'package:adopt_animal/features/shop/data/order_repository.dart';
import 'package:adopt_animal/core/widgets/app_widgets.dart';
import 'package:adopt_animal/core/widgets/settings_widgets.dart';

class CheckoutPage extends StatelessWidget {
  const CheckoutPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SubPageHeader("Checkout"),
              const SizedBox(height: 22),
              const Text("Delivery address", style: AppText.secondary),
              const SizedBox(height: 10),
              _addressCard(context),
              const SizedBox(height: 22),
              const Text("Payment", style: AppText.secondary),
              const SizedBox(height: 10),
              _payOption(icon: AppIcons.payments, label: "Cash on delivery", selected: true),
              const SizedBox(height: 12),
              _payOption(icon: AppIcons.creditCard, label: "Card payment", selected: false, comingSoon: true),
              const SizedBox(height: 22),
              const Text("Order summary", style: AppText.secondary),
              const SizedBox(height: 10),
              _summaryCard(),
            ],
          ),
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
          child: PrimaryButton(
            label: "Place order",
            onTap: () async {
              try {
                await OrderRepository().placeOrder(
                  items: List.of(cart.items),
                  subtotal: cart.subtotal,
                  delivery: cart.deliveryFee,
                  total: cart.total,
                );
              } catch (_) {}
              cart.clear();
              if (!context.mounted) return;
              Navigator.popUntil(context, (r) => r.isFirst);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Order placed! You'll get a confirmation shortly.")),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _addressCard(BuildContext context) {
    return Container(
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
          const IconBadge(child: AppIcon(AppIcons.home, size: 22, color: AppColors.primary)),
          const SizedBox(width: 14),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Home",
                    style: TextStyle(
                        fontWeight: FontWeight.w700, fontSize: 15, color: AppColors.primaryDark)),
                SizedBox(height: 2),
                Text("12 Road 9, Maadi, Cairo · +20 100 234 5678", style: AppText.secondary),
              ],
            ),
          ),
          GestureDetector(
            onTap: () {},
            child: const Text("Edit",
                style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.w600, fontSize: 15)),
          ),
        ],
      ),
    );
  }

  Widget _payOption({
    required String icon,
    required String label,
    required bool selected,
    bool comingSoon = false,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: comingSoon ? AppColors.neutralBg : AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: selected ? AppColors.primary : Colors.transparent,
          width: 1.5,
        ),
      ),
      child: Row(
        children: [
          AppIcon(icon, size: 22, color: comingSoon ? AppColors.textSecondary : AppColors.primaryDark),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label,
                    style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 15,
                        color: comingSoon ? AppColors.textSecondary : AppColors.primaryDark)),
                if (comingSoon)
                  const Text("Coming soon", style: AppText.secondary),
              ],
            ),
          ),
          Icon(
            selected ? Icons.radio_button_checked : Icons.radio_button_unchecked,
            color: selected ? AppColors.primary : AppColors.textSecondary,
            size: 22,
          ),
        ],
      ),
    );
  }

  Widget _summaryCard() {
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
        children: [
          for (final it in cart.items) ...[
            _line("${it.product.name} × ${it.qty}", "EGP ${it.product.price * it.qty}"),
            const SizedBox(height: 10),
          ],
          _line("Delivery", "EGP ${cart.deliveryFee}"),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 12),
            child: Divider(height: 1, color: AppColors.stroke),
          ),
          _line("Total", "EGP ${cart.total}", bold: true),
        ],
      ),
    );
  }

  Widget _line(String label, String value, {bool bold = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Text(label,
              style: bold
                  ? const TextStyle(fontWeight: FontWeight.w800, fontSize: 16, color: AppColors.primaryDark)
                  : const TextStyle(fontSize: 14, color: AppColors.primaryDark)),
        ),
        Text(value,
            style: TextStyle(
                fontWeight: FontWeight.w800,
                fontSize: bold ? 16 : 14,
                color: bold ? AppColors.primary : AppColors.primaryDark)),
      ],
    );
  }
}
