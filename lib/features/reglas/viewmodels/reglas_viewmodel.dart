import 'package:brawl_tcg/features/eventos/data/tournament.dart';
import '../data/game_rule.dart';

class ReglasViewModel {
  final RuleAlert alert;
  final List<GameRule> games;

  const ReglasViewModel({
    required this.alert,
    required this.games,
  });

  static const ReglasViewModel mock = ReglasViewModel(
    alert: RuleAlert(
      tag: '⚡ Actualizado · 28 Abr',
      title: 'Nueva ban list · Magic Standard',
      subtitle: '3 cartas restringidas · lee el comunicado',
    ),
    games: [
      GameRule(
        game: TcgGame.mtg,
        formats: 'Standard · Pioneer · Modern · Commander',
        updated: 'Abr 2026',
        isNew: true,
      ),
      GameRule(
        game: TcgGame.pok,
        formats: 'Standard · Expanded · GLC',
        updated: 'Mar 2026',
      ),
      GameRule(
        game: TcgGame.ygo,
        formats: 'Advanced · Traditional · Speed Duel',
        updated: 'Abr 2026',
        isNew: true,
      ),
      GameRule(
        game: TcgGame.lor,
        formats: 'Standard · Eternal',
        updated: 'Mar 2026',
      ),
      GameRule(
        game: TcgGame.one,
        formats: 'Estándar',
        updated: 'Feb 2026',
      ),
      GameRule(
        game: TcgGame.dbs,
        formats: 'Masters · Zenkai',
        updated: 'Abr 2026',
      ),
    ],
  );
}
