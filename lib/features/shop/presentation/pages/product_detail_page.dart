import 'package:flutter/material.dart';
import 'package:adopt_animal/core/app_icons.dart';
import 'package:adopt_animal/core/app_theme.dart';
import 'package:adopt_animal/core/sample_data.dart';
import 'package:adopt_animal/core/cart_service.dart';
import 'package:adopt_animal/core/widgets/app_widgets.dart';

class ProductDetailPage extends StatefulWidget {
  final Product product;
  const ProductDetailPage({super.key, required this.product});

  @override
  State<ProductDetailPage> createState() => _ProductDetailPageState();
}

class _ProductDetailPageState extends State<ProductDetailPage> {
  int _qty = 1;

  @override
  Widget build(BuildContext context) {
    final p = widget.product;
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        bottom: false,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
                child: Stack(
                  children: [
                    StripedPlaceholder(label: "product photo", height: 280, borderRadius: 24),
                    Positioned(
                      top: 12,
                      left: 12,
                      child: GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: Container(
                          padding: const EdgeInsets.all(10),
                          decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                          child: const AppIcon(AppIcons.arrowBack, size: 20, color: AppColors.primaryDark),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(child: Text(p.name, style: AppText.title)),
                        const SizedBox(width: 12),
                        Text("EGP ${p.price}",
                            style: const TextStyle(
                                color: AppColors.primary, fontWeight: FontWeight.w800, fontSize: 20)),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        const AppIcon(AppIcons.star, size: 16, color: Color(0xFFF2B21C)),
                        const SizedBox(width: 4),
                        Text("${p.rating} · ${p.reviews} reviews", style: AppText.secondary),
                        const Spacer(),
                        StatusBadge(
                          label: p.inStock ? "In stock" : "Out of stock",
                          type: p.inStock ? BadgeType.success : BadgeType.neutral,
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Text(p.description, style: AppText.body),
                    const SizedBox(height: 22),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text("Quantity",
                            style: TextStyle(
                                fontWeight: FontWeight.w700, fontSize: 16, color: AppColors.primaryDark)),
                        _stepper(),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        Expanded(child: _infoTile(AppIcons.shipping, "Ships in 2 days")),
                        const SizedBox(width: 10),
                        Expanded(child: _infoTile(AppIcons.payments, "Cash on delivery")),
                        const SizedBox(width: 10),
                        Expanded(child: _infoTile(AppIcons.replay, "14-day returns")),
                      ],
                    ),
                  ],
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
            label: "Add to cart",
            icon: Icons.shopping_cart_outlined,
            onTap: () {
              cart.add(p, _qty);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text("Added $_qty × ${p.name} to cart")),
              );
              Navigator.pop(context);
            },
          ),
        ),
      ),
    );
  }

  Widget _stepper() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(24),
        boxShadow: const [
          BoxShadow(color: Color(0x0A1F2A44), blurRadius: 8, offset: Offset(0, 2)),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _stepBtn(AppIcons.remove, () {
            if (_qty > 1) setState(() => _qty--);
          }, filled: false),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text("$_qty",
                style: const TextStyle(
                    fontWeight: FontWeight.w700, fontSize: 16, color: AppColors.primaryDark)),
          ),
          _stepBtn(AppIcons.add, () => setState(() => _qty++), filled: true),
        ],
      ),
    );
  }

  Widget _stepBtn(String icon, VoidCallback onTap, {required bool filled}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.all(6),
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: filled ? AppColors.primary : AppColors.background,
          shape: BoxShape.circle,
        ),
        child: AppIcon(icon, size: 18, color: filled ? Colors.white : AppColors.primaryDark),
      ),
    );
  }

  Widget _infoTile(String icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 6),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          AppIcon(icon, size: 22, color: AppColors.primary),
          const SizedBox(height: 8),
          Text(label,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
        ],
      ),
    );
  }
}
