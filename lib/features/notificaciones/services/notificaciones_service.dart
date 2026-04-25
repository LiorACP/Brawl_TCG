import 'package:cloud_firestore/cloud_firestore.dart';
import '../data/notification.dart';

// Firestore schema for Notifications:
//   date (Timestamp), mensaje (string), type (string), userID (Reference)
//   Optional: title, icon, isRead
//
// Required index: (userID ASC, date DESC)
typedef NotiBundle = ({
  List<AppNotification> today,
  List<AppNotification> yesterday,
  int unreadCount,
});

class NotificacionesService {
  static final _db = FirebaseFirestore.instance;

  static Stream<NotiBundle> watchNotifications(String uid) {
    final userRef = _db.collection('User').doc(uid);
    final cutoff = DateTime.now().subtract(const Duration(days: 2));
    return _db
        .collection('Notifications')
        .where('userID', isEqualTo: userRef)
        .where('date', isGreaterThan: Timestamp.fromDate(cutoff))
        .orderBy('date', descending: true)
        .snapshots()
        .map((snap) {
      final now = DateTime.now();
      final today = <AppNotification>[];
      final yesterday = <AppNotification>[];
      int unread = 0;

      for (final doc in snap.docs) {
        final n = AppNotification.fromFirestore(doc);
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

  static bool _isToday(DateTime dt, DateTime now) =>
      dt.year == now.year && dt.month == now.month && dt.day == now.day;
}
