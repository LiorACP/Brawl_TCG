import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../theme/app_colors.dart';

class AppPrefsNotifier extends ChangeNotifier {
  static final AppPrefsNotifier instance = AppPrefsNotifier._();
  AppPrefsNotifier._();

  String _tema = 'dark';
  String _idioma = 'es';
  String _distancia = 'km';
  String _hora = '24h';
  Map<String, bool> _notifToggles = {
    'Torneos próximos': true,
    'Nuevos eventos cerca': true,
    'Resultados y emparejamiento': true,
  };

  String get tema => _tema;
  String get idioma => _idioma;
  String get distancia => _distancia;
  String get hora => _hora;
  Map<String, bool> get notifToggles => Map.unmodifiable(_notifToggles);

  Future<void> loadFromFirestore(String uid) async {
    try {
      final doc =
          await FirebaseFirestore.instance.collection('User').doc(uid).get();
      final data = doc.data();
      if (data == null) return;

      final prefs = data['appPrefs'] as Map<String, dynamic>? ?? {};
      _tema = prefs['tema'] as String? ?? 'dark';
      _idioma = prefs['idioma'] as String? ?? 'es';
      _distancia = prefs['distancia'] as String? ?? 'km';
      _hora = prefs['hora'] as String? ?? '24h';

      final notifPrefs = data['notifPrefs'] as Map<String, dynamic>? ?? {};
      _notifToggles = {
        'Torneos próximos':
            notifPrefs['Torneos próximos'] as bool? ?? true,
        'Nuevos eventos cerca':
            notifPrefs['Nuevos eventos cerca'] as bool? ?? true,
        'Resultados y emparejamiento':
            notifPrefs['Resultados y emparejamiento'] as bool? ?? true,
      };

      AppColors.setTheme(_tema);
      notifyListeners();
    } catch (_) {}
  }

  Future<void> setTema(String uid, String value) async {
    _tema = value;
    AppColors.setTheme(value);
    notifyListeners();
    await _saveAppPref(uid, 'tema', value);
  }

  Future<void> setIdioma(String uid, String value) async {
    _idioma = value;
    notifyListeners();
    await _saveAppPref(uid, 'idioma', value);
  }

  Future<void> setDistancia(String uid, String value) async {
    _distancia = value;
    notifyListeners();
    await _saveAppPref(uid, 'distancia', value);
  }

  Future<void> setHora(String uid, String value) async {
    _hora = value;
    notifyListeners();
    await _saveAppPref(uid, 'hora', value);
  }

  Future<void> setNotifToggle(String uid, String key, bool value) async {
    _notifToggles = {..._notifToggles, key: value};
    notifyListeners();
    try {
      await FirebaseFirestore.instance
          .collection('User')
          .doc(uid)
          .update({'notifPrefs.$key': value});
    } catch (_) {}
  }

  Future<void> _saveAppPref(String uid, String key, dynamic value) async {
    try {
      await FirebaseFirestore.instance
          .collection('User')
          .doc(uid)
          .update({'appPrefs.$key': value});
    } catch (_) {}
  }
}
