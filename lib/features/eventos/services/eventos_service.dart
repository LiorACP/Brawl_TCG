import 'package:cloud_firestore/cloud_firestore.dart';
import '../data/tournament.dart';
import '../data/enrollment.dart';
import '../data/org_kpi.dart';

// Required Firestore indexes:
//   Tournaments: (organizerId ASC, status ASC, date ASC)
//   registration (collection group): (userId ASC, status ASC)
class EventosService {
  static final _db = FirebaseFirestore.instance;

  // ── CLIENTE: inscripciones aceptadas ──────────────────────────────────────
  //
  // registration is a subcollection of Tournaments:
  //   Tournaments/{id}/registration/{regId}
  //   Fields: userId (Reference), status, deck, player_name, points
  //
  // We query via collectionGroup so we don't need to know the tournament ID
  // upfront. The parent tournament is retrieved via regDoc.reference.parent.parent.

  static Stream<(Enrollment? active, List<Enrollment> upcoming)>
      watchClienteApuntados(String uid) {
    final userRef = _db.collection('User').doc(uid);
    return _db
        .collectionGroup('registration')
        .where('userId', isEqualTo: userRef)
        .where('status', isEqualTo: 'Accepted')
        .snapshots()
        .asyncMap((snap) => _buildApuntados(snap.docs));
  }

  static Future<(Enrollment? active, List<Enrollment> upcoming)>
      _buildApuntados(
          List<QueryDocumentSnapshot<Map<String, dynamic>>> docs) async {
    if (docs.isEmpty) return (null, <Enrollment>[]);

    final results = await Future.wait(docs.map(_enrollmentFromReg));
    final all = results
        .whereType<Enrollment>()
        .where((e) => e.isFuture)
        .toList()
      ..sort((a, b) => a.date.compareTo(b.date));

    if (all.isEmpty) return (null, <Enrollment>[]);
    return (all.first, all.skip(1).toList());
  }

  // ── CLIENTE: torneos participados (fecha pasada) ──────────────────────────

  static Stream<(PlayerStats stats, List<TournamentResult> results)>
      watchClienteParticipados(String uid) {
    final userRef = _db.collection('User').doc(uid);
    return _db
        .collectionGroup('registration')
        .where('userId', isEqualTo: userRef)
        .where('status', isEqualTo: 'Accepted')
        .snapshots()
        .asyncMap((snap) => _buildParticipados(snap.docs));
  }

  static Future<(PlayerStats stats, List<TournamentResult> results)>
      _buildParticipados(
          List<QueryDocumentSnapshot<Map<String, dynamic>>> docs) async {
    if (docs.isEmpty) {
      return (
        const PlayerStats(played: 0, podiums: 0, titles: 0),
        <TournamentResult>[]
      );
    }

    final now = DateTime.now();
    final futures = docs.map((regDoc) async {
      try {
        final tournamentId = regDoc.reference.parent.parent!.id;
        final tDoc = await _db.collection('Tournaments').doc(tournamentId).get();
        if (!tDoc.exists) return null;

        final t = Tournament.fromFirestore(tDoc);
        if (t.date == null || t.date!.isAfter(now)) return null;

        final reg = regDoc.data();
        final position = (reg['points'] as num?)?.toInt();
        return TournamentResult(
          tournamentId: tournamentId,
          tournamentName: t.name,
          game: t.game,
          dateLabel: _shortDate(t.date!),
          positionLabel: position != null && position > 0
              ? '$position pts'
              : '— pts',
          isTop: position != null && position >= 9,
          date: t.date!,
        );
      } catch (_) {
        return null;
      }
    });

    final results = (await Future.wait(futures))
        .whereType<TournamentResult>()
        .toList()
      ..sort((a, b) => b.date.compareTo(a.date));

    final played = results.length;
    final podiums = results.where((r) => r.isTop).length;
    final titles = 0; // titles require a specific "position=1" field not yet in schema

    return (
      PlayerStats(played: played, podiums: podiums, titles: titles),
      results
    );
  }

  // ── ORGANIZADOR: torneos en curso (Live + Pending) ────────────────────────

  static Stream<List<Tournament>> watchOrgEnCurso(String orgId) {
    final orgRef = _db.collection('User').doc(orgId);
    return _db
        .collection('Tournaments')
        .where('organizerId', isEqualTo: orgRef)
        .where('status', whereIn: ['Live', 'Pending'])
        .orderBy('date')
        .snapshots()
        .map((snap) =>
            snap.docs.map((d) => Tournament.fromFirestore(d)).toList());
  }

  static Stream<List<Tournament>> watchOrgByStatus(
      String orgId, String status) {
    final orgRef = _db.collection('User').doc(orgId);
    return _db
        .collection('Tournaments')
        .where('organizerId', isEqualTo: orgRef)
        .where('status', isEqualTo: status)
        .orderBy('date', descending: status == 'Finished')
        .snapshots()
        .map((snap) =>
            snap.docs.map((d) => Tournament.fromFirestore(d)).toList());
  }

  // ── ORGANIZADOR: KPIs en tiempo real ─────────────────────────────────────

  static Stream<OrgKpi> watchOrgKpi(String orgId) {
    final orgRef = _db.collection('User').doc(orgId);
    return _db
        .collection('Tournaments')
        .where('organizerId', isEqualTo: orgRef)
        .where('status', whereIn: ['Live', 'Pending'])
        .snapshots()
        .asyncMap((snap) => _buildKpi(snap.docs));
  }

  static Future<OrgKpi> _buildKpi(
      List<QueryDocumentSnapshot<Map<String, dynamic>>> docs) async {
    final now = DateTime.now();
    final startOfDay = DateTime(now.year, now.month, now.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));

    int todayCount = 0;
    int totalEnrolled = 0;
    int newEnrollments = 0;

    for (final doc in docs) {
      final t = Tournament.fromFirestore(doc);
      if (t.date != null &&
          !t.date!.isBefore(startOfDay) &&
          t.date!.isBefore(endOfDay)) {
        todayCount++;
      }

      // Count registrations from subcollection
      try {
        final regSnap = await doc.reference.collection('registration').get();
        totalEnrolled +=
            regSnap.docs.where((r) => r['status'] == 'Accepted').length;
        newEnrollments +=
            regSnap.docs.where((r) => r['status'] == 'Pending').length;
      } catch (_) {}
    }

    return OrgKpi(
      todayCount: todayCount,
      totalEnrolled: totalEnrolled,
      newEnrollments: newEnrollments,
      monthlyRevenue: 0,
    );
  }

  // ── HELPERS ───────────────────────────────────────────────────────────────

  static Future<Enrollment?> _enrollmentFromReg(
      QueryDocumentSnapshot<Map<String, dynamic>> regDoc) async {
    try {
      final tournamentId = regDoc.reference.parent.parent!.id;
      final tDoc = await _db.collection('Tournaments').doc(tournamentId).get();
      if (!tDoc.exists) return null;

      final t = Tournament.fromFirestore(tDoc);
      final date = t.date ?? DateTime.now();
      final reg = regDoc.data();

      return Enrollment(
        id: regDoc.id,
        tournamentId: tournamentId,
        tournamentName: t.name,
        game: t.game,
        storeName: t.location,
        dateLabel: t.dateLabel,
        timeLabel: t.timeLabel,
        date: date,
        tableNumber: (reg['tableNumber'] as num?)?.toInt(),
      );
    } catch (_) {
      return null;
    }
  }

  static String _shortDate(DateTime d) {
    const months = [
      'Ene', 'Feb', 'Mar', 'Abr', 'May', 'Jun',
      'Jul', 'Ago', 'Sep', 'Oct', 'Nov', 'Dic',
    ];
    return '${d.day} ${months[d.month - 1]}';
  }
}
