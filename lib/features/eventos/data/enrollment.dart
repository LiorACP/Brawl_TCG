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
  final DateTime date;
  final int? tableNumber;
  final String? tagLabel;
  final Color? tagColor;
  final String? organizerId;

  String get tableLabel =>
      tableNumber != null ? '#${tableNumber.toString().padLeft(2, '0')}' : '—';

  bool get isFuture => date.isAfter(DateTime.now());

  Enrollment({
    required this.id,
    required this.tournamentId,
    required this.tournamentName,
    required this.game,
    required this.storeName,
    required this.dateLabel,
    required this.timeLabel,
    required this.date,
    this.tableNumber,
    this.tagLabel,
    this.tagColor,
    this.organizerId,
  });
}

class TournamentResult {
  final String tournamentId;
  final String tournamentName;
  final TcgGame game;
  final String dateLabel;
  final String positionLabel;
  final bool isTop;
  final DateTime date;

  TournamentResult({
    required this.tournamentId,
    required this.tournamentName,
    required this.game,
    required this.dateLabel,
    required this.positionLabel,
    required this.isTop,
    required this.date,
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
