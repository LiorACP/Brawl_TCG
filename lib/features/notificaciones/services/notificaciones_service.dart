import 'package:cloud_firestore/cloud_firestore.dart';
import '../data/notification.dart';

// Campos del documento en Firestore (colección Notifications):
//   date (Timestamp), mensaje (string), type (string), userID (Reference)
//   title, icon, isRead  (opcionales)
typedef NotiBundle = ({
  List<AppNotification> today,
  List<AppNotification> yesterday,
  int unreadCount,
});

class NotificacionesService {
  static final _db = FirebaseFirestore.instance;

  static Stream<NotiBundle> watchNotifications(String uid) {
    final userRef = _db.collection('User').doc(uid);
    // Solo filtro por userID para no necesitar un índice compuesto en Firestore.
    // El filtro por fecha y el orden los hago yo aquí en el cliente.
    return _db
        .collection('Notifications')
        .where('userID', isEqualTo: userRef)
        .snapshots()
        .map((snap) {
      final now = DateTime.now();
      // Solo muestro notificaciones de los últimos 2 días
      final cutoff = now.subtract(const Duration(days: 2));
      final today = <AppNotification>[];
      final yesterday = <AppNotification>[];
      int unread = 0;

      final docs = snap.docs
          .map((d) => AppNotification.fromFirestore(d))
          .where((n) => n.createdAt.isAfter(cutoff))
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

  // Marca todas las notificaciones del usuario como leídas de una vez
  static Future<void> markAllRead(String uid) async {
    final userRef = _db.collection('User').doc(uid);
    final snap = await _db
        .collection('Notifications')
        .where('userID', isEqualTo: userRef)
        .where('isRead', isEqualTo: false)
        .get();

    if (snap.docs.isEmpty) return;
    // Uso batch para actualizar todas en una sola petición
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

  // Comprueba si una fecha es de hoy comparando año, mes y día
  static bool _isToday(DateTime dt, DateTime now) =>
      dt.year == now.year && dt.month == now.month && dt.day == now.day;
}
