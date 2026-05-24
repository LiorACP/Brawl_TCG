import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

class PremiosViewModel extends ChangeNotifier {
  bool isSaving = false;

  Future<bool> saveDraft(String eventId, int pool, bool productPrize, bool promoPrize) async {
    isSaving = true;
    notifyListeners();
    try {
      await FirebaseFirestore.instance
          .collection('Tournaments')
          .doc(eventId)
          .update({
        'prizePool': pool,
        'productPrize': productPrize,
        'promoPrize': promoPrize,
      });
      return true;
    } catch (_) {
      isSaving = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> next(String eventId, int pool, bool productPrize, bool promoPrize) async {
    isSaving = true;
    notifyListeners();
    try {
      await FirebaseFirestore.instance
          .collection('Tournaments')
          .doc(eventId)
          .update({
        'prizePool': pool,
        'productPrize': productPrize,
        'promoPrize': promoPrize,
        'prizeInfo': '€ $pool · ${productPrize ? 'Producto' : ''}'
            '${productPrize && promoPrize ? ' · ' : ''}'
            '${promoPrize ? 'Promo Top 4' : ''}',
      });
      return true;
    } catch (_) {
      isSaving = false;
      notifyListeners();
      return false;
    }
  }
}
