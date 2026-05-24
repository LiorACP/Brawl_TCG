import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:brawl_tcg/core/state/app_prefs_notifier.dart';
import 'package:brawl_tcg/features/eventos/services/eventos_service.dart';
import 'package:brawl_tcg/features/notificaciones/services/notificaciones_service.dart';

class ConfigViewModel extends ChangeNotifier {
  Map<String, bool> toggles = {};
  Map<String, bool> ciudadToggles = {};
  bool loadingCiudades = true;
  String nombre = '';
  String email = '';
  String telefono = '';
  String localidad = '';
  String joinYear = '';
  Set<String> selectedGames = {'MTG', 'POK', 'YGO'};

  String get idioma => AppPrefsNotifier.instance.idioma;
  String get apariencia => AppPrefsNotifier.instance.tema;
  String get distancia => AppPrefsNotifier.instance.distancia;
  String get hora => AppPrefsNotifier.instance.hora;

  void init() {
    toggles = Map<String, bool>.from(AppPrefsNotifier.instance.notifToggles);
    loadUser();
  }

  Future<void> loadUser() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) {
      loadingCiudades = false;
      notifyListeners();
      return;
    }
    final creationTime = FirebaseAuth.instance.currentUser?.metadata.creationTime;
    final authEmail = FirebaseAuth.instance.currentUser?.email ?? '';
    try {
      final doc = await FirebaseFirestore.instance.collection('User').doc(uid).get();
      final data = doc.data();
      final loc = data?['localidad'] as String? ?? '';
      final savedNotifCiudades = data?['notifCiudades'] as Map<String, dynamic>? ?? {};
      final notifPrefs = data?['notifPrefs'] as Map<String, dynamic>? ?? {};
      final freshToggles = {
        'Torneos próximos': notifPrefs['Torneos próximos'] as bool? ?? true,
        'Nuevos eventos cerca': notifPrefs['Nuevos eventos cerca'] as bool? ?? true,
        'Resultados y emparejamiento': notifPrefs['Resultados y emparejamiento'] as bool? ?? true,
      };
      nombre = data?['name'] as String? ?? '';
      email = data?['email'] as String? ?? authEmail;
      telefono = data?['telefono'] as String? ?? '';
      joinYear = creationTime != null ? creationTime.year.toString() : '';
      localidad = loc;
      toggles = freshToggles;
      notifyListeners();
      await _loadCiudadesNotif(uid, loc, savedNotifCiudades);
      if (freshToggles['Torneos próximos'] == true) _checkUpcomingTorneos(uid);
      if (freshToggles['Nuevos eventos cerca'] == true) _checkEventosCerca(uid);
    } catch (_) {
      email = authEmail;
      joinYear = creationTime != null ? creationTime.year.toString() : '';
      loadingCiudades = false;
      notifyListeners();
    }
  }

  Future<void> _loadCiudadesNotif(
      String uid, String loc, Map<String, dynamic> savedPrefs) async {
    try {
      final cities = await EventosService.fetchUserCities(uid);
      if (loc.isNotEmpty) cities.add(loc);
      final t = <String, bool>{};
      for (final city in cities) {
        t[city] = savedPrefs[city] as bool? ?? true;
      }
      ciudadToggles = t;
      loadingCiudades = false;
      notifyListeners();
    } catch (_) {
      final t = <String, bool>{};
      if (localidad.isNotEmpty) {
        t[localidad] = savedPrefs[localidad] as bool? ?? true;
      }
      ciudadToggles = t;
      loadingCiudades = false;
      notifyListeners();
    }
  }

  Future<void> _checkUpcomingTorneos(String uid) async {
    final userRef = FirebaseFirestore.instance.collection('User').doc(uid);
    final now = DateTime.now();
    final twoHoursLater = now.add(const Duration(hours: 2));
    try {
      final snap = await FirebaseFirestore.instance
          .collectionGroup('registration')
          .where('userId', isEqualTo: userRef)
          .where('status', isEqualTo: 'Accepted')
          .get();
      for (final regDoc in snap.docs) {
        final tournamentId = regDoc.reference.parent.parent?.id;
        if (tournamentId == null) continue;
        final tDoc = await FirebaseFirestore.instance
            .collection('Tournaments')
            .doc(tournamentId)
            .get();
        if (!tDoc.exists) continue;
        final dateTs = tDoc.data()?['date'] as Timestamp?;
        if (dateTs == null) continue;
        final date = dateTs.toDate();
        if (date.isAfter(now) && date.isBefore(twoHoursLater)) {
          final existing = await FirebaseFirestore.instance
              .collection('Notifications')
              .where('userID', isEqualTo: userRef)
              .where('tournamentId', isEqualTo: tournamentId)
              .where('type', isEqualTo: 'torneo_pronto')
              .get();
          if (existing.docs.isEmpty) {
            final name = tDoc.data()?['name'] as String? ?? 'tu torneo';
            await NotificacionesService.notifyTorneoProximo(
              userRef: userRef,
              tournamentName: name,
              tournamentId: tournamentId,
            );
          }
        }
      }
    } catch (_) {}
  }

  Future<void> _checkEventosCerca(String uid) async {
    final enabledCities = ciudadToggles.entries
        .where((e) => e.value)
        .map((e) => e.key)
        .toList();
    if (enabledCities.isEmpty) return;
    final userRef = FirebaseFirestore.instance.collection('User').doc(uid);
    final since =
        Timestamp.fromDate(DateTime.now().subtract(const Duration(hours: 24)));
    for (final city in enabledCities) {
      try {
        final snap = await FirebaseFirestore.instance
            .collection('Tournaments')
            .where('localidad', isEqualTo: city)
            .where('status', isEqualTo: 'open')
            .where('createdAt', isGreaterThan: since)
            .get();
        for (final tDoc in snap.docs) {
          final existing = await FirebaseFirestore.instance
              .collection('Notifications')
              .where('userID', isEqualTo: userRef)
              .where('tournamentId', isEqualTo: tDoc.id)
              .where('type', isEqualTo: 'discovered_event')
              .get();
          if (existing.docs.isEmpty) {
            final name = tDoc.data()['name'] as String? ?? 'Nuevo torneo';
            await FirebaseFirestore.instance.collection('Notifications').add({
              'userID': userRef,
              'date': FieldValue.serverTimestamp(),
              'type': 'discovered_event',
              'title': 'Nuevo torneo en $city',
              'mensaje': '$name disponible cerca de ti',
              'icon': '🔍',
              'isRead': false,
              'tournamentId': tDoc.id,
            });
          }
        }
      } catch (_) {}
    }
  }

  Future<void> saveCiudadToggle(String city, bool value) async {
    ciudadToggles[city] = value;
    notifyListeners();
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;
    await FirebaseFirestore.instance
        .collection('User')
        .doc(uid)
        .update({'notifCiudades.$city': value});
  }

  Future<void> onNotifToggle(String key, bool value) async {
    toggles[key] = value;
    notifyListeners();
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;
    await AppPrefsNotifier.instance.setNotifToggle(uid, key, value);
    if (value && uid.isNotEmpty) {
      if (key == 'Torneos próximos') _checkUpcomingTorneos(uid);
      if (key == 'Nuevos eventos cerca') _checkEventosCerca(uid);
    }
  }

  Future<void> savePersonalData(String n, String e, String t) async {
    nombre = n;
    email = e;
    telefono = t;
    notifyListeners();
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;
    await FirebaseFirestore.instance.collection('User').doc(uid).update({
      'name': n,
      'email': e,
      if (t.isNotEmpty) 'telefono': t,
    });
  }

  Future<void> logout() => FirebaseAuth.instance.signOut();
}
