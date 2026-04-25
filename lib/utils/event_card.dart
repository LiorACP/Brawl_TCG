import 'package:brawl_tcg/models/event_model.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class EventCard extends StatelessWidget {
  final Evento evento;
  const EventCard({super.key, required this.evento});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 120,
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Row(
        children: [
          const SizedBox(width: 15),
          CircleAvatar(
            radius: 35,
            backgroundColor: Colors.white10,
            backgroundImage: evento.avatarUrl.isNotEmpty
                ? AssetImage(evento.avatarUrl)
                : null,
            child: evento.avatarUrl.isEmpty
                ? const Icon(Icons.emoji_events, color: Colors.white24, size: 30)
                : null,
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  evento.nombre,
                  style: GoogleFonts.rubik(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                Text(
                  evento.subtitulo,
                  style: GoogleFonts.rubik(color: Colors.white54, fontSize: 12),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    _miniStat(Icons.people, evento.jugadores),
                    const SizedBox(width: 10),
                    _miniStat(Icons.style, evento.formato),
                  ],
                ),
              ],
            ),
          ),
          // RANKING (ESTILO IMAGEN)
          Container(
            width: 70,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFFEC5544), Color(0xFF9120A6)],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
              borderRadius: BorderRadius.only(
                topRight: Radius.circular(15),
                bottomRight: Radius.circular(15),
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "${evento.ranking}",
                  style: GoogleFonts.rubik(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  "Rank",
                  style: GoogleFonts.rubik(color: Colors.white70, fontSize: 10),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _miniStat(IconData icon, String label) {
    return Row(
      children: [
        Icon(icon, size: 14, color: const Color(0XFFF8BF54)),
        const SizedBox(width: 4),
        Text(
          label,
          style: const TextStyle(color: Colors.white70, fontSize: 11),
        ),
      ],
    );
  }
}
