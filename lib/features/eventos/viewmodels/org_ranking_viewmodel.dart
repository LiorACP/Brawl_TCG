import 'package:cloud_firestore/cloud_firestore.dart';

class OrgRankingViewModel {
  Stream<List<QueryDocumentSnapshot<Map<String, dynamic>>>> watchRanking(
      String tournamentId) {
    return FirebaseFirestore.instance
        .collection('Tournaments')
        .doc(tournamentId)
        .collection('registration')
        .where('status', isEqualTo: 'Accepted')
        .snapshots()
        .map((snap) {
      final sorted = [...snap.docs]
        ..sort((a, b) {
          final pa = (a.data()['points'] as num?)?.toInt() ?? 0;
          final pb = (b.data()['points'] as num?)?.toInt() ?? 0;
          return pb.compareTo(pa);
        });
      return sorted;
    });
  }
}
