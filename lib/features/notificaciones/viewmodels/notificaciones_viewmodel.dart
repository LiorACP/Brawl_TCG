import 'package:brawl_tcg/core/theme/app_colors.dart';
import '../data/notification.dart';

class NotificacionesViewModel {
  final int unreadCount;
  final List<AppNotification> todayNotifications;
  final List<AppNotification> yesterdayNotifications;

  const NotificacionesViewModel({
    required this.unreadCount,
    required this.todayNotifications,
    required this.yesterdayNotifications,
  });

  List<AppNotification> filtered(String filterKey, List<AppNotification> notis) {
    if (filterKey == 'all') return notis;
    final type = switch (filterKey) {
      'events' => NotificationType.event,
      'results' => NotificationType.result,
      'social' => NotificationType.social,
      'system' => NotificationType.system,
      _ => null,
    };
    if (type == null) return notis;
    return notis.where((n) => n.type == type).toList();
  }

  static const NotificacionesViewModel mock = NotificacionesViewModel(
    unreadCount: 5,
    todayNotifications: [
      AppNotification(
        icon: '⏰',
        color: AppColors.cyan,
        title: 'Torneo empieza en 1h 42min',
        body: 'Pioneer FNM · Dragón Rojo Store',
        timeLabel: '5m',
        type: NotificationType.event,
      ),
      AppNotification(
        icon: '⚔',
        color: AppColors.pink,
        title: 'Nueva ronda disponible',
        body: 'R2 contra Laura M. · Mesa 14',
        timeLabel: '12m',
        type: NotificationType.event,
      ),
      AppNotification(
        icon: '✉',
        color: AppColors.violet,
        title: 'Invitación de David R.',
        body: '"Te apuntas al Commander del sábado?"',
        timeLabel: '1h',
        type: NotificationType.social,
      ),
      AppNotification(
        icon: '◉',
        color: AppColors.orange,
        title: 'Nuevo anuncio de El Refugio',
        body: 'Torneo de Yu-Gi-Oh! publicado · 24 plazas',
        timeLabel: '2h',
        type: NotificationType.event,
      ),
      AppNotification(
        icon: '🏆',
        color: AppColors.yellow,
        title: 'Resultado final publicado',
        body: 'Terminaste 2º · +18 pts de ranking · 15 € en tienda',
        timeLabel: '3h',
        type: NotificationType.result,
      ),
    ],
    yesterdayNotifications: [
      AppNotification(
        icon: '★',
        color: AppColors.yellow,
        title: 'Laura M. dejó una reseña de 5★',
        body: '"Organización perfecta, volveré"',
        timeLabel: '18h',
        type: NotificationType.social,
        isRead: true,
      ),
      AppNotification(
        icon: '📍',
        color: AppColors.blue,
        title: 'Nueva tienda cerca',
        body: 'Puzzle Games a 1,2 km',
        timeLabel: '20h',
        type: NotificationType.system,
        isRead: true,
      ),
      AppNotification(
        icon: '✎',
        color: AppColors.orange,
        title: 'Reglas actualizadas · Magic',
        body: 'Nueva ban list efectiva el 28 Abr',
        timeLabel: '22h',
        type: NotificationType.system,
        isRead: true,
      ),
    ],
  );
}
