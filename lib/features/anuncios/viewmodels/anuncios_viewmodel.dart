import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:brawl_tcg/core/l10n/app_l10n.dart';

class AnunciosViewModel extends ChangeNotifier {
  String eventName = '';
  String dateTimeLabel = '';
  String gameCode = 'MTG';
  int plazas = 0;
  double entryFee = 0;
  int enrolledCount = 0;
  bool loading = true;
  bool isSaving = false;

  Future<void> loadEvent(String eventId) async {
    try {
      final doc = await FirebaseFirestore.instance
          .collection('Tournaments')
          .doc(eventId)
          .get();
      final d = doc.data() ?? {};
      final timestamp = d['date'] as Timestamp?;
      final date = timestamp?.toDate();
      final ruleSet = d['rule_set'] as String? ?? '';
      eventName = d['name'] as String? ?? '';
      dateTimeLabel = date != null ? _formatDateTime(date) : '';
      gameCode = parseGameCode(ruleSet);
      plazas = (d['participants'] as num?)?.toInt() ?? 0;
      entryFee = (d['entryFee'] as num?)?.toDouble() ?? 0;
      enrolledCount = (d['enrolledCount'] as num?)?.toInt() ?? 0;
      loading = false;
      notifyListeners();
    } catch (_) {
      loading = false;
      notifyListeners();
    }
  }

  static String parseGameCode(String ruleSet) {
    final s = ruleSet.toLowerCase();
    if (s.contains('magic') || s.contains('mtg')) return 'MTG';
    if (s.contains('pokémon') || s.contains('pokemon')) return 'POK';
    if (s.contains('yu-gi-oh') || s.contains('yugioh') || s.contains('ygo')) return 'YGO';
    if (s.contains('lorcana') || s.contains('disney')) return 'LRC';
    if (s.contains('flesh') || s.contains('blood')) return 'FAB';
    if (s.contains('one piece')) return 'ONE';
    if (s.contains('dragon ball')) return 'DBS';
    return 'MTG';
  }

  static const _codeChars = 'ABCDEFGHJKMNPQRSTUVWXYZ23456789';

  static String generateCode() {
    final rng = Random.secure();
    return List.generate(6, (_) => _codeChars[rng.nextInt(_codeChars.length)]).join();
  }

  static String _formatDateTime(DateTime d) {
    const weekdays = ['LUN', 'MAR', 'MIÉ', 'JUE', 'VIE', 'SÁB', 'DOM'];
    final h = d.hour.toString().padLeft(2, '0');
    final m = d.minute.toString().padLeft(2, '0');
    return '${L10n.t(weekdays[d.weekday - 1])} · $h:$m';
  }

  Future<bool> saveDraft(String eventId, String text, String code) async {
    isSaving = true;
    notifyListeners();
    try {
      await FirebaseFirestore.instance
          .collection('Tournaments')
          .doc(eventId)
          .update({
        'announcementText': text.trim(),
        if (code.trim().isNotEmpty) 'accessCode': code.trim(),
      });
      return true;
    } catch (_) {
      isSaving = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> saveChanges(String eventId, String text, String code) async {
    isSaving = true;
    notifyListeners();
    try {
      await FirebaseFirestore.instance
          .collection('Tournaments')
          .doc(eventId)
          .update({
        'announcementText': text.trim(),
        if (code.trim().isNotEmpty) 'accessCode': code.trim(),
      });
      return true;
    } catch (_) {
      isSaving = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> publish(String eventId, String text, String code) async {
    isSaving = true;
    notifyListeners();
    try {
      await FirebaseFirestore.instance
          .collection('Tournaments')
          .doc(eventId)
          .update({
        'status': 'Pending',
        'announcementText': text.trim(),
        if (code.trim().isNotEmpty) 'accessCode': code.trim(),
      });
      return true;
    } catch (_) {
      isSaving = false;
      notifyListeners();
      return false;
    }
  }
}
