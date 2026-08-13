import 'package:flutter/material.dart';
import 'package:adopt_animal/core/app_icons.dart';
import 'package:adopt_animal/core/app_theme.dart';
import 'package:adopt_animal/core/sample_data.dart';
import 'package:adopt_animal/core/cart_service.dart';
import 'package:adopt_animal/core/widgets/app_widgets.dart';
import 'package:adopt_animal/core/widgets/settings_widgets.dart';
import 'package:adopt_animal/features/shop/presentation/pages/product_detail_page.dart';
import 'package:adopt_animal/features/shop/presentation/pages/cart_page.dart';
import 'package:adopt_animal/features/shop/data/product_repository.dart';

class ShopPage extends StatefulWidget {
  const ShopPage({super.key});

  @override
  State<ShopPage> createState() => _ShopPageState();
}

class _ShopPageState extends State<ShopPage> {
  int _category = 0;
  String _query = "";
  final _categories = const ["Food", "Toys", "Accessories", "Health"];
  final _repo = ProductRepository();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text("Shop", style: AppText.heading),
                _cartButton(),
              ],
            ),
            const SizedBox(height: 16),
            AppSearchField(
              hint: "Search products...",
              onChanged: (v) => setState(() => _query = v),
            ),
            const SizedBox(height: 16),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  for (int i = 0; i < _categories.length; i++) ...[
                    SelectableChip(
                      label: _categories[i],
                      selected: _category == i,
                      onTap: () => setState(() => _category = i),
                    ),
                    if (i != _categories.length - 1) const SizedBox(width: 12),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: StreamBuilder<List<Product>>(
                stream: _repo.watch(),
                builder: (context, snap) {
                  if (snap.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  final all = snap.data ?? <Product>[];
                  if (all.isEmpty) {
                    return const EmptyState(
                      icon: Icons.shopping_bag_outlined,
                      title: "No products yet",
                      subtitle: "Products will appear here once they're added.",
                    );
                  }
                  final q = _query.trim().toLowerCase();
                  final products = all
                      .where((p) =>
                          p.category == _categories[_category] &&
                          (q.isEmpty ||
                              p.name.toLowerCase().contains(q) ||
                              p.description.toLowerCase().contains(q)))
                      .toList();
                  if (products.isEmpty) {
                    return const EmptyState(
                      icon: Icons.shopping_bag_outlined,
                      title: "No products in this category",
                    );
                  }
                  return GridView.builder(
                    padding: const EdgeInsets.only(bottom: 16),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      mainAxisSpacing: 14,
                      crossAxisSpacing: 14,
                      childAspectRatio: 0.60,
                    ),
                    itemCount: products.length,
                    itemBuilder: (context, i) => _productCard(products[i]),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _cartButton() {
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const CartPage()),
      ),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          boxShadow: const [
            BoxShadow(color: Color(0x0F1F2A44), blurRadius: 12, offset: Offset(0, 4)),
          ],
        ),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            const AppIcon(AppIcons.cart, size: 24, color: AppColors.primaryDark),
            Positioned(
              right: -6,
              top: -6,
              child: Container(
                padding: const EdgeInsets.all(4),
                constraints: const BoxConstraints(minWidth: 18, minHeight: 18),
                decoration: const BoxDecoration(color: AppColors.primary, shape: BoxShape.circle),
                child: Text("${cart.count}",
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w700)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _productCard(Product p) {
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => ProductDetailPage(product: p)),
      ),
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(20),
          boxShadow: const [
            BoxShadow(color: Color(0x0F1F2A44), blurRadius: 14, offset: Offset(0, 6)),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AspectRatio(
              aspectRatio: 1.25,
              child: StripedPlaceholder(label: p.photoLabel, borderRadius: 14),
            ),
            const SizedBox(height: 10),
            Text(
              p.name,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: AppColors.primaryDark,
                height: 1.2,
              ),
            ),
            const SizedBox(height: 6),
            Row(
              children: [
                const AppIcon(AppIcons.star, size: 15, color: Color(0xFFF2B21C)),
                const SizedBox(width: 4),
                Text("${p.rating} (${p.reviews})", style: AppText.secondary),
              ],
            ),
            const Spacer(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("EGP ${p.price}",
                    style: const TextStyle(
                        color: AppColors.primary, fontWeight: FontWeight.w800, fontSize: 16)),
                GestureDetector(
                  onTap: () {
                    cart.add(p);
                    setState(() {});
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text("Added ${p.name} to cart")),
                    );
                  },
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const AppIcon(AppIcons.add, size: 18, color: Colors.white),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
