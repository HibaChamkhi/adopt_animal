import 'package:flutter/material.dart';
import 'package:adopt_animal/core/app_theme.dart';
import 'package:adopt_animal/core/sample_data.dart';
import 'package:adopt_animal/core/widgets/app_widgets.dart';
import 'package:adopt_animal/features/shop/data/product_repository.dart';
import 'package:adopt_animal/features/vet/data/vet_repository.dart';

class AdminPage extends StatefulWidget {
  const AdminPage({super.key});

  @override
  State<AdminPage> createState() => _AdminPageState();
}

class _AdminPageState extends State<AdminPage> {
  int _tab = 0;
  final _products = ProductRepository();
  final _vets = VetRepository();

  final _productCats = const ["Food", "Toys", "Accessories", "Health"];
  final _vetCats = const ["Canine", "Feline", "Exotic"];

  void _snack(String m) =>
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(m)));

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppColors.primary,
        onPressed: _tab == 0 ? _addProduct : _addVet,
        icon: const Icon(Icons.add, color: Colors.white),
        label: Text(_tab == 0 ? "Add product" : "Add vet",
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("Admin · Catalog", style: AppText.heading),
              const SizedBox(height: 4),
              Text("Manage the products and vets everyone sees",
                  style: AppText.secondary),
              const SizedBox(height: 16),
              _tabs(),
              const SizedBox(height: 16),
              Expanded(child: _tab == 0 ? _productList() : _vetList()),
            ],
          ),
        ),
      ),
    );
  }

  Widget _tabs() {
    return Container(
      padding: const EdgeInsets.all(5),
      decoration: BoxDecoration(
          color: AppColors.surface, borderRadius: BorderRadius.circular(28)),
      child: Row(
        children: [
          _tabBtn("Products", 0),
          _tabBtn("Vets", 1),
        ],
      ),
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

  Widget _productList() {
    return StreamBuilder<List<Product>>(
      stream: _products.watch(),
      builder: (context, snap) {
        if (snap.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        final items = snap.data ?? const <Product>[];
        if (items.isEmpty) {
          return const EmptyState(
              icon: Icons.shopping_bag_outlined,
              title: "No products",
              subtitle: "Tap Add product to create one.");
        }
        return ListView.separated(
          padding: const EdgeInsets.only(bottom: 90),
          itemCount: items.length,
          separatorBuilder: (_, __) => const SizedBox(height: 12),
          itemBuilder: (context, i) {
            final p = items[i];
            return _row(
              title: p.name,
              sub: "${p.category} · EGP ${p.price}",
              onDelete: () => _confirmDelete(
                  "product", p.name, () => _products.delete(p.id)),
            );
          },
        );
      },
    );
  }

  Widget _vetList() {
    return StreamBuilder<List<Vet>>(
      stream: _vets.watch(),
      builder: (context, snap) {
        if (snap.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        final items = snap.data ?? const <Vet>[];
        if (items.isEmpty) {
          return const EmptyState(
              icon: Icons.medical_services_outlined,
              title: "No vets",
              subtitle: "Tap Add vet to create one.");
        }
        return ListView.separated(
          padding: const EdgeInsets.only(bottom: 90),
          itemCount: items.length,
          separatorBuilder: (_, __) => const SizedBox(height: 12),
          itemBuilder: (context, i) {
            final v = items[i];
            return _row(
              title: v.name,
              sub: "${v.specialty} · ${v.clinic}",
              onDelete: () =>
                  _confirmDelete("vet", v.name, () => _vets.delete(v.id)),
            );
          },
        );
      },
    );
  }

  Widget _row(
      {required String title,
      required String sub,
      required VoidCallback onDelete}) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(color: Color(0x0A1F2A44), blurRadius: 10, offset: Offset(0, 3)),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 15,
                        color: AppColors.primaryDark)),
                const SizedBox(height: 2),
                Text(sub, style: AppText.secondary),
              ],
            ),
          ),
          GestureDetector(
            onTap: onDelete,
            child: const Padding(
              padding: EdgeInsets.all(6),
              child: Icon(Icons.delete_outline, color: Color(0xFFE05B5B)),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _confirmDelete(
      String kind, String name, Future<void> Function() doDelete) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text("Delete $kind?"),
        content: Text("Remove $name? This can't be undone."),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text("Keep")),
          TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text("Delete")),
        ],
      ),
    );
    if (ok != true) return;
    try {
      await doDelete();
      _snack("Deleted");
    } catch (_) {
      _snack("Couldn't delete — are you signed in as admin?");
    }
  }

  Future<void> _addProduct() async {
    final name = TextEditingController();
    final desc = TextEditingController();
    final price = TextEditingController();
    int cat = 0;
    final saved = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setSheet) => _sheet(
          ctx,
          title: "Add product",
          fields: [
            _field("Name", name, "Premium Dry Food 5kg"),
            _chips("Category", _productCats, cat, (i) => setSheet(() => cat = i)),
            _field("Description", desc, "Grain-free recipe...", maxLines: 3),
            _field("Price (EGP)", price, "450", number: true),
          ],
          onSave: () => Navigator.pop(ctx, true),
        ),
      ),
    );
    if (saved != true) return;
    if (name.text.trim().isEmpty) {
      _snack("Enter a name");
      return;
    }
    try {
      await _products.add(
        name: name.text.trim(),
        category: _productCats[cat],
        description: desc.text.trim(),
        price: int.tryParse(price.text.trim()) ?? 0,
      );
      _snack("Product added");
    } catch (_) {
      _snack("Couldn't add — are you signed in as admin?");
    }
  }

  Future<void> _addVet() async {
    final name = TextEditingController();
    final specialty = TextEditingController();
    final clinic = TextEditingController();
    final city = TextEditingController();
    final phone = TextEditingController();
    final price = TextEditingController();
    int cat = 0;
    final saved = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setSheet) => _sheet(
          ctx,
          title: "Add vet",
          fields: [
            _field("Name", name, "Dr. Ahmed Hassan"),
            _field("Specialty", specialty, "Canine specialist"),
            _field("Clinic", clinic, "Golden Paws Clinic"),
            _field("City", city, "Maadi, Cairo"),
            _chips("Category", _vetCats, cat, (i) => setSheet(() => cat = i)),
            _field("Price / visit (EGP)", price, "250", number: true),
            _field("Phone", phone, "+201001112233"),
          ],
          onSave: () => Navigator.pop(ctx, true),
        ),
      ),
    );
    if (saved != true) return;
    if (name.text.trim().isEmpty) {
      _snack("Enter a name");
      return;
    }
    try {
      await _vets.add(
        name: name.text.trim(),
        specialty: specialty.text.trim(),
        clinic: clinic.text.trim(),
        city: city.text.trim(),
        category: _vetCats[cat],
        price: int.tryParse(price.text.trim()) ?? 0,
        phone: phone.text.trim(),
      );
      _snack("Vet added");
    } catch (_) {
      _snack("Couldn't add — are you signed in as admin?");
    }
  }

  Widget _sheet(BuildContext ctx,
      {required String title,
      required List<Widget> fields,
      required VoidCallback onSave}) {
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
      child: Container(
        decoration: const BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: AppText.title),
              const SizedBox(height: 16),
              for (final f in fields) ...[f, const SizedBox(height: 14)],
              const SizedBox(height: 4),
              PrimaryButton(label: "Save", onTap: onSave),
            ],
          ),
        ),
      ),
    );
  }

  Widget _field(String label, TextEditingController c, String hint,
      {int maxLines = 1, bool number = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppText.secondary),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
              color: AppColors.surface, borderRadius: BorderRadius.circular(16)),
          child: TextField(
            controller: c,
            style: AppText.body,
            maxLines: maxLines,
            keyboardType: number ? TextInputType.number : TextInputType.text,
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: AppText.secondary,
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(vertical: 14),
            ),
          ),
        ),
      ],
    );
  }

  Widget _chips(
      String label, List<String> options, int selected, ValueChanged<int> onTap) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppText.secondary),
        const SizedBox(height: 8),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: [
            for (int i = 0; i < options.length; i++)
              SelectableChip(
                label: options[i],
                selected: selected == i,
                onTap: () => onTap(i),
              ),
          ],
        ),
      ],
    );
  }
}
