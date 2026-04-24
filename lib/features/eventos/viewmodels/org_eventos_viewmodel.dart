import 'package:brawl_tcg/core/theme/app_colors.dart';
import '../data/tournament.dart';
import '../data/org_kpi.dart';

class OrgEventosViewModel {
  final OrgKpi kpi;
  final Tournament liveTournament;
  final List<Tournament> upcomingTournaments;
  final int enCursoCount;
  final int draftCount;
  final int finishedCount;

  const OrgEventosViewModel({
    required this.kpi,
    required this.liveTournament,
    required this.upcomingTournaments,
    required this.enCursoCount,
    required this.draftCount,
    required this.finishedCount,
  });

  static OrgEventosViewModel mock() => const OrgEventosViewModel(
        kpi: OrgKpi(
          todayCount: 2,
          totalEnrolled: 48,
          newEnrollments: 6,
          monthlyRevenue: 1240,
        ),
        liveTournament: Tournament(
          id: 'fnm-apr',
          name: 'Pioneer FNM Abril',
          game: TcgGame.mtg,
          format: 'Pioneer',
          status: TournamentStatus.live,
          dateLabel: 'Hoy',
          timeLabel: '18:30',
          location: 'Dragón Rojo Store',
          totalSlots: 32,
          enrolledCount: 32,
          totalRounds: 5,
          currentRound: 3,
          roundProgress: [1.0, 1.0, 1.0, 0.6, 0.0],
          pendingResults: 18,
          activeTables: 16,
          liveTimer: '22:14',
        ),
        upcomingTournaments: [
          Tournament(
            id: 'pok-pre',
            name: 'Prerelease Stellar',
            game: TcgGame.pok,
            format: 'Prerelease',
            status: TournamentStatus.upcoming,
            dateLabel: 'Sáb',
            timeLabel: '10:00',
            location: 'Dragón Rojo Store',
            totalSlots: 16,
            enrolledCount: 12,
            tagLabel: 'Mañana',
            tagColor: AppColors.yellow,
          ),
          Tournament(
            id: 'ygo-liga',
            name: 'Liga Master Duel — J3',
            game: TcgGame.ygo,
            format: 'Master Duel',
            status: TournamentStatus.upcoming,
            dateLabel: 'Dom',
            timeLabel: '17:00',
            location: 'Dragón Rojo Store',
            totalSlots: 24,
            enrolledCount: 8,
            tagLabel: 'Dom',
            tagColor: AppColors.violet,
          ),
          Tournament(
            id: 'lor-show',
            name: 'Runeterra Showdown',
            game: TcgGame.lor,
            format: 'Standard',
            status: TournamentStatus.upcoming,
            dateLabel: 'Vie 1 May',
            timeLabel: '19:30',
            location: 'Online',
            totalSlots: 32,
            enrolledCount: 4,
            tagLabel: 'En 6 días',
            tagColor: AppColors.cyan,
            opacity: 0.8,
          ),
        ],
        enCursoCount: 2,
        draftCount: 1,
        finishedCount: 14,
      );
}
