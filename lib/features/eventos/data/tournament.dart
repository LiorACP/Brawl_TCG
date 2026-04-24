import 'package:flutter/material.dart';

enum TcgGame { mtg, pok, ygo, lor, fab, one, dbs }

extension TcgGameX on TcgGame {
  String get code => switch (this) {
        TcgGame.mtg => 'MTG',
        TcgGame.pok => 'POK',
        TcgGame.ygo => 'YGO',
        TcgGame.lor => 'LOR',
        TcgGame.fab => 'FAB',
        TcgGame.one => 'ONE',
        TcgGame.dbs => 'DBS',
      };

  String get shortName => switch (this) {
        TcgGame.mtg => 'Magic',
        TcgGame.pok => 'Pokémon',
        TcgGame.ygo => 'YuGiOh',
        TcgGame.lor => 'Runeterra',
        TcgGame.fab => 'Flesh & Blood',
        TcgGame.one => 'One Piece',
        TcgGame.dbs => 'Dragon Ball',
      };

  String get fullName => switch (this) {
        TcgGame.mtg => 'Magic: The Gathering',
        TcgGame.pok => 'Pokémon TCG',
        TcgGame.ygo => 'Yu-Gi-Oh!',
        TcgGame.lor => 'Runeterra',
        TcgGame.fab => 'Flesh & Blood',
        TcgGame.one => 'One Piece TCG',
        TcgGame.dbs => 'Dragon Ball Fusion',
      };
}

enum TournamentStatus { live, upcoming, draft, finished }

class Tournament {
  final String id;
  final String name;
  final TcgGame game;
  final String format;
  final TournamentStatus status;
  final String dateLabel;
  final String timeLabel;
  final String location;
  final int totalSlots;
  final int enrolledCount;

  // Solo en torneos live
  final int? totalRounds;
  final int? currentRound;
  final List<double>? roundProgress;
  final int? pendingResults;
  final int? activeTables;
  final String? liveTimer;

  // Presentación
  final String? tagLabel;
  final Color? tagColor;
  final double opacity;

  // Económico
  final double? entryFee;
  final String? prizeInfo;

  double get fillFraction =>
      totalSlots > 0 ? enrolledCount / totalSlots : 0.0;

  String get detailLabel =>
      '$dateLabel · $timeLabel · $totalSlots plazas';

  const Tournament({
    required this.id,
    required this.name,
    required this.game,
    required this.format,
    required this.status,
    required this.dateLabel,
    required this.timeLabel,
    required this.location,
    required this.totalSlots,
    required this.enrolledCount,
    this.totalRounds,
    this.currentRound,
    this.roundProgress,
    this.pendingResults,
    this.activeTables,
    this.liveTimer,
    this.tagLabel,
    this.tagColor,
    this.opacity = 1.0,
    this.entryFee,
    this.prizeInfo,
  });
}
