import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';

/// Datos del emparejamiento activo para un jugador.
class LiveMatchData {
  final String tournamentId;
  final String tournamentName;
  final String organizerId;
  final String matchId;
  final int roundNum;
  final String myName;
  final String opponentName;
  final bool isPlayer1;
  final bool active;
  final bool roundFinished;

  const LiveMatchData({
    required this.tournamentId,
    required this.tournamentName,
    required this.organizerId,
    required this.matchId,
    required this.roundNum,
    required this.myName,
    required this.opponentName,
    required this.isPlayer1,
    required this.active,
    required this.roundFinished,
  });

  factory LiveMatchData.fromMap(Map<String, dynamic> d) => LiveMatchData(
        tournamentId: d['tournamentId'] as String? ?? '',
        tournamentName: d['tournamentName'] as String? ?? '',
        organizerId: d['organizerId'] as String? ?? '',
        matchId: d['matchId'] as String? ?? '',
        roundNum: (d['roundNum'] as num?)?.toInt() ?? 1,
        myName: d['myName'] as String? ?? 'Jugador',
        opponentName: d['opponentName'] as String? ?? 'Oponente',
        isPlayer1: d['isPlayer1'] as bool? ?? true,
        active: d['active'] as bool? ?? false,
        roundFinished: d['roundFinished'] as bool? ?? false,
      );
}

/// Datos de un enfrentamiento dentro de una ronda.
class RoundMatch {
  final String id;
  final String player1Uid;
  final String player1Name;
  final String player2Uid;
  final String player2Name;
  final bool player1Done;
  final bool player2Done;
  final int? player1Points;
  final int? player2Points;
  final bool scored;

  const RoundMatch({
    required this.id,
    required this.player1Uid,
    required this.player1Name,
    required this.player2Uid,
    required this.player2Name,
    required this.player1Done,
    required this.player2Done,
    this.player1Points,
    this.player2Points,
    this.scored = false,
  });

  factory RoundMatch.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final d = doc.data()!;
    return RoundMatch(
      id: doc.id,
      player1Uid: d['player1Uid'] as String? ?? '',
      player1Name: d['player1Name'] as String? ?? 'J1',
      player2Uid: d['player2Uid'] as String? ?? '',
      player2Name: d['player2Name'] as String? ?? 'J2',
      player1Done: d['player1Done'] as bool? ?? false,
      player2Done: d['player2Done'] as bool? ?? false,
      player1Points: (d['player1Points'] as num?)?.toInt(),
      player2Points: (d['player2Points'] as num?)?.toInt(),
      scored: d['scored'] as bool? ?? false,
    );
  }

  bool get allDone => player1Done && player2Done;
}

class TorneoLiveService {
  static final _db = FirebaseFirestore.instance;

  /// Genera emparejamientos y notifica a cada jugador via UserLiveMatch.
  /// [randomize] = true para ronda 1, false (orden por puntos) para siguientes.
  static Future<void> startRound({
    required String tournamentId,
    required String tournamentName,
    required String organizerId,
    required int roundNum,
    required bool randomize,
  }) async {
    final regSnap = await _db
        .collection('Tournaments')
        .doc(tournamentId)
        .collection('registration')
        .where('status', isEqualTo: 'Accepted')
        .get();

    final players = regSnap.docs.map((d) {
      final data = d.data();
      final userRef = data['userId'] as DocumentReference?;
      return {
        'uid': userRef?.id ?? d.id,
        'name': data['player_name'] as String? ?? 'Jugador',
        'points': (data['points'] as num?)?.toInt() ?? 0,
      };
    }).toList();

    if (players.length < 2) return;

    if (randomize) {
      players.shuffle(Random());
    } else {
      // Swiss: emparejar por puntos similares (orden descendente, pares adyacentes)
      players.sort(
          (a, b) => (b['points'] as int).compareTo(a['points'] as int));
    }

    final batch = _db.batch();

    final roundRef = _db
        .collection('Tournaments')
        .doc(tournamentId)
        .collection('rounds')
        .doc('$roundNum');

    batch.set(roundRef, {
      'status': 'active',
      'roundNum': roundNum,
      'createdAt': FieldValue.serverTimestamp(),
    });

    for (int i = 0; i < players.length - 1; i += 2) {
      final p1 = players[i];
      final p2 = players[i + 1];
      final matchRef = roundRef.collection('matches').doc();

      batch.set(matchRef, {
        'player1Uid': p1['uid'],
        'player1Name': p1['name'],
        'player2Uid': p2['uid'],
        'player2Name': p2['name'],
        'player1Done': false,
        'player2Done': false,
        'player1Points': null,
        'player2Points': null,
        'scored': false,
        'createdAt': FieldValue.serverTimestamp(),
      });

      // UserLiveMatch para P1
      batch.set(
        _db.collection('UserLiveMatch').doc(p1['uid'] as String),
        {
          'tournamentId': tournamentId,
          'tournamentName': tournamentName,
          'organizerId': organizerId,
          'matchId': matchRef.id,
          'roundNum': roundNum,
          'myName': p1['name'],
          'opponentName': p2['name'],
          'isPlayer1': true,
          'active': true,
          'roundFinished': false,
        },
      );

      // UserLiveMatch para P2
      batch.set(
        _db.collection('UserLiveMatch').doc(p2['uid'] as String),
        {
          'tournamentId': tournamentId,
          'tournamentName': tournamentName,
          'organizerId': organizerId,
          'matchId': matchRef.id,
          'roundNum': roundNum,
          'myName': p2['name'],
          'opponentName': p1['name'],
          'isPlayer1': false,
          'active': true,
          'roundFinished': false,
        },
      );
    }

    batch.update(_db.collection('Tournaments').doc(tournamentId), {
      'status': 'Live',
      'currentRound': roundNum,
      'roundStatus': 'playing',
    });

    await batch.commit();
  }

  /// El jugador marca su partida como terminada.
  static Future<void> markRoundDone({
    required String uid,
    required String tournamentId,
    required String matchId,
    required int roundNum,
    required bool isPlayer1,
    required String organizerId,
    required String playerName,
    required String tournamentName,
  }) async {
    final batch = _db.batch();

    final matchRef = _db
        .collection('Tournaments')
        .doc(tournamentId)
        .collection('rounds')
        .doc('$roundNum')
        .collection('matches')
        .doc(matchId);

    batch.update(matchRef, {
      isPlayer1 ? 'player1Done' : 'player2Done': true,
    });

    batch.update(_db.collection('UserLiveMatch').doc(uid), {
      'roundFinished': true,
    });

    // Notificación al organizador
    batch.set(_db.collection('Notifications').doc(), {
      'userID': _db.collection('User').doc(organizerId),
      'date': FieldValue.serverTimestamp(),
      'type': 'round_done',
      'title': 'Partida terminada',
      'mensaje':
          '$playerName ha terminado su partida en "$tournamentName" (Ronda $roundNum).',
      'icon': '⚔',
      'isRead': false,
      'tournamentId': tournamentId,
    });

    await batch.commit();
  }

  /// Stream del emparejamiento activo del jugador.
  static Stream<LiveMatchData?> watchLiveMatch(String uid) {
    return _db.collection('UserLiveMatch').doc(uid).snapshots().map((snap) {
      if (!snap.exists || snap.data() == null) return null;
      return LiveMatchData.fromMap(snap.data()!);
    });
  }

  /// Stream de todos los enfrentamientos de una ronda (para el organizador).
  static Stream<List<RoundMatch>> watchRoundMatches(
      String tournamentId, int roundNum) {
    return _db
        .collection('Tournaments')
        .doc(tournamentId)
        .collection('rounds')
        .doc('$roundNum')
        .collection('matches')
        .snapshots()
        .map((snap) => snap.docs.map(RoundMatch.fromDoc).toList());
  }

  /// El organizador introduce los puntos de un enfrentamiento.
  static Future<void> scoreMatch({
    required String tournamentId,
    required String matchId,
    required int roundNum,
    required String player1Uid,
    required String player2Uid,
    required int player1Points,
    required int player2Points,
  }) async {
    await _db
        .collection('Tournaments')
        .doc(tournamentId)
        .collection('rounds')
        .doc('$roundNum')
        .collection('matches')
        .doc(matchId)
        .update({
      'player1Points': player1Points,
      'player2Points': player2Points,
      'scored': true,
    });

    await Future.wait([
      _addPoints(tournamentId, player1Uid, player1Points),
      _addPoints(tournamentId, player2Uid, player2Points),
    ]);
  }

  static Future<void> _addPoints(
      String tournamentId, String playerUid, int points) async {
    final q = await _db
        .collection('Tournaments')
        .doc(tournamentId)
        .collection('registration')
        .where('userId',
            isEqualTo: _db.collection('User').doc(playerUid))
        .get();
    if (q.docs.isNotEmpty) {
      await q.docs.first.reference
          .update({'points': FieldValue.increment(points)});
    }
  }

  /// El organizador finaliza el torneo.
  static Future<void> finalizarTorneo(String tournamentId) async {
    final regSnap = await _db
        .collection('Tournaments')
        .doc(tournamentId)
        .collection('registration')
        .where('status', isEqualTo: 'Accepted')
        .get();

    final batch = _db.batch();

    batch.update(_db.collection('Tournaments').doc(tournamentId), {
      'status': 'Finished',
      'roundStatus': 'finished',
    });

    for (final doc in regSnap.docs) {
      final userRef = doc.data()['userId'] as DocumentReference?;
      if (userRef != null) {
        batch.delete(_db.collection('UserLiveMatch').doc(userRef.id));
      }
    }

    await batch.commit();
  }

  /// Inicia la siguiente ronda (emparejamiento por puntos).
  static Future<void> nextRound({
    required String tournamentId,
    required String tournamentName,
    required String organizerId,
    required int currentRound,
  }) async {
    await startRound(
      tournamentId: tournamentId,
      tournamentName: tournamentName,
      organizerId: organizerId,
      roundNum: currentRound + 1,
      randomize: false,
    );
  }
}
