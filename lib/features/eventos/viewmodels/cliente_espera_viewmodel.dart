import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:brawl_tcg/features/eventos/services/torneo_live_service.dart';

class ClienteEsperaViewModel extends ChangeNotifier {
  StreamSubscription<LiveMatchData?>? _matchSub;
  bool shouldPop = false;

  void startWatching() {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;
    _matchSub = TorneoLiveService.watchLiveMatch(uid).listen((data) {
      if (data == null || !data.active) {
        shouldPop = true;
        notifyListeners();
      }
    });
  }

  @override
  void dispose() {
    _matchSub?.cancel();
    super.dispose();
  }
}
