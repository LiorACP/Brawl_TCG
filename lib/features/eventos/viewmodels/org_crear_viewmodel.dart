import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

class OrgCrearViewModel extends ChangeNotifier {
  bool isSaving = false;

  Future<bool> saveDraft({
    required String eventId,
    required String gameFullName,
    required String formatName,
    required int plazas,
    required double entryFee,
  }) async {
    isSaving = true;
    notifyListeners();
    try {
      await FirebaseFirestore.instance
          .collection('Tournaments')
          .doc(eventId)
          .update({
        'rule_set': '$gameFullName. $formatName',
        'participants': plazas,
        'entryFee': entryFee,
      });
      return true;
    } catch (_) {
      isSaving = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> next({
    required String eventId,
    required String gameFullName,
    required String formatName,
    required int plazas,
    required double entryFee,
  }) async {
    isSaving = true;
    notifyListeners();
    try {
      await FirebaseFirestore.instance
          .collection('Tournaments')
          .doc(eventId)
          .update({
        'rule_set': '$gameFullName. $formatName',
        'participants': plazas,
        'entryFee': entryFee,
      });
      return true;
    } catch (_) {
      isSaving = false;
      notifyListeners();
      return false;
    }
  }
}
