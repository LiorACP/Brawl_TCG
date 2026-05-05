import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class TiendaService {
  static final _db = FirebaseFirestore.instance;

  static String? get _uid => FirebaseAuth.instance.currentUser?.uid;

  static Stream<Map<String, dynamic>> watchProfile() {
    final uid = _uid;
    if (uid == null) return const Stream.empty();
    return _db
        .collection('User')
        .doc(uid)
        .snapshots()
        .map((s) => s.data() ?? {});
  }

  static Future<void> saveProfile(Map<String, dynamic> fields) async {
    final uid = _uid;
    if (uid == null) return;
    await _db.collection('User').doc(uid).set(fields, SetOptions(merge: true));
  }

  static Stream<int> watchTorneosCount() {
    final uid = _uid;
    if (uid == null) return Stream.value(0);
    final orgRef = _db.collection('User').doc(uid);
    return _db
        .collection('Tournaments')
        .where('organizerId', isEqualTo: orgRef)
        .snapshots()
        .map((s) => s.docs.length);
  }
}
