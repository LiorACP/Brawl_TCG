import 'package:cloud_firestore/cloud_firestore.dart';

class OrgParticipantesViewModel {
  Stream<QuerySnapshot<Map<String, dynamic>>> watchAcceptedParticipants(
      String tournamentId) {
    return FirebaseFirestore.instance
        .collection('Tournaments')
        .doc(tournamentId)
        .collection('registration')
        .where('status', isEqualTo: 'Accepted')
        .orderBy('creadoEn', descending: false)
        .snapshots();
  }

  Future<void> removePlayer({
    required String tournamentId,
    required String tournamentName,
    required String regId,
    required DocumentReference? playerRef,
  }) async {
    final db = FirebaseFirestore.instance;
    final regRef = db
        .collection('Tournaments')
        .doc(tournamentId)
        .collection('registration')
        .doc(regId);

    await regRef.update({'status': 'Removed'});

    await db
        .collection('Tournaments')
        .doc(tournamentId)
        .update({'enrolledCount': FieldValue.increment(-1)});

    if (playerRef != null) {
      await db.collection('Notifications').add({
        'userID': playerRef,
        'date': FieldValue.serverTimestamp(),
        'type': 'desapuntado',
        'title': 'Has sido desapuntado',
        'mensaje':
            'El organizador te ha eliminado del torneo "$tournamentName".',
        'icon': '⚠',
        'isRead': false,
        'tournamentId': tournamentId,
      });
    }
  }
}
