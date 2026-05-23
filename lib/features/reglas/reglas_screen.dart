import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:brawl_tcg/core/l10n/app_l10n.dart';
import 'package:brawl_tcg/core/theme/app_colors.dart';
import 'package:brawl_tcg/core/widgets/brawl_widgets.dart';
import 'package:brawl_tcg/features/eventos/data/tournament.dart';
import 'data/game_rule.dart';
import 'data/regla_firestore.dart';
import 'services/reglas_service.dart';
import 'viewmodels/reglas_viewmodel.dart';
import 'widgets/eventos_oficiales_sheet.dart';
import 'regla_detalle_screen.dart';

class SharedReglasScreen extends StatelessWidget {
  const SharedReglasScreen({super.key});

  @override
  Widget build(BuildContext context) {
    const vm = ReglasViewModel.mock;

    return Scaffold(
      backgroundColor: AppColors.bg,
      body: BrawlBackground(
        seed: 61,
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(22, 18, 22, 0),
                child: Column(
                  children: [
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            L10n.t('BIBLIOTECA'),
                            style: GoogleFonts.rubik(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textMute,
                              letterSpacing: 0.5,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            L10n.t('Juegos & Reglas'),
                            style: GoogleFonts.rubik(
                              fontSize: 26,
                              fontWeight: FontWeight.w700,
                              color: AppColors.text,
                              letterSpacing: -0.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    StreamBuilder<GameMeta?>(
                      stream: ReglasService.watchLatestUpdate(),
                      builder: (context, snap) {
                        final meta = snap.data;
                        if (meta == null) return const SizedBox.shrink();

                        final game = TcgGameFirestoreId.fromFirestoreId(meta.gameId);
                        final gameName = game?.fullName ?? meta.gameId;
                        final dateLabel = _shortDate(meta.lastUpdated!);

                        return Column(
                          children: [
                            BrawlCard(
                              padding: EdgeInsets.zero,
                              radius: 22,
                              tint: const Color(0xFF0F0C1A),
                              border: Colors.transparent,
                              child: SizedBox(
                                height: 110,
                                child: Stack(
                                  children: [
                                    Positioned(
                                      top: -30,
                                      right: -40,
                                      child: Container(
                                        width: 200,
                                        height: 200,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          gradient: RadialGradient(
                                            colors: [
                                              AppColors.orange.withValues(alpha: 0.5),
                                              AppColors.pink.withValues(alpha: 0.3),
                                              Colors.transparent,
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                    Positioned(
                                      bottom: 12,
                                      left: 16,
                                      right: 16,
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          BrawlTag(
                                            label: '⚡ Actualizado · $dateLabel',
                                            color: AppColors.yellow,
                                          ),
                                          const SizedBox(height: 8),
                                          Text(
                                            'Reglas actualizadas · $gameName',
                                            style: GoogleFonts.rubik(
                                              fontSize: 16,
                                              fontWeight: FontWeight.w700,
                                              color: AppColors.text,
                                            ),
                                          ),
                                          const SizedBox(height: 2),
                                          Text(
                                            '${meta.rulesCount} reglas · v.${meta.version}',
                                            style: GoogleFonts.rubik(
                                                fontSize: 11,
                                                color: AppColors.textDim),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(height: 12),
                          ],
                        );
                      },
                    ),
                  ],
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(22, 4, 22, 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SectionLabel(L10n.t('Juegos soportados'),
                          margin: const EdgeInsets.only(left: 4, bottom: 10)),

                      // Aquí cada fila lee su versión en tiempo real desde Firestore
                      ...vm.games.map((g) => _GameRuleRowFirestore(rule: g)),

                      SectionLabel(L10n.t('Recursos rápidos'),
                          margin: const EdgeInsets.only(left: 4, top: 6, bottom: 10)),
                      _ResourceTile(
                        title: L10n.t('Eventos oficiales'),
                        color: AppColors.orange,
                        icon: '★',
                        onTap: () => showEventosOficialesSheet(context),
                      ),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
              const BrawlNavBarSpacer(),
            ],
          ),
        ),
      ),
    );
  }
}

// Fila de juego que muestra la versión actualizada desde Firestore
//
// Mantiene exactamente el mismo layout que _GameRuleRow.
// Usa StreamBuilder solo para sustituir el campo "versión".
// Al tocar navega a ReglaDetalleScreen pasando el TcgGame.

class _GameRuleRowFirestore extends StatelessWidget {
  final GameRule rule;
  const _GameRuleRowFirestore({required this.rule});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: StreamBuilder<GameMeta>(
        stream: ReglasService.watchGameMeta(rule.game.firestoreId),
        builder: (context, snap) {
          // Mientras carga usa la versión del viewmodel como fallback
          final version = snap.data?.version ?? rule.updated;
          final isUpdated = snap.data?.lastUpdated != null;

          return BrawlCard(
            padding: const EdgeInsets.all(14),
            radius: 20,
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => ReglaDetalleScreen(game: rule.game),
              ),
            ),
            child: Row(
              children: [
                GameBadge(game: rule.game.code, size: 44),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              rule.game.fullName,
                              style: GoogleFonts.rubik(
                                  fontSize: 14.5,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.text),
                            ),
                          ),
                          if (isUpdated)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 6, vertical: 1.5),
                              decoration: BoxDecoration(
                                color: AppColors.pink,
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                L10n.t('NUEVO'),
                                style: GoogleFonts.rubik(
                                    fontSize: 9,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.white,
                                    letterSpacing: 0.4),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(
                        rule.formats,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.rubik(
                            fontSize: 11.5, color: AppColors.textDim),
                      ),
                      const SizedBox(height: 3),
                      // ← versión desde Firestore (fallback al mock mientras carga)
                      Text(
                        L10n.fmt('Reglas v.{v}', {'v': version}),
                        style: GoogleFonts.rubik(
                            fontSize: 10.5, color: AppColors.textMute),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Text('›',
                    style:
                        TextStyle(fontSize: 18, color: AppColors.textMute)),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _ResourceTile extends StatelessWidget {
  final String title, icon;
  final Color color;
  final VoidCallback? onTap;
  const _ResourceTile({
    required this.title,
    required this.icon,
    required this.color,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return BrawlCard(
      onTap: onTap,
      padding: const EdgeInsets.all(14),
      radius: 18,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: color.withValues(alpha: 0.2)),
            ),
            child: Center(
              child: Text(
                icon,
                style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: color),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            title,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.rubik(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppColors.text),
          ),
        ],
      ),
    );
  }
}

String _shortDate(DateTime d) {
  const months = [
    'Ene', 'Feb', 'Mar', 'Abr', 'May', 'Jun',
    'Jul', 'Ago', 'Sep', 'Oct', 'Nov', 'Dic',
  ];
  return '${d.day} ${months[d.month - 1]}';
}
