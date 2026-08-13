import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'sample_data.dart';

/// One-tap Firestore seeding of the built-in sample data (dev/testing).
class SeederService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<String> seedAll() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return "Please sign in first.";
    final lines = <String>[];
    lines.add(await _seedAnimals(uid));
    lines.add(await _seedProducts());
    lines.add(await _seedVets());
    lines.add(await _seedMyListings(uid));
    lines.add(await _seedOrders(uid));
    lines.add(await _seedRequests(uid));
    lines.add(await _seedAppointments(uid));
    return lines.join('\n');
  }

  Future<bool> _isEmpty(String col) async {
    final s = await _db.collection(col).limit(1).get();
    return s.docs.isEmpty;
  }

  Future<String> _seedAnimals(String uid) async {
    try {
      if (!await _isEmpty('animals')) return "animals — already has data (skipped)";
      final col = _db.collection('animals');
      for (final a in sampleAnimals) {
        await col.add({
          'ownerId': uid,
          'ownerName': a.ownerName,
          'name': a.name,
          'species': a.species,
          'breed': a.breed,
          'age': a.age,
          'gender': a.gender,
          'size': a.size,
          'weight': a.weight,
          'city': a.city,
          'area': a.area,
          'description': a.description,
          'health': a.health,
          'photoLabel': a.photoLabel,
          'status': 'available',
          'createdAt': FieldValue.serverTimestamp(),
        });
      }
      return "animals — added ${sampleAnimals.length}";
    } catch (e) {
      return "animals — FAILED: $e";
    }
  }

  /// Seed a couple of listings owned by the CURRENT user, so the
  /// "My listings" tab (which filters by ownerId == you) has data.
  Future<String> _seedMyListings(String uid) async {
    try {
      final existing = await _db
          .collection('animals')
          .where('ownerId', isEqualTo: uid)
          .limit(1)
          .get();
      if (existing.docs.isNotEmpty) {
        return "my listings — already has data (skipped)";
      }
      final col = _db.collection('animals');
      final mine = <Map<String, dynamic>>[
        {
          'name': 'Bella', 'species': 'dog', 'breed': 'Labrador mix', 'age': '3 yr',
          'gender': 'Female', 'size': 'Large', 'weight': '24 kg', 'city': 'Cairo',
          'area': 'Maadi, Cairo', 'description': 'Friendly and house-trained.',
          'health': 'Vaccinated · Spayed', 'photoLabel': 'dog photo', 'status': 'available',
        },
        {
          'name': 'Simba', 'species': 'cat', 'breed': 'Persian cat', 'age': '5 yr',
          'gender': 'Male', 'size': 'Medium', 'weight': '6 kg', 'city': 'Cairo',
          'area': 'Nasr City, Cairo', 'description': 'Calm lap cat, litter trained.',
          'health': 'Vaccinated · Neutered', 'photoLabel': 'cat photo', 'status': 'adopted',
        },
      ];
      for (final a in mine) {
        await col.add({
          'ownerId': uid,
          'ownerName': 'You',
          ...a,
          'createdAt': FieldValue.serverTimestamp(),
        });
      }
      return "my listings — added ${mine.length}";
    } catch (e) {
      return "my listings — FAILED: $e";
    }
  }

  Future<String> _seedProducts() async {
    try {
      if (!await _isEmpty('products')) return "products — already has data (skipped)";
      final col = _db.collection('products');
      for (final p in sampleProducts) {
        await col.add({
          'name': p.name,
          'category': p.category,
          'photoLabel': p.photoLabel,
          'description': p.description,
          'price': p.price,
          'rating': p.rating,
          'reviews': p.reviews,
          'inStock': p.inStock,
        });
      }
      return "products — added ${sampleProducts.length} (needs admin role)";
    } catch (e) {
      return "products — FAILED (needs admin role): $e";
    }
  }

  Future<String> _seedVets() async {
    try {
      if (!await _isEmpty('vets')) return "vets — already has data (skipped)";
      final col = _db.collection('vets');
      for (final v in sampleVets) {
        await col.add({
          'name': v.name,
          'specialty': v.specialty,
          'clinic': v.clinic,
          'city': v.city,
          'initials': v.initials,
          'category': v.category,
          'rating': v.rating,
          'availability': v.availability,
          'about': v.about,
          'experience': v.experience,
          'patients': v.patients,
          'price': v.price,
          'address': v.address,
          'hours': v.hours,
          'phone': v.phone,
        });
      }
      return "vets — added ${sampleVets.length} (needs admin role)";
    } catch (e) {
      return "vets — FAILED (needs admin role): $e";
    }
  }

  Future<String> _seedOrders(String uid) async {
    try {
      final existing = await _db
          .collection('orders')
          .where('userId', isEqualTo: uid)
          .limit(1)
          .get();
      if (existing.docs.isNotEmpty) return "orders — already has data (skipped)";
      final col = _db.collection('orders');
      final samples = <Map<String, dynamic>>[
        {
          'items': [
            {'productId': 'Premium Dry Food 5kg', 'name': 'Premium Dry Food 5kg', 'price': 450, 'qty': 1},
          ],
          'itemCount': 1, 'subtotal': 450, 'deliveryFee': 30, 'total': 480, 'status': 'delivered',
        },
        {
          'items': [
            {'productId': 'Cat Scratching Post', 'name': 'Cat Scratching Post', 'price': 300, 'qty': 2},
          ],
          'itemCount': 2, 'subtotal': 600, 'deliveryFee': 30, 'total': 630, 'status': 'pending',
        },
        {
          'items': [
            {'productId': 'Chew Toy Set', 'name': 'Chew Toy Set', 'price': 120, 'qty': 1},
          ],
          'itemCount': 1, 'subtotal': 120, 'deliveryFee': 30, 'total': 150, 'status': 'shipped',
        },
      ];
      for (final o in samples) {
        await col.add({
          'userId': uid,
          ...o,
          'paymentMethod': 'cod',
          'createdAt': FieldValue.serverTimestamp(),
        });
      }
      return "orders — added ${samples.length}";
    } catch (e) {
      return "orders — FAILED: $e";
    }
  }

  Future<String> _seedRequests(String uid) async {
    try {
      final existing = await _db
          .collection('adoption_requests')
          .where('ownerId', isEqualTo: uid)
          .limit(1)
          .get();
      if (existing.docs.isNotEmpty) {
        return "requests — already has data (skipped)";
      }
      // Attach to one of the user's own listings if there is one.
      String animalId = '';
      String animalName = 'Your pet';
      final mine = await _db
          .collection('animals')
          .where('ownerId', isEqualTo: uid)
          .limit(1)
          .get();
      if (mine.docs.isNotEmpty) {
        animalId = mine.docs.first.id;
        animalName = (mine.docs.first.data()['name'] ?? 'Your pet') as String;
      }
      final col = _db.collection('adoption_requests');
      final samples = <Map<String, String>>[
        {'adopterName': 'Sarah M.', 'message': "We're a family of four with a big garden and we'd love to give a home."},
        {'adopterName': 'Ali H.', 'message': "I work from home and have a big balcony — lots of time and love to give."},
        {'adopterName': 'Noha F.', 'message': "We recently lost our old dog and would love to adopt again."},
      ];
      for (final r in samples) {
        await col.add({
          'adopterId': uid, // must equal auth.uid to satisfy the create rule
          'adopterName': r['adopterName'],
          'ownerId': uid, // so it shows in your "Requests" tab
          'ownerName': 'You',
          'animalId': animalId,
          'animalName': animalName,
          'breed': '',
          'message': r['message'],
          'home': {'outdoor': true, 'ownedBefore': true, 'otherPets': false},
          'status': 'pending',
          'createdAt': FieldValue.serverTimestamp(),
        });
      }
      return "requests — added ${samples.length}";
    } catch (e) {
      return "requests — FAILED: $e";
    }
  }

  Future<String> _seedAppointments(String uid) async {
    try {
      final existing = await _db
          .collection('appointments')
          .where('userId', isEqualTo: uid)
          .limit(1)
          .get();
      if (existing.docs.isNotEmpty) {
        return "appointments — already has data (skipped)";
      }
      final col = _db.collection('appointments');
      final samples = <Map<String, String>>[
        {
          'vetName': 'Dr. Ahmed Hassan', 'clinic': 'Golden Paws Clinic',
          'day': '21', 'month': 'JUL', 'time': '3:00 PM',
          'reason': 'Ear irritation follow-up', 'status': 'confirmed',
        },
        {
          'vetName': 'Dr. Mona Nabil', 'clinic': 'Whiskers Vet Center',
          'day': '28', 'month': 'JUL', 'time': '11:30 AM',
          'reason': 'Annual vaccines', 'status': 'requested',
        },
      ];
      for (final ap in samples) {
        await col.add({
          'userId': uid,
          'vetId': '',
          ...ap,
          'createdAt': FieldValue.serverTimestamp(),
        });
      }
      return "appointments — added ${samples.length}";
    } catch (e) {
      return "appointments — FAILED: $e";
    }
  }
}
