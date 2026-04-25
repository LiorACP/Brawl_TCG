import '../data/tournament.dart';
import '../data/org_kpi.dart';

class OrgEventosViewModel {
  final OrgKpi kpi;
  final Tournament? liveTournament;
  final List<Tournament> upcomingTournaments;
  final int enCursoCount;
  final int draftCount;
  final int finishedCount;

  const OrgEventosViewModel({
    required this.kpi,
    this.liveTournament,
    required this.upcomingTournaments,
    required this.enCursoCount,
    required this.draftCount,
    required this.finishedCount,
  });
}
