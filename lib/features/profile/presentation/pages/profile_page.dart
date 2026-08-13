import 'package:flutter/material.dart';
import 'package:adopt_animal/core/app_icons.dart';
import 'package:adopt_animal/core/app_theme.dart';
import 'package:adopt_animal/core/const/page_const.dart';
import 'package:adopt_animal/core/widgets/settings_widgets.dart';
import 'package:adopt_animal/injection.dart' as di;
import 'package:adopt_animal/features/auth/domain/entities/user_entity.dart';
import 'package:adopt_animal/features/auth/domain/useCases/get_current_user_use_case.dart';
import 'package:adopt_animal/features/auth/domain/useCases/sign_out_use_case.dart';
import 'package:adopt_animal/features/profile/presentation/pages/app_settings_page.dart';
import 'package:adopt_animal/features/profile/presentation/pages/personal_info_page.dart';
import 'package:adopt_animal/features/vet/presentation/pages/appointments_page.dart';
import 'package:adopt_animal/features/adoption/presentation/pages/my_listings_page.dart';
import 'package:adopt_animal/features/adoption/presentation/pages/saved_page.dart';
import 'package:adopt_animal/features/shop/presentation/pages/orders_page.dart';
import 'package:adopt_animal/core/seeder.dart';
import 'package:adopt_animal/features/admin/presentation/pages/admin_page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:adopt_animal/features/adoption/data/animal_repository.dart';
import 'package:adopt_animal/features/shop/data/order_repository.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  String _name = "";
  String _email = "";
  String _city = "";
  String _role = "";

  @override
  void initState() {
    super.initState();
    _load();
  }

  void _load() {
    di.sl<GetCurrentUserUseCase>().call().then((UserEntity u) {
      if (!mounted) return;
      setState(() {
        _name = (u.name != null && u.name!.trim().isNotEmpty) ? u.name! : "Your profile";
        _email = u.email ?? "";
        _city = (u.city != null && u.city!.trim().isNotEmpty) ? u.city! : "";
        _role = u.role ?? "";
      });
    }).catchError((_) {});
  }

  String get _initial => _name.isNotEmpty ? _name[0].toUpperCase() : "?";

  Future<void> _logout() async {
    try {
      await di.sl<SignOutUseCase>().call();
    } catch (_) {}
    if (!mounted) return;
    Navigator.pushNamedAndRemoveUntil(context, PageConst.loginPage, (r) => false);
  }

  Future<void> _push(Widget page) =>
      Navigator.push(context, MaterialPageRoute(builder: (_) => page));

  Future<void> _seed() async {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Seeding Firestore...")),
    );
    final msg = await SeederService().seedAll();
    if (!mounted) return;
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Seed result"),
        content: Text(msg),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("OK")),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Profile", style: AppText.heading),
            const SizedBox(height: 20),
            _profileCard(),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(child: _statBoxLive(_listingsCount(), "Listings")),
                const SizedBox(width: 12),
                Expanded(child: _statBoxLive(_savedCount(), "Saved")),
                const SizedBox(width: 12),
                Expanded(child: _statBoxLive(_ordersCount(), "Orders")),
              ],
            ),
            const SizedBox(height: 20),
            CardGroup(
              children: [
                SettingsRow(
                  leading: const Icon(Icons.cloud_upload_outlined, size: 22, color: AppColors.primary),
                  title: "Seed test data (dev)",
                  onTap: _seed,
                ),
                if (_role == 'admin')
                  SettingsRow(
                    leading: const Icon(Icons.admin_panel_settings_outlined,
                        size: 22, color: AppColors.primary),
                    title: "Admin — manage catalog",
                    onTap: () => _push(const AdminPage()),
                  ),
                SettingsRow(
                  leading: const AppIcon(AppIcons.pets, size: 22, color: AppColors.primary),
                  title: "My listings & requests",
                  onTap: () => _push(const MyListingsPage()),
                ),
                SettingsRow(
                  leading: const AppIcon(AppIcons.favorite, size: 22, color: AppColors.primary),
                  title: "Saved animals",
                  onTap: () => _push(const SavedPage()),
                ),
                SettingsRow(
                  leading: const AppIcon(AppIcons.shipping, size: 22, color: AppColors.primary),
                  title: "My orders",
                  onTap: () => _push(const OrdersPage()),
                ),
                SettingsRow(
                  leading: const AppIcon(AppIcons.event, size: 22, color: AppColors.primary),
                  title: "Appointments",
                  onTap: () => _push(const AppointmentsPage()),
                ),
                SettingsRow(
                  leading: const Icon(Icons.settings, size: 22, color: AppColors.primary),
                  title: "Settings",
                  onTap: () => _push(const AppSettingsPage()),
                ),
              ],
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 54,
              child: OutlinedButton.icon(
                onPressed: _logout,
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFFE05B5B),
                  side: const BorderSide(color: Color(0x55E05B5B)),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
                ),
                icon: const Icon(Icons.logout, size: 20),
                label: const Text("Log out",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _profileCard() {
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
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.12),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Center(
              child: Text(
                _initial,
                style: const TextStyle(
                    color: AppColors.primary, fontWeight: FontWeight.w700, fontSize: 22),
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _name.isEmpty ? "..." : _name,
                  style: const TextStyle(
                      fontWeight: FontWeight.w700, fontSize: 17, color: AppColors.primaryDark),
                ),
                const SizedBox(height: 2),
                Text(
                  [_email, if (_city.isNotEmpty) _city].join(" · "),
                  style: AppText.secondary,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: () async {
              await _push(const PersonalInfoPage());
              _load();
            },
            child: const Padding(
              padding: EdgeInsets.only(left: 8),
              child: Text("Edit",
                  style: TextStyle(
                      color: AppColors.primary, fontWeight: FontWeight.w600, fontSize: 15)),
            ),
          ),
        ],
      ),
    );
  }

  String get _uid => FirebaseAuth.instance.currentUser?.uid ?? "";

  Stream<int> _listingsCount() =>
      AnimalRepository().watchMyListings(_uid).map((l) => l.length);

  Stream<int> _ordersCount() =>
      OrderRepository().watchMyOrders(_uid).map((l) => l.length);

  Stream<int> _savedCount() => FirebaseFirestore.instance
      .collection('users')
      .doc(_uid)
      .collection('favorites')
      .snapshots()
      .map((s) => s.docs.length);

  Widget _statBoxLive(Stream<int> stream, String label) {
    return StreamBuilder<int>(
      stream: stream,
      builder: (context, snap) => _statBox("${snap.data ?? 0}", label),
    );
  }

  Widget _statBox(String value, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 18),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(color: Color(0x0A1F2A44), blurRadius: 10, offset: Offset(0, 4)),
        ],
      ),
      child: Column(
        children: [
          Text(value,
              style: const TextStyle(
                  fontSize: 22, fontWeight: FontWeight.w800, color: AppColors.primaryDark)),
          const SizedBox(height: 2),
          Text(label, style: AppText.secondary),
        ],
      ),
    );
  }
}
