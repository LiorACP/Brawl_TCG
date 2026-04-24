import 'package:brawl_tcg/features/eventos/data/tournament.dart';

class GameRule {
  final TcgGame game;
  final String formats;
  final String updated;
  final bool isNew;

  const GameRule({
    required this.game,
    required this.formats,
    required this.updated,
    this.isNew = false,
  });
}

class RuleAlert {
  final String tag;
  final String title;
  final String subtitle;

  const RuleAlert({
    required this.tag,
    required this.title,
    required this.subtitle,
  });
}
