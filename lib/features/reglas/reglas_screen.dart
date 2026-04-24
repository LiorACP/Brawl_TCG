import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:brawl_tcg/core/theme/app_colors.dart';
import 'package:brawl_tcg/core/widgets/brawl_widgets.dart';
import 'package:brawl_tcg/features/eventos/data/tournament.dart';
import 'data/game_rule.dart';
import 'viewmodels/reglas_viewmodel.dart';

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
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'BIBLIOTECA',
                              style: GoogleFonts.rubik(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textMute,
                                letterSpacing: 0.5,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'Juegos & Reglas',
                              style: GoogleFonts.rubik(
                                fontSize: 26,
                                fontWeight: FontWeight.w700,
                                color: AppColors.text,
                                letterSpacing: -0.5,
                              ),
                            ),
                          ],
                        ),
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: AppColors.surface,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: AppColors.stroke),
                          ),
                          child: const Icon(Icons.search, size: 18, color: Colors.white),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
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
                                    label: vm.alert.tag,
                                    color: AppColors.yellow,
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    vm.alert.title,
                                    style: GoogleFonts.rubik(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.text,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    vm.alert.subtitle,
                                    style: GoogleFonts.rubik(
                                        fontSize: 11, color: AppColors.textDim),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 4),
                  ],
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(22, 0, 22, 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SectionLabel('Juegos soportados'),
                      ...vm.games.map((g) => _GameRuleRow(rule: g)),
                      const SectionLabel('Recursos rápidos'),
                      LayoutBuilder(
                        builder: (context, constraints) {
                          final isWide = constraints.maxWidth >= 600;
                          return GridView.count(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            crossAxisCount: isWide ? 4 : 2,
                            mainAxisSpacing: isWide ? 8 : 10,
                            crossAxisSpacing: isWide ? 8 : 10,
                            childAspectRatio: isWide ? 2.0 : 1.5,
                            children: [
                              _ResourceTile(
                                title: 'Glosario',
                                sub: '248 términos',
                                color: AppColors.violet,
                                icon: 'A',
                                onTap: () {},
                              ),
                              _ResourceTile(
                                title: 'Árbitro FAQ',
                                sub: 'Situaciones comunes',
                                color: AppColors.cyan,
                                icon: '?',
                                onTap: () {},
                              ),
                              _ResourceTile(
                                title: 'Decklists',
                                sub: 'Meta actual',
                                color: AppColors.pink,
                                icon: '◈',
                                onTap: () {},
                              ),
                              _ResourceTile(
                                title: 'Eventos oficiales',
                                sub: 'Calendario IRL',
                                color: AppColors.orange,
                                icon: '★',
                                onTap: () {},
                              ),
                            ],
                          );
                        },
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

class _GameRuleRow extends StatelessWidget {
  final GameRule rule;
  const _GameRuleRow({required this.rule});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: BrawlCard(
        padding: const EdgeInsets.all(14),
        radius: 20,
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
                      if (rule.isNew)
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 1.5),
                          decoration: BoxDecoration(
                            color: AppColors.pink,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            'NUEVO',
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
                  Text(
                    'Reglas v.${rule.updated}',
                    style: GoogleFonts.rubik(
                        fontSize: 10.5, color: AppColors.textMute),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Text('›', style: TextStyle(fontSize: 18, color: AppColors.textMute)),
          ],
        ),
      ),
    );
  }
}

class _ResourceTile extends StatelessWidget {
  final String title, sub, icon;
  final Color color;
  final VoidCallback? onTap;
  const _ResourceTile({
    required this.title,
    required this.sub,
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
                    fontSize: 15, fontWeight: FontWeight.w700, color: color),
              ),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            title,
            style: GoogleFonts.rubik(
                fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.text),
          ),
          const SizedBox(height: 2),
          Text(
            sub,
            style: GoogleFonts.rubik(fontSize: 11, color: AppColors.textDim),
          ),
        ],
      ),
    );
  }
}
