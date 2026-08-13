import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class Appointment {
  final String id, day, month, vetName, time, clinic, reason, status;
  Appointment({
    required this.id,
    required this.day,
    required this.month,
    required this.vetName,
    required this.time,
    required this.clinic,
    required this.reason,
    required this.status,
  });
}

class AppointmentRepository {
  final CollectionReference<Map<String, dynamic>> _col =
      FirebaseFirestore.instance.collection('appointments');

  Future<void> book({
    required String vetId,
    required String vetName,
    required String clinic,
    required String day,
    required String month,
    required String time,
    required String reason,
  }) async {
    final uid = FirebaseAuth.instance.currentUser?.uid ?? 'anonymous';
    await _col.add({
      'userId': uid,
      'vetId': vetId,
      'vetName': vetName,
      'clinic': clinic,
      'day': day,
      'month': month,
      'time': time,
      'reason': reason,
      'status': 'requested',
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Stream<List<Appointment>> watchMine(String uid) {
    return _col.where('userId', isEqualTo: uid).snapshots().map((snap) =>
        snap.docs.map((d) {
          final m = d.data();
          final s = (m['status'] ?? 'requested') as String;
          return Appointment(
            id: d.id,
            day: (m['day'] ?? '') as String,
            month: (m['month'] ?? '') as String,
            vetName: (m['vetName'] ?? '') as String,
            time: (m['time'] ?? '') as String,
            clinic: (m['clinic'] ?? '') as String,
            reason: (m['reason'] ?? '') as String,
            status: s.isNotEmpty ? s[0].toUpperCase() + s.substring(1) : s,
          );
        }).toList());
  }

  Future<void> updateStatus(String id, String status) async {
    await _col.doc(id).update({'status': status});
  }

  Future<void> reschedule(String id,
      {required String day, required String month, required String time}) async {
    await _col.doc(id).update({
      'day': day,
      'month': month,
      'time': time,
      'status': 'requested',
    });
  }
}
