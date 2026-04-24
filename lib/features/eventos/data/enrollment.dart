import 'package:flutter/material.dart';
import 'tournament.dart';

class Enrollment {
  final String id;
  final String tournamentId;
  final String tournamentName;
  final TcgGame game;
  final String storeName;
  final String dateLabel;
  final String timeLabel;
  final int? tableNumber;
  final String? tagLabel;
  final Color? tagColor;

  String get tableLabel =>
      tableNumber != null ? '#${tableNumber.toString().padLeft(2, '0')}' : '—';

  const Enrollment({
    required this.id,
    required this.tournamentId,
    required this.tournamentName,
    required this.game,
    required this.storeName,
    required this.dateLabel,
    required this.timeLabel,
    this.tableNumber,
    this.tagLabel,
    this.tagColor,
  });
}

class TournamentResult {
  final String tournamentId;
  final String tournamentName;
  final TcgGame game;
  final String dateLabel;
  final String positionLabel;
  final bool isTop;

  const TournamentResult({
    required this.tournamentId,
    required this.tournamentName,
    required this.game,
    required this.dateLabel,
    required this.positionLabel,
    required this.isTop,
  });
}

class PlayerStats {
  final int played;
  final int podiums;
  final int titles;

  const PlayerStats({
    required this.played,
    required this.podiums,
    required this.titles,
  });
}
