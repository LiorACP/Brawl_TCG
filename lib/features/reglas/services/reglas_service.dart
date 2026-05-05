import 'package:cloud_firestore/cloud_firestore.dart';
import '../data/regla_firestore.dart';

class ReglasService {
  static final _db = FirebaseFirestore.instance;

  // Escucha el documento de metadatos del juego para mostrar la versión actualizada
  static Stream<GameMeta> watchGameMeta(String gameId) {
    return _db
        .collection('games')
        .doc(gameId)
        .withConverter<GameMeta>(
          fromFirestore: (snap, _) => GameMeta.fromFirestore(snap),
          toFirestore: (_, __) => {},
        )
        .snapshots()
        .map((snap) => snap.data() ?? GameMeta.fallback);
  }

  // Devuelve las reglas de un juego, con filtro opcional por categoría
  static Stream<List<ReglaFirestore>> watchRules(
    String gameId, {
    String? category,
  }) {
    Query<Map<String, dynamic>> query = _db
        .collection('games')
        .doc(gameId)
        .collection('rules');

    if (category != null) {
      query = query.where('category', isEqualTo: category);
    }

    return query.snapshots().map((snap) {
      final rules = snap.docs
          .map((d) => ReglaFirestore.fromFirestore(d))
          .toList()
        ..sort((a, b) => a.title.compareTo(b.title));
      return rules;
    });
  }

  // Saca las categorías únicas para mostrar los chips de filtro arriba
  static Stream<List<String>> watchCategories(String gameId) {
    return watchRules(gameId).map((rules) {
      final cats = rules.map((r) => r.category).toSet().toList()..sort();
      return cats;
    });
  }

  // Consulta puntual para obtener solo la versión sin abrir un stream
  static Future<String> fetchVersion(String gameId) async {
    final doc = await _db.collection('games').doc(gameId).get();
    return doc.data()?['version'] as String? ?? '—';
  }

  // Devuelve el GameMeta actualizado más recientemente entre todos los juegos.
  // Emite null si ningún juego tiene lastUpdated (la API no ha corrido aún).
  static Stream<GameMeta?> watchLatestUpdate() {
    return _db.collection('games').snapshots().map((snap) {
      final withDate = snap.docs
          .map((d) => GameMeta.fromFirestore(d))
          .where((m) => m.lastUpdated != null)
          .toList();
      if (withDate.isEmpty) return null;
      return withDate.reduce(
        (a, b) => a.lastUpdated!.isAfter(b.lastUpdated!) ? a : b,
      );
    });
  }
}
