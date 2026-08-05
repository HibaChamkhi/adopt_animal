import 'package:flutter/material.dart';
import 'package:adopt_animal/core/app_icons.dart';
import 'package:adopt_animal/core/app_theme.dart';
import 'package:adopt_animal/core/cart_service.dart';
import 'package:adopt_animal/core/widgets/app_widgets.dart';
import 'package:adopt_animal/features/shop/presentation/pages/checkout_page.dart';

class CartPage extends StatelessWidget {
  const CartPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: AnimatedBuilder(
          animation: cart,
          builder: (context, _) {
            if (cart.items.isEmpty) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Padding(
                    padding: EdgeInsets.fromLTRB(20, 16, 20, 0),
                    child: Text("Cart", style: AppText.heading),
                  ),
                  Expanded(
                    child: EmptyState(
                      icon: Icons.shopping_cart_outlined,
                      title: "Your cart is empty",
                      subtitle: "Add supplies from the shop.",
                    ),
                  ),
                ],
              );
            }
            return Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Cart", style: AppText.heading),
                  const SizedBox(height: 16),
                  Expanded(
                    child: ListView(
                      padding: const EdgeInsets.only(bottom: 16),
                      children: [
                        for (final it in cart.items) ...[
                          _itemCard(context, it),
                          const SizedBox(height: 12),
                        ],
                        const SizedBox(height: 4),
                        _summary(),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
      bottomNavigationBar: AnimatedBuilder(
        animation: cart,
        builder: (context, _) {
          if (cart.items.isEmpty) return const SizedBox.shrink();
          return SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
              child: PrimaryButton(
                label: "Checkout · EGP ${cart.total}",
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const CheckoutPage()),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _itemCard(BuildContext context, CartItem it) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
        boxShadow: const [
          BoxShadow(color: Color(0x0F1F2A44), blurRadius: 14, offset: Offset(0, 6)),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 64,
            height: 64,
            child: StripedPlaceholder(label: it.product.photoLabel, borderRadius: 14),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(it.product.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                        fontWeight: FontWeight.w700, fontSize: 15, color: AppColors.primaryDark)),
                const SizedBox(height: 2),
                Text("EGP ${it.product.price}",
                    style: const TextStyle(
                        color: AppColors.primary, fontWeight: FontWeight.w700, fontSize: 14)),
                const SizedBox(height: 8),
                _stepper(it),
              ],
            ),
          ),
          GestureDetector(
            onTap: () => cart.removeItem(it),
            child: const Padding(
              padding: EdgeInsets.all(4),
              child: AppIcon(AppIcons.delete, size: 20, color: AppColors.textSecondary),
            ),
          ),
        ],
      ),
    );
  }

  Widget _stepper(CartItem it) {
    return Row(
      children: [
        _stepBtn(AppIcons.remove, () => cart.dec(it), filled: false),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14),
          child: Text("${it.qty}",
              style: const TextStyle(
                  fontWeight: FontWeight.w700, fontSize: 15, color: AppColors.primaryDark)),
        ),
        _stepBtn(AppIcons.add, () => cart.inc(it), filled: true),
      ],
    );
  }

  Widget _stepBtn(String icon, VoidCallback onTap, {required bool filled}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: filled ? AppColors.primary : AppColors.background,
          shape: BoxShape.circle,
        ),
        child: AppIcon(icon, size: 16, color: filled ? Colors.white : AppColors.primaryDark),
      ),
    );
  }

  Widget _summary() {
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
          _row("Subtotal", "EGP ${cart.subtotal}"),
          const SizedBox(height: 10),
          _row("Delivery", "EGP ${cart.deliveryFee}"),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 12),
            child: Divider(height: 1, color: AppColors.stroke),
          ),
          _row("Total", "EGP ${cart.total}", bold: true),
        ],
      ),
    );
  }

  Widget _row(String label, String value, {bool bold = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label,
            style: bold
                ? const TextStyle(fontWeight: FontWeight.w800, fontSize: 16, color: AppColors.primaryDark)
                : AppText.secondary),
        Text(value,
            style: TextStyle(
                fontWeight: FontWeight.w800,
                fontSize: bold ? 16 : 14,
                color: bold ? AppColors.primary : AppColors.primaryDark)),
      ],
    );
  }
}
