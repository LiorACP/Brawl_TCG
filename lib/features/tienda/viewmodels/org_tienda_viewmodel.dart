import 'package:brawl_tcg/core/theme/app_colors.dart';
import '../data/store_profile.dart';

class OrgTiendaViewModel {
  final StoreProfile profile;
  final StoreStats stats;
  final List<StoreAdminSection> adminSections;
  final List<StoreReview> reviews;

  const OrgTiendaViewModel({
    required this.profile,
    required this.stats,
    required this.adminSections,
    required this.reviews,
  });

  static const OrgTiendaViewModel mock = OrgTiendaViewModel(
    profile: StoreProfile(
      name: 'Dragón Rojo',
      address: 'C/ Aragón 214, Barcelona',
      foundedYear: 2011,
      verified: true,
    ),
    stats: StoreStats(
      rating: 4.8,
      followers: 312,
      tournaments: 47,
    ),
    adminSections: [
      StoreAdminSection(
        icon: '⏱',
        title: 'Horarios',
        subtitle: 'Abierto ahora · cierra 22h',
        color: AppColors.cyan,
      ),
      StoreAdminSection(
        icon: '⬢',
        title: 'Juegos soportados',
        subtitle: '6 juegos · 14 formatos',
        color: AppColors.violet,
      ),
      StoreAdminSection(
        icon: '♟',
        title: 'Staff & jueces',
        subtitle: '3 activos · 1 pendiente',
        color: AppColors.pink,
      ),
      StoreAdminSection(
        icon: '▦',
        title: 'Mesas físicas',
        subtitle: '12 mesas · plano',
        color: AppColors.orange,
      ),
    ],
    reviews: [
      StoreReview(
        authorName: 'Laura M.',
        stars: 5,
        body: 'Torneo FNM muy bien organizado, premios puntuales y ambiente top.',
      ),
    ],
  );
}
