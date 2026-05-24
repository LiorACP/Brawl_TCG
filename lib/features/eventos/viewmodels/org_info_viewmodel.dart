import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

class OrgInfoViewModel extends ChangeNotifier {
  bool isSaving = false;

  // Returns the new tournament ID on success, null on failure.
  Future<String?> createTournament({
    required String name,
    required DateTime eventDate,
  }) async {
    isSaving = true;
    notifyListeners();
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        isSaving = false;
        notifyListeners();
        return null;
      }
      final orgRef = FirebaseFirestore.instance.collection('User').doc(user.uid);
      final doc = await FirebaseFirestore.instance.collection('Tournaments').add({
        'name': name,
        'date': Timestamp.fromDate(eventDate),
        'status': 'Draft',
        'organizerId': orgRef,
        'enrolledCount': 0,
        'city': '',
      });
      return doc.id;
    } catch (_) {
      isSaving = false;
      notifyListeners();
      return null;
    }
  }

  // Saves a draft without validation (just needs a name).
  Future<bool> saveDraft({
    required String name,
    required DateTime eventDate,
  }) async {
    isSaving = true;
    notifyListeners();
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        isSaving = false;
        notifyListeners();
        return false;
      }
      final orgRef = FirebaseFirestore.instance.collection('User').doc(user.uid);
      await FirebaseFirestore.instance.collection('Tournaments').add({
        'name': name,
        'date': Timestamp.fromDate(eventDate),
        'status': 'Draft',
        'organizerId': orgRef,
        'enrolledCount': 0,
        'city': '',
      });
      return true;
    } catch (_) {
      isSaving = false;
      notifyListeners();
      return false;
    }
  }
}
