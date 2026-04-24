import 'package:brawl_tcg/core/theme/app_colors.dart';
import '../data/tournament.dart';
import '../data/enrollment.dart';

class ClienteEventosViewModel {
  final String userName;
  final Enrollment? activeEnrollment;
  final List<Enrollment> upcomingEnrollments;
  final PlayerStats stats;
  final List<TournamentResult> results;

  const ClienteEventosViewModel({
    required this.userName,
    required this.activeEnrollment,
    required this.upcomingEnrollments,
    required this.stats,
    required this.results,
  });

  static ClienteEventosViewModel mock() => const ClienteEventosViewModel(
        userName: 'MARCO',
        activeEnrollment: Enrollment(
          id: 'enr-1',
          tournamentId: 'fnm-std',
          tournamentName: 'Standard FNM — Pioneer',
          game: TcgGame.mtg,
          storeName: 'Dragón Rojo Store · Barcelona',
          dateLabel: 'HOY',
          timeLabel: '18:30',
          tableNumber: 7,
        ),
        upcomingEnrollments: [
          Enrollment(
            id: 'enr-2',
            tournamentId: 'pok-spring',
            tournamentName: 'Copa de Primavera',
            game: TcgGame.pok,
            storeName: 'Puzzle Games · Madrid',
            dateLabel: 'Sáb 25 Abr',
            timeLabel: '10:00',
            tagLabel: 'Clasificación',
            tagColor: AppColors.violet,
          ),
          Enrollment(
            id: 'enr-3',
            tournamentId: 'ygo-master',
            tournamentName: 'Torneo Master Duel',
            game: TcgGame.ygo,
            storeName: 'El Refugio · Valencia',
            dateLabel: 'Dom 26 Abr',
            timeLabel: '17:00',
            tagLabel: 'Amistoso',
            tagColor: AppColors.violet,
          ),
          Enrollment(
            id: 'enr-4',
            tournamentId: 'lor-open',
            tournamentName: 'Riot Runeterra Open',
            game: TcgGame.lor,
            storeName: 'Online',
            dateLabel: 'Vie 1 May',
            timeLabel: '19:30',
            tagLabel: 'Online',
            tagColor: AppColors.cyan,
          ),
        ],
        stats: PlayerStats(played: 27, podiums: 8, titles: 2),
        results: [
          TournamentResult(
            tournamentId: 'pio-14',
            tournamentName: 'Pioneer Challenge #14',
            game: TcgGame.mtg,
            dateLabel: '18 Abr',
            positionLabel: '2º / 32',
            isTop: true,
          ),
          TournamentResult(
            tournamentId: 'liga-prim',
            tournamentName: 'Liga local primavera',
            game: TcgGame.ygo,
            dateLabel: '12 Abr',
            positionLabel: '5º / 24',
            isTop: false,
          ),
          TournamentResult(
            tournamentId: 'pre-scarlet',
            tournamentName: 'Prerelease Scarlet',
            game: TcgGame.pok,
            dateLabel: '6 Abr',
            positionLabel: '🏆 1º / 18',
            isTop: true,
          ),
          TournamentResult(
            tournamentId: 'cmd-night',
            tournamentName: 'Commander Night',
            game: TcgGame.mtg,
            dateLabel: '29 Mar',
            positionLabel: '8º / 16',
            isTop: false,
          ),
        ],
      );
}
