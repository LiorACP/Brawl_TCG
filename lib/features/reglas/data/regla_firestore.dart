import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:brawl_tcg/features/eventos/data/tournament.dart';

// Extensión para convertir el enum TcgGame al id del documento en Firestore
// Por ejemplo: TcgGame.mtg -> "magic"
extension TcgGameFirestoreId on TcgGame {
  String get firestoreId => switch (this) {
        TcgGame.mtg => 'magic',
        TcgGame.pok => 'pokemon',
        TcgGame.ygo => 'yugioh',
        TcgGame.lor => 'lorcana',
        TcgGame.fab => 'fab',
        TcgGame.one => 'onepiece',
        TcgGame.dbs => 'dbs',
      };
}

// Modelo para el documento games/{gameId}
// Lo escribe la API de Python cada vez que hace una ingesta
class GameMeta {
  final String gameId;
  final String version;
  final int rulesCount;
  final DateTime? lastUpdated;

  const GameMeta({
    required this.gameId,
    required this.version,
    this.rulesCount = 0,
    this.lastUpdated,
  });

  factory GameMeta.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final d = doc.data() ?? {};
    return GameMeta(
      gameId: doc.id,
      version: d['version'] as String? ?? '—',
      rulesCount: (d['rulesCount'] as num?)?.toInt() ?? 0,
      lastUpdated: (d['lastUpdated'] as Timestamp?)?.toDate(),
    );
  }

  // Valor por defecto cuando Firestore aún no tiene datos del juego
  static const fallback = GameMeta(gameId: '', version: '—');
}

// Modelo para cada documento de la subcolección games/{gameId}/rules/{ruleId}
class ReglaFirestore {
  final String id;
  final String gameId;
  final String title;
  final String category;
  final String body;
  final String language;
  final String version;
  final List<String> searchKeywords;
  final List<String> examples;

  const ReglaFirestore({
    required this.id,
    required this.gameId,
    required this.title,
    required this.category,
    required this.body,
    this.language = 'en',
    this.version = '—',
    this.searchKeywords = const [],
    this.examples = const [],
  });

  factory ReglaFirestore.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final d = doc.data() ?? {};
    return ReglaFirestore(
      id: doc.id,
      gameId: d['game'] as String? ?? '',
      title: d['title'] as String? ?? 'Sin título',
      category: d['category'] as String? ?? 'General',
      body: d['body'] as String? ?? '',
      language: d['language'] as String? ?? 'en',
      version: d['version'] as String? ?? '—',
      searchKeywords: List<String>.from(d['search_keywords'] ?? []),
      examples: List<String>.from(d['examples'] ?? []),
    );
  }
}
