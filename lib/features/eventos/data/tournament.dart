import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

enum TcgGame { mtg, pok, ygo, lor, fab, one, dbs }

extension TcgGameX on TcgGame {
  String get code => switch (this) {
        TcgGame.mtg => 'MTG',
        TcgGame.pok => 'POK',
        TcgGame.ygo => 'YGO',
        TcgGame.lor => 'LRC',
        TcgGame.fab => 'FAB',
        TcgGame.one => 'ONE',
        TcgGame.dbs => 'DBS',
      };

  String get shortName => switch (this) {
        TcgGame.mtg => 'Magic',
        TcgGame.pok => 'Pokémon',
        TcgGame.ygo => 'YuGiOh',
        TcgGame.lor => 'Lorcana',
        TcgGame.fab => 'Flesh & Blood',
        TcgGame.one => 'One Piece',
        TcgGame.dbs => 'Dragon Ball',
      };

  String get fullName => switch (this) {
        TcgGame.mtg => 'Magic: The Gathering',
        TcgGame.pok => 'Pokémon TCG',
        TcgGame.ygo => 'Yu-Gi-Oh!',
        TcgGame.lor => 'Disney Lorcana',
        TcgGame.fab => 'Flesh and Blood',
        TcgGame.one => 'One Piece TCG',
        TcgGame.dbs => 'Dragon Ball Super',
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
  final String? organizerId;
  final DateTime? date;

  // Live fields
  final int? totalRounds;
  final int? currentRound;
  final List<double>? roundProgress;
  final int? pendingResults;
  final int? activeTables;
  final String? liveTimer;

  // Presentation
  final String? tagLabel;
  final Color? tagColor;
  final double opacity;

  // Economic
  final double? entryFee;
  final String? prizeInfo;

  // Access
  final String? accessCode;

  double get fillFraction => totalSlots > 0 ? enrolledCount / totalSlots : 0.0;
  String get detailLabel => '$dateLabel · $timeLabel · $totalSlots plazas';

  Tournament({
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
    this.organizerId,
    this.date,
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
    this.accessCode,
  });

  // Firestore schema:
  //   name, rule_set, status, date (Timestamp), city,
  //   organizerId (DocumentReference), participants (optional)
  factory Tournament.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final d = doc.data()!;

    final ruleSet =
        d['rule_set'] as String? ?? d['game'] as String? ?? '';
    final game = _parseGame(ruleSet);
    final format = _parseFormat(ruleSet);

    // organizerId is stored as a DocumentReference
    final orgRef = d['organizerId'] as DocumentReference?;
    final organizerId = orgRef?.id;

    final timestamp = d['date'] as Timestamp?;
    final date = timestamp?.toDate();

    return Tournament(
      id: doc.id,
      name: d['name'] as String? ?? '',
      game: game,
      format: format,
      status: _parseStatus(d['status'] as String? ?? ''),
      dateLabel: date != null ? _dateLabel(date) : '',
      timeLabel: date != null ? _timeLabel(date) : '',
      location: d['city'] as String? ?? d['location'] as String? ?? '',
      totalSlots: (d['participants'] as num?)?.toInt() ??
          (d['totalSlots'] as num?)?.toInt() ??
          0,
      enrolledCount: (d['enrolledCount'] as num?)?.toInt() ?? 0,
      organizerId: organizerId,
      date: date,
      currentRound: (d['currentRound'] as num?)?.toInt(),
      totalRounds: (d['totalRounds'] as num?)?.toInt(),
      roundProgress: (d['roundProgress'] as List?)
          ?.map((e) => (e as num).toDouble())
          .toList(),
      pendingResults: (d['pendingResults'] as num?)?.toInt(),
      activeTables: (d['activeTables'] as num?)?.toInt(),
      liveTimer: d['liveTimer'] as String?,
      entryFee: (d['entryFee'] as num?)?.toDouble(),
      prizeInfo: d['prizeInfo'] as String?,
      accessCode: d['accessCode'] as String?,
    );
  }

  static TcgGame _parseGame(String ruleSet) {
    final s = ruleSet.toLowerCase();
    if (s.contains('magic') || s.contains('mtg')) return TcgGame.mtg;
    if (s.contains('pokémon') || s.contains('pokemon')) return TcgGame.pok;
    if (s.contains('yu-gi-oh') || s.contains('yugioh') || s.contains('ygo')) {
      return TcgGame.ygo;
    }
    if (s.contains('lorcana') || s.contains('disney')) return TcgGame.lor;
    if (s.contains('flesh') || s.contains('blood')) return TcgGame.fab;
    if (s.contains('one piece')) return TcgGame.one;
    if (s.contains('dragon ball')) return TcgGame.dbs;
    return TcgGame.mtg;
  }

  // "Magic: The Gathering. Commander" → "Commander"
  static String _parseFormat(String ruleSet) {
    final dot = ruleSet.indexOf('.');
    if (dot >= 0 && dot < ruleSet.length - 1) {
      return ruleSet.substring(dot + 1).trim();
    }
    return ruleSet;
  }

  static TournamentStatus _parseStatus(String s) => switch (s.toLowerCase()) {
        'live' => TournamentStatus.live,
        'draft' => TournamentStatus.draft,
        'finished' => TournamentStatus.finished,
        _ => TournamentStatus.upcoming, // covers "Pending" and "upcoming"
      };

  static String _dateLabel(DateTime d) {
    final now = DateTime.now();
    if (_sameDay(d, now)) return 'HOY';
    if (_sameDay(d, now.add(const Duration(days: 1)))) return 'Mañana';
    const months = [
      'Ene', 'Feb', 'Mar', 'Abr', 'May', 'Jun',
      'Jul', 'Ago', 'Sep', 'Oct', 'Nov', 'Dic',
    ];
    const weekdays = ['Lun', 'Mar', 'Mié', 'Jue', 'Vie', 'Sáb', 'Dom'];
    return '${weekdays[d.weekday - 1]} ${d.day} ${months[d.month - 1]}';
  }

  static String _timeLabel(DateTime d) {
    final h = d.hour.toString().padLeft(2, '0');
    final m = d.minute.toString().padLeft(2, '0');
    return '$h:$m';
  }

  static bool _sameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;
}
