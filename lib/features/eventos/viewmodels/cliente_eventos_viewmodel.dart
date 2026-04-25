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
}
