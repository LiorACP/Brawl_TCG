import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:brawl_tcg/core/theme/app_colors.dart';
import 'package:brawl_tcg/core/navigation/transitions.dart';
import 'data/tournament.dart';
import 'org_rondas_screen.dart';

class OrgRankingScreen extends StatelessWidget {
  final Tournament tournament;
  const OrgRankingScreen({super.key, required this.tournament});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        backgroundColor: AppColors.bgDeep,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new, color: AppColors.text, size: 18),
          onPressed: () => Navigator.pop(context),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Ranking',
              style: GoogleFonts.rubik(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: AppColors.text,
              ),
            ),
            Text(
              tournament.name,
              style: GoogleFonts.rubik(fontSize: 11, color: AppColors.textMute),
            ),
          ],
        ),
        actions: [
          if ((tournament.currentRound ?? 0) > 0)
            Padding(
              padding: const EdgeInsets.only(right: 12),
              child: GestureDetector(
                onTap: () => Navigator.push(
                  context,
                  slideRoute(OrgRondasScreen(tournament: tournament)),
                ),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: AppColors.organizadorGradient,
                    ),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    'Gestionar Ronda ${tournament.currentRound}',
                    style: GoogleFonts.rubik(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: FirebaseFirestore.instance
            .collection('Tournaments')
            .doc(tournament.id)
            .collection('registration')
            .where('status', isEqualTo: 'Accepted')
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.cyan),
            );
          }

          final docs = snapshot.data?.docs ?? [];

          // Ordenar por puntos descendente en cliente
          final sorted = [...docs]
            ..sort((a, b) {
              final pa = (a.data()['points'] as num?)?.toInt() ?? 0;
              final pb = (b.data()['points'] as num?)?.toInt() ?? 0;
              return pb.compareTo(pa);
            });

          if (sorted.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text('🏆', style: TextStyle(fontSize: 48)),
                    const SizedBox(height: 12),
                    Text(
                      'Sin puntuaciones aún',
                      style: GoogleFonts.rubik(
                        fontSize: 15,
                        color: AppColors.textMute,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Los puntos aparecerán cuando se registren resultados de rondas',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.rubik(
                        fontSize: 12,
                        color: AppColors.textMute,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }

          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 14, 16, 4),
                child: Row(
                  children: [
                    Text(
                      '${sorted.length} jugador${sorted.length == 1 ? '' : 'es'}',
                      style: GoogleFonts.rubik(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textDim,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      '· en vivo',
                      style: GoogleFonts.rubik(
                        fontSize: 12,
                        color: AppColors.pink,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: ListView.separated(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 20),
                  itemCount: sorted.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 8),
                  itemBuilder: (context, i) {
                    final data = sorted[i].data();
                    final name = data['player_name'] as String? ?? 'Jugador';
                    final points = (data['points'] as num?)?.toInt() ?? 0;
                    return _RankingCard(
                      position: i + 1,
                      playerName: name,
                      points: points,
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _RankingCard extends StatelessWidget {
  final int position;
  final String playerName;
  final int points;
  const _RankingCard({
    required this.position,
    required this.playerName,
    required this.points,
  });

  Color get _borderColor => switch (position) {
    1 => const Color(0xFFFFD700),
    2 => const Color(0xFFC0C0C0),
    3 => const Color(0xFFCD7F32),
    _ => AppColors.stroke,
  };

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _borderColor.withValues(alpha: 0.4)),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 30,
            child: switch (position) {
              1 => const Text('🥇', style: TextStyle(fontSize: 18)),
              2 => const Text('🥈', style: TextStyle(fontSize: 18)),
              3 => const Text('🥉', style: TextStyle(fontSize: 18)),
              _ => Text(
                '$position',
                style: GoogleFonts.rubikMonoOne(
                  fontSize: 11,
                  color: AppColors.textMute,
                ),
              ),
            },
          ),
          const SizedBox(width: 10),
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: AppColors.clienteGradient,
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Center(
              child: Text(
                playerName.isNotEmpty ? playerName[0].toUpperCase() : '?',
                style: GoogleFonts.rubik(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              playerName,
              style: GoogleFonts.rubik(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.text,
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.cyan.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppColors.cyan.withValues(alpha: 0.3)),
            ),
            child: Text(
              '$points pts',
              style: GoogleFonts.rubik(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppColors.cyan,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
