import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:brawl_tcg/core/l10n/app_l10n.dart';
import 'package:brawl_tcg/features/notificaciones/services/notificaciones_service.dart';

class CodigoViewModel extends ChangeNotifier {
  String code = '';
  bool searching = false;
  bool enrolling = false;
  DocumentSnapshot<Map<String, dynamic>>? tournamentDoc;
  String? errorMsg;

  static String parseFormat(String? ruleSet) {
    if (ruleSet == null) return '';
    final dot = ruleSet.indexOf('.');
    if (dot >= 0 && dot < ruleSet.length - 1) {
      return ruleSet.substring(dot + 1).trim();
    }
    return ruleSet.trim();
  }

  static bool requiresDeck(String? ruleSet) {
    final format = parseFormat(ruleSet).toLowerCase();
    return !['draft', 'sealed', 'sealed battle'].contains(format);
  }

  static String gameCodeFromRuleSet(String? ruleSet) {
    final s = (ruleSet ?? '').toLowerCase();
    if (s.contains('magic') || s.contains('mtg')) return 'MTG';
    if (s.contains('pokémon') || s.contains('pokemon')) return 'POK';
    if (s.contains('yu-gi-oh') || s.contains('yugioh') || s.contains('ygo')) return 'YGO';
    if (s.contains('lorcana') || s.contains('disney')) return 'LRC';
    if (s.contains('flesh') || s.contains('blood')) return 'FAB';
    if (s.contains('one piece')) return 'ONE';
    if (s.contains('dragon ball')) return 'DBS';
    return 'MTG';
  }

  void updateCode(String newCode) {
    code = newCode;
    tournamentDoc = null;
    errorMsg = null;
    notifyListeners();
  }

  Future<void> searchTournament(String codeStr) async {
    searching = true;
    notifyListeners();
    try {
      final snap = await FirebaseFirestore.instance
          .collection('Tournaments')
          .where('accessCode', isEqualTo: codeStr)
          .limit(1)
          .get();
      if (snap.docs.isEmpty) {
        errorMsg = L10n.t('Código no encontrado');
        searching = false;
      } else {
        tournamentDoc = snap.docs.first;
        searching = false;
      }
    } catch (_) {
      errorMsg = L10n.t('Error al buscar el torneo');
      searching = false;
    }
    notifyListeners();
  }

  // Returns null on success, error message on failure.
  Future<String?> enroll(String deckUrl) async {
    final doc = tournamentDoc;
    if (doc == null) return null;
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return null;
    enrolling = true;
    notifyListeners();
    try {
      final db = FirebaseFirestore.instance;
      final userRef = db.collection('User').doc(user.uid);
      final orgRef = doc.data()?['organizerId'] as DocumentReference?;
      final existing = await doc.reference
          .collection('registration')
          .where('userId', isEqualTo: userRef)
          .limit(1)
          .get();
      if (existing.docs.isNotEmpty) {
        enrolling = false;
        notifyListeners();
        return L10n.t('Ya estás inscrito en este torneo');
      }
      final userSnap = await userRef.get();
      final userName = userSnap.data()?['name'] as String? ??
          userSnap.data()?['nombre'] as String? ??
          user.email?.split('@').first ??
          'Jugador';
      final tournamentName = doc.data()?['name'] as String? ?? 'Torneo';
      await doc.reference.collection('registration').add({
        'userId': userRef,
        'status': 'Pending',
        'player_name': userName,
        'deck': deckUrl,
        'points': 0,
        'creadoEn': FieldValue.serverTimestamp(),
      });
      doc.reference.update({'pendingCount': FieldValue.increment(1)}).catchError((_) {});
      if (orgRef != null) {
        try {
          await NotificacionesService.notifyOrganizer(
            organizerRef: orgRef,
            playerName: userName,
            tournamentName: tournamentName,
            tournamentId: doc.id,
          );
        } catch (e) {
          debugPrint('Error al enviar notificación al organizador: $e');
        }
      }
      enrolling = false;
      notifyListeners();
      return null;
    } catch (e) {
      enrolling = false;
      notifyListeners();
      return L10n.fmt('Error al inscribirse: {e}', {'e': '$e'});
    }
  }

  void reset() {
    code = '';
    tournamentDoc = null;
    errorMsg = null;
    notifyListeners();
  }
}
