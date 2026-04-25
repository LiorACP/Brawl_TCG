import 'package:cloud_firestore/cloud_firestore.dart';

class Evento {
  final String id;
  final String nombre;
  final String subtitulo;
  final String jugadores;
  final String formato;
  final String premios;
  final int ranking;
  final String avatarUrl;

  Evento({
    required this.id,
    required this.nombre,
    required this.subtitulo,
    required this.jugadores,
    required this.formato,
    required this.premios,
    required this.ranking,
    required this.avatarUrl,
  });

  factory Evento.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Evento(
      id: doc.id,
      nombre: data['nombre'] ?? '',
      subtitulo: data['subtitulo'] ?? '',
      jugadores: (data['jugadores'] ?? 0).toString(),
      formato: data['formato'] ?? '',
      premios: data['premios'] ?? '',
      ranking: (data['ranking'] ?? 0) as int,
      avatarUrl: data['avatarUrl'] ?? '',
    );
  }
}