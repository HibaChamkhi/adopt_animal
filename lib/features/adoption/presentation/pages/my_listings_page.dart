import 'package:flutter/material.dart';
import 'package:adopt_animal/core/app_icons.dart';
import 'package:adopt_animal/core/app_theme.dart';
import 'package:adopt_animal/core/widgets/app_widgets.dart';
import 'package:adopt_animal/features/adoption/presentation/pages/list_for_adoption_page.dart';
import 'package:adopt_animal/features/adoption/data/adoption_request_repository.dart';
import 'package:adopt_animal/features/adoption/data/animal_repository.dart';
import 'package:adopt_animal/core/sample_data.dart';
import 'package:firebase_auth/firebase_auth.dart';

class MyListingsPage extends StatefulWidget {
  const MyListingsPage({super.key});

  @override
  State<MyListingsPage> createState() => _MyListingsPageState();
}

class _MyListingsPageState extends State<MyListingsPage> {
  int _tab = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.primary,
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const ListForAdoptionPage()),
        ),
        child: const AppIcon(AppIcons.add, size: 26, color: Colors.white),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("My listings", style: AppText.heading),
              const SizedBox(height: 16),
              _tabs(),
              const SizedBox(height: 16),
              Expanded(
                child: _tab == 0 ? _listingsTab() : _requestsTab(),
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
      child: Row(
        children: [
          _tabBtn("Listings", 0),
          _tabBtn("Requests", 1),
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

  Widget _listingsTab() {
    final uid = FirebaseAuth.instance.currentUser?.uid ?? "";
    return StreamBuilder<List<Animal>>(
      stream: AnimalRepository().watchMyListings(uid),
      builder: (context, snap) {
        if (snap.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        final mine = snap.data ?? const <Animal>[];
        if (mine.isEmpty) {
          return const EmptyState(
            icon: Icons.pets,
            title: "No listings yet",
            subtitle: "Tap + to list a pet for adoption.",
          );
        }
        return ListView.separated(
          padding: const EdgeInsets.only(bottom: 90),
          itemCount: mine.length,
          separatorBuilder: (_, __) => const SizedBox(height: 14),
          itemBuilder: (context, i) {
            final a = mine[i];
            return _listingCard(
              name: a.name,
              sub: "${a.breed} · ${a.age}",
              photo: a.photoLabel,
              photoBase64: a.photoBase64,
              adopted: a.status == "adopted",
              requests: 0,
              views: 0,
              onEdit: () => _openEdit(a),
              onDelete: () => _confirmDelete(a),
            );
          },
        );
      },
    );
  }

  Widget _requestsTab() {
    final uid = FirebaseAuth.instance.currentUser?.uid ?? "";
    return StreamBuilder<List<AdoptionRequest>>(
      stream: AdoptionRequestRepository().watchForOwner(uid),
      builder: (context, snap) {
        if (snap.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        final reqs = snap.data ?? const <AdoptionRequest>[];
        if (reqs.isEmpty) {
          return const EmptyState(
            icon: Icons.mail_outline,
            title: "No requests yet",
            subtitle: "Adoption requests for your pets will appear here.",
          );
        }
        return ListView.separated(
          padding: const EdgeInsets.only(bottom: 90),
          itemCount: reqs.length,
          separatorBuilder: (_, __) => const SizedBox(height: 14),
          itemBuilder: (context, i) {
            final r = reqs[i];
            final initial = r.adopterName.isNotEmpty ? r.adopterName[0] : "?";
            return _requestCard(
              initial,
              r.adopterName,
              r.animalName,
              r.message,
              status: r.status,
              onAccept: () => _accept(r),
              onDecline: () => _decline(r),
            );
          },
        );
      },
    );
  }

  Widget _listingCard({
    required String name,
    required String sub,
    required String photo,
    String photoBase64 = "",
    required bool adopted,
    int requests = 0,
    int views = 0,
    String adoptedBy = "",
    VoidCallback? onEdit,
    VoidCallback? onDelete,
  }) {
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
            width: 64, height: 64,
            child: photoOrPlaceholder(photoBase64, photo, radius: 14),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(name,
                          style: const TextStyle(
                              fontWeight: FontWeight.w700, fontSize: 16, color: AppColors.primaryDark)),
                    ),
                    StatusBadge(
                      label: adopted ? "Adopted" : "Available",
                      type: adopted ? BadgeType.neutral : BadgeType.success,
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(sub, style: AppText.secondary),
                const SizedBox(height: 10),
                if (adopted)
                  Text(adoptedBy,
                      style: const TextStyle(
                          color: AppColors.success, fontWeight: FontWeight.w600, fontSize: 13))
                else
                  Row(
                    children: [
                      const AppIcon(AppIcons.mail, size: 16, color: AppColors.primary),
                      const SizedBox(width: 4),
                      Text("$requests requests",
                          style: const TextStyle(
                              color: AppColors.primary, fontWeight: FontWeight.w600, fontSize: 13)),
                      const SizedBox(width: 14),
                      const AppIcon(AppIcons.visibility, size: 16, color: AppColors.textSecondary),
                      const SizedBox(width: 4),
                      Text("$views views", style: AppText.secondary),
                      const Spacer(),
                      GestureDetector(
                        onTap: onEdit,
                        child: const AppIcon(AppIcons.edit,
                            size: 18, color: AppColors.textSecondary),
                      ),
                      const SizedBox(width: 14),
                      GestureDetector(
                        onTap: onDelete,
                        child: const AppIcon(AppIcons.delete,
                            size: 18, color: Color(0xFFE05B5B)),
                      ),
                    ],
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _requestCard(String initial, String who, String pet, String msg,
      {String status = 'pending',
      VoidCallback? onAccept,
      VoidCallback? onDecline}) {
    return Container(
      padding: const EdgeInsets.all(14),
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
              Container(
                width: 44, height: 44,
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.12), shape: BoxShape.circle),
                child: Center(
                  child: Text(initial,
                      style: const TextStyle(
                          color: AppColors.primary, fontWeight: FontWeight.w700, fontSize: 16)),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text.rich(TextSpan(children: [
                      TextSpan(text: "$who ",
                          style: const TextStyle(
                              fontWeight: FontWeight.w700, fontSize: 15, color: AppColors.primaryDark)),
                      const TextSpan(text: "→ ", style: TextStyle(color: AppColors.textSecondary)),
                      TextSpan(text: pet,
                          style: const TextStyle(
                              fontWeight: FontWeight.w700, fontSize: 15, color: AppColors.primaryDark)),
                    ])),
                    const SizedBox(height: 2),
                    Text(msg, maxLines: 1, overflow: TextOverflow.ellipsis, style: AppText.secondary),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (status == 'pending')
            Row(
              children: [
                Expanded(
                  child: SizedBox(
                    height: 44,
                    child: ElevatedButton(
                      onPressed: onAccept,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                      ),
                      child: const Text("Accept", style: TextStyle(fontWeight: FontWeight.w700)),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: SizedBox(
                    height: 44,
                    child: OutlinedButton(
                      onPressed: onDecline,
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.textSecondary,
                        side: const BorderSide(color: AppColors.stroke),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                      ),
                      child: const Text("Decline", style: TextStyle(fontWeight: FontWeight.w700)),
                    ),
                  ),
                ),
              ],
            )
          else
            Align(
              alignment: Alignment.centerLeft,
              child: StatusBadge(
                label: status == 'accepted' ? 'Accepted' : 'Declined',
                type: status == 'accepted'
                    ? BadgeType.success
                    : BadgeType.neutral,
              ),
            ),
        ],
      ),
    );
  }

  Future<void> _openEdit(Animal a) async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => ListForAdoptionPage(existing: a)),
    );
  }

  Future<void> _confirmDelete(Animal a) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Delete listing?"),
        content: Text("Remove ${a.name} from adoption? This can't be undone."),
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
      await AnimalRepository().delete(a.id);
      _snack("Listing deleted");
    } catch (_) {
      _snack("Couldn't delete — try again");
    }
  }

  Future<void> _accept(AdoptionRequest r) async {
    try {
      await AdoptionRequestRepository().updateStatus(r.id, 'accepted');
      if (r.animalId.isNotEmpty) {
        await AnimalRepository().setStatus(r.animalId, 'adopted');
      }
      _snack("Request accepted");
    } catch (e) {
      _snack("Couldn't accept — try again");
    }
  }

  Future<void> _decline(AdoptionRequest r) async {
    try {
      await AdoptionRequestRepository().updateStatus(r.id, 'declined');
      _snack("Request declined");
    } catch (e) {
      _snack("Couldn't decline — try again");
    }
  }

  void _snack(String s) =>
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(s)));
}
