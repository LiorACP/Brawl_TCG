import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:brawl_tcg/core/l10n/app_l10n.dart';

class OrgInscripcionesViewModel {
  Stream<QuerySnapshot<Map<String, dynamic>>> watchPendingRegistrations(
      String tournamentId) {
    return FirebaseFirestore.instance
        .collection('Tournaments')
        .doc(tournamentId)
        .collection('registration')
        .where('status', isEqualTo: 'Pending')
        .orderBy('creadoEn', descending: false)
        .snapshots();
  }

  Future<void> updateStatus({
    required String tournamentId,
    required String tournamentName,
    required String regId,
    required String newStatus,
    required DocumentReference? playerRef,
  }) async {
    final db = FirebaseFirestore.instance;
    final regRef = db
        .collection('Tournaments')
        .doc(tournamentId)
        .collection('registration')
        .doc(regId);

    await regRef.update({'status': newStatus});

    await db
        .collection('Tournaments')
        .doc(tournamentId)
        .update({'pendingCount': FieldValue.increment(-1)});

    if (newStatus == 'Accepted') {
      await db
          .collection('Tournaments')
          .doc(tournamentId)
          .update({'enrolledCount': FieldValue.increment(1)});
    }

    if (playerRef != null) {
      final isAccepted = newStatus == 'Accepted';
      await db.collection('Notifications').add({
        'userID': playerRef,
        'date': FieldValue.serverTimestamp(),
        'type': 'inscripcion_respuesta',
        'title': isAccepted
            ? L10n.t('Inscripción aceptada')
            : L10n.t('Inscripción rechazada'),
        'mensaje': isAccepted
            ? L10n.fmt('Tu inscripción a "{name}" ha sido aceptada. ¡Nos vemos!',
                {'name': tournamentName})
            : L10n.fmt('Tu inscripción a "{name}" ha sido rechazada.',
                {'name': tournamentName}),
        'icon': isAccepted ? '✅' : '❌',
        'isRead': false,
        'tournamentId': tournamentId,
      });
    }
  }
}
