import 'package:flutter/foundation.dart';
import 'package:brawl_tcg/features/eventos/services/torneo_live_service.dart';

class OrgRondasViewModel extends ChangeNotifier {
  final Map<String, bool> saving = {};
  bool startingNext = false;

  Future<void> scoreMatch({
    required String tournamentId,
    required RoundMatch match,
    required int p1Points,
    required int p2Points,
    required int roundNum,
  }) async {
    saving[match.id] = true;
    notifyListeners();
    try {
      await TorneoLiveService.scoreMatch(
        tournamentId: tournamentId,
        matchId: match.id,
        roundNum: roundNum,
        player1Uid: match.player1Uid,
        player2Uid: match.player2Uid,
        player1Points: p1Points,
        player2Points: p2Points,
      );
    } finally {
      saving.remove(match.id);
      notifyListeners();
    }
  }

  Future<bool> nextRound({
    required String tournamentId,
    required String tournamentName,
    required String organizerId,
    required int currentRound,
  }) async {
    startingNext = true;
    notifyListeners();
    try {
      await TorneoLiveService.nextRound(
        tournamentId: tournamentId,
        tournamentName: tournamentName,
        organizerId: organizerId,
        currentRound: currentRound,
      );
      return true;
    } catch (_) {
      startingNext = false;
      notifyListeners();
      return false;
    }
  }
}
