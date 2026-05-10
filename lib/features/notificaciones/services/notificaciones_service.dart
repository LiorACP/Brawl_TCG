import 'package:brawl_tcg/core/state/app_prefs_notifier.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../data/notification.dart';

typedef NotiBundle = ({
  List<AppNotification> today,
  List<AppNotification> yesterday,
  int unreadCount,
});

class NotificacionesService {
  static final _db = FirebaseFirestore.instance;

  static Stream<NotiBundle> watchNotifications(String uid) {
    final userRef = _db.collection('User').doc(uid);
    return _db
        .collection('Notifications')
        .where('userID', isEqualTo: userRef)
        .snapshots()
        .map((snap) {
      final prefs = AppPrefsNotifier.instance.notifToggles;
      final now = DateTime.now();
      final cutoff = now.subtract(const Duration(days: 2));
      final today = <AppNotification>[];
      final yesterday = <AppNotification>[];
      int unread = 0;

      final docs = snap.docs
          .map((d) => AppNotification.fromFirestore(d))
          .where((n) => n.createdAt.isAfter(cutoff))
          .where((n) => _isAllowed(n, prefs))
          .toList()
        ..sort((a, b) => b.createdAt.compareTo(a.createdAt));

      for (final n in docs) {
        if (!n.isRead) unread++;
        if (_isToday(n.createdAt, now)) {
          today.add(n);
        } else {
          yesterday.add(n);
        }
      }

      return (today: today, yesterday: yesterday, unreadCount: unread);
    });
  }

  // Filtra una notificación según las preferencias del usuario
  static bool _isAllowed(
      AppNotification n, Map<String, bool> prefs) {
    switch (n.type) {
      case NotificationType.event:
        // 'discovered_event' → toggle "Nuevos eventos cerca"
        // otros eventos → toggle "Torneos próximos"
        if (n.icon == '🔍') {
          return prefs['Nuevos eventos cerca'] ?? true;
        }
        return prefs['Torneos próximos'] ?? true;
      case NotificationType.result:
        return prefs['Resultados y emparejamiento'] ?? true;
      case NotificationType.social:
        // Las inscripciones siempre se muestran (acción del organizador)
        return true;
      case NotificationType.system:
        // Tipo 'promo' → toggle "Promociones de tiendas"
        // Resto de sistema siempre visible
        return prefs['Promociones de tiendas'] ?? false;
    }
  }

  static Future<void> markAllRead(String uid) async {
    final userRef = _db.collection('User').doc(uid);
    final snap = await _db
        .collection('Notifications')
        .where('userID', isEqualTo: userRef)
        .where('isRead', isEqualTo: false)
        .get();

    if (snap.docs.isEmpty) return;
    final batch = _db.batch();
    for (final doc in snap.docs) {
      batch.update(doc.reference, {'isRead': true});
    }
    await batch.commit();
  }

  static Future<void> markRead(String notificationId) async {
    await _db
        .collection('Notifications')
        .doc(notificationId)
        .update({'isRead': true});
  }

  // Notificación de inscripción para el organizador
  static Future<void> notifyOrganizer({
    required DocumentReference organizerRef,
    required String playerName,
    required String tournamentName,
    required String tournamentId,
  }) async {
    await _db.collection('Notifications').add({
      'userID': organizerRef,
      'date': FieldValue.serverTimestamp(),
      'type': 'inscripcion',
      'title': 'Nueva inscripción',
      'mensaje': '$playerName quiere apuntarse a $tournamentName',
      'icon': '✉',
      'isRead': false,
      'tournamentId': tournamentId,
    });
  }

  // Notificación de torneo próximo (2h antes) para el jugador inscrito
  static Future<void> notifyTorneoProximo({
    required DocumentReference userRef,
    required String tournamentName,
    required String tournamentId,
  }) async {
    await _db.collection('Notifications').add({
      'userID': userRef,
      'date': FieldValue.serverTimestamp(),
      'type': 'torneo',
      'title': '¡Tu torneo empieza pronto!',
      'mensaje': '$tournamentName comienza en menos de 2 horas',
      'icon': '⏰',
      'isRead': false,
      'tournamentId': tournamentId,
    });
  }

  static bool _isToday(DateTime dt, DateTime now) =>
      dt.year == now.year && dt.month == now.month && dt.day == now.day;
}
