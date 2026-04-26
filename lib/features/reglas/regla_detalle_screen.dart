import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:brawl_tcg/core/theme/app_colors.dart';
import 'package:brawl_tcg/core/widgets/brawl_widgets.dart';
import 'package:brawl_tcg/features/eventos/data/tournament.dart';
import 'data/regla_firestore.dart';
import 'services/reglas_service.dart';

class ReglaDetalleScreen extends StatefulWidget {
  final TcgGame game;

  const ReglaDetalleScreen({super.key, required this.game});

  @override
  State<ReglaDetalleScreen> createState() => _ReglaDetalleScreenState();
}

class _ReglaDetalleScreenState extends State<ReglaDetalleScreen> {
  String? _selectedCategory;

  @override
  Widget build(BuildContext context) {
    final gameId = widget.game.firestoreId;

    return Scaffold(
      backgroundColor: AppColors.bg,
      body: BrawlBackground(
        seed: 42,
        child: SafeArea(
          child: Column(
            children: [
              // Cabecera con botón de volver y badge del juego
              Padding(
                padding: const EdgeInsets.fromLTRB(22, 18, 22, 0),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppColors.stroke),
                        ),
                        child: const Icon(Icons.arrow_back_ios_new,
                            size: 16, color: Colors.white),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'REGLAMENTO',
                          style: GoogleFonts.rubik(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textMute,
                            letterSpacing: 0.5,
                          ),
                        ),
                        Text(
                          widget.game.fullName,
                          style: GoogleFonts.rubik(
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                            color: AppColors.text,
                            letterSpacing: -0.3,
                          ),
                        ),
                      ],
                    ),
                    const Spacer(),
                    GameBadge(game: widget.game.code, size: 40),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Chips horizontales para filtrar por categoría
              StreamBuilder<List<String>>(
                stream: ReglasService.watchCategories(gameId),
                builder: (context, snap) {
                  if (!snap.hasData || snap.data!.isEmpty) {
                    return const SizedBox.shrink();
                  }
                  final cats = ['Todas', ...snap.data!];
                  return SizedBox(
                    height: 34,
                    child: ListView.separated(
                      padding: const EdgeInsets.symmetric(horizontal: 22),
                      scrollDirection: Axis.horizontal,
                      itemCount: cats.length,
                      separatorBuilder: (_, __) => const SizedBox(width: 8),
                      itemBuilder: (context, i) {
                        final cat = cats[i];
                        final isAll = cat == 'Todas';
                        final selected = isAll
                            ? _selectedCategory == null
                            : _selectedCategory == cat;
                        return GestureDetector(
                          onTap: () => setState(
                            () => _selectedCategory = isAll ? null : cat,
                          ),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 14, vertical: 6),
                            decoration: BoxDecoration(
                              color: selected
                                  ? AppColors.violet
                                  : AppColors.surface,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: selected
                                    ? AppColors.violet
                                    : AppColors.stroke,
                              ),
                            ),
                            child: Text(
                              cat,
                              style: GoogleFonts.rubik(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: selected
                                    ? Colors.white
                                    : AppColors.textDim,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  );
                },
              ),
              const SizedBox(height: 12),

              // Lista de reglas del juego
              Expanded(
                child: StreamBuilder<List<ReglaFirestore>>(
                  stream: ReglasService.watchRules(
                    gameId,
                    category: _selectedCategory,
                  ),
                  builder: (context, snap) {
                    if (snap.connectionState == ConnectionState.waiting) {
                      return const Center(
                        child: CircularProgressIndicator(
                          color: AppColors.violet,
                          strokeWidth: 2,
                        ),
                      );
                    }

                    if (snap.hasError) {
                      return Center(
                        child: Text(
                          'Error: ${snap.error}',
                          style: GoogleFonts.rubik(color: AppColors.textDim),
                        ),
                      );
                    }

                    final rules = snap.data ?? [];

                    if (rules.isEmpty) {
                      return Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text('📚',
                                style: const TextStyle(fontSize: 40)),
                            const SizedBox(height: 12),
                            Text(
                              'Sin reglas disponibles',
                              style: GoogleFonts.rubik(
                                  fontSize: 15,
                                  color: AppColors.textDim,
                                  fontWeight: FontWeight.w600),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Ejecuta la ingesta desde la API para poblar los datos',
                              textAlign: TextAlign.center,
                              style: GoogleFonts.rubik(
                                  fontSize: 12, color: AppColors.textMute),
                            ),
                          ],
                        ),
                      );
                    }

                    return ListView.builder(
                      padding: const EdgeInsets.fromLTRB(22, 0, 22, 20),
                      itemCount: rules.length,
                      itemBuilder: (context, i) =>
                          _ReglaRow(regla: rules[i]),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Tarjeta de cada regla con el mismo estilo que el resto de la app

class _ReglaRow extends StatelessWidget {
  final ReglaFirestore regla;
  const _ReglaRow({required this.regla});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: BrawlCard(
        padding: const EdgeInsets.all(14),
        radius: 20,
        onTap: () => _showDetail(context),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Badge de categoría
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: AppColors.violet.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                    color: AppColors.violet.withValues(alpha: 0.25)),
              ),
              child: Center(
                child: Text(
                  regla.category.isEmpty ? '?' : regla.category[0].toUpperCase(),
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: AppColors.violet,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          regla.title,
                          style: GoogleFonts.rubik(
                            fontSize: 13.5,
                            fontWeight: FontWeight.w700,
                            color: AppColors.text,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    regla.category,
                    style: GoogleFonts.rubik(
                        fontSize: 11, color: AppColors.textDim),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    regla.body,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.rubik(
                        fontSize: 11, color: AppColors.textMute),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Text('›',
                style: TextStyle(fontSize: 18, color: AppColors.textMute)),
          ],
        ),
      ),
    );
  }

  void _showDetail(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _ReglaSheet(regla: regla),
    );
  }
}

// Panel que se desliza desde abajo con el texto completo de la regla

class _ReglaSheet extends StatelessWidget {
  final ReglaFirestore regla;
  const _ReglaSheet({required this.regla});

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.6,
      maxChildSize: 0.92,
      minChildSize: 0.4,
      builder: (_, controller) => Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
          border: Border.all(color: AppColors.stroke),
        ),
        child: Column(
          children: [
            const SizedBox(height: 10),
            Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.stroke,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Expanded(
              child: ListView(
                controller: controller,
                padding: const EdgeInsets.fromLTRB(22, 16, 22, 32),
                children: [
                  BrawlTag(label: regla.category, color: AppColors.violet),
                  const SizedBox(height: 10),
                  Text(
                    regla.title,
                    style: GoogleFonts.rubik(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: AppColors.text,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'v.${regla.version}',
                    style: GoogleFonts.rubik(
                        fontSize: 11, color: AppColors.textMute),
                  ),
                  const SizedBox(height: 14),
                  Text(
                    regla.body,
                    style: GoogleFonts.rubik(
                      fontSize: 13.5,
                      color: AppColors.textDim,
                      height: 1.6,
                    ),
                  ),
                  if (regla.examples.isNotEmpty) ...[
                    const SizedBox(height: 16),
                    BrawlCard(
                      padding: const EdgeInsets.all(14),
                      radius: 16,
                      tint: const Color(0xFF0F0C1A),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Ejemplo',
                            style: GoogleFonts.rubik(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: AppColors.yellow,
                              letterSpacing: 0.4,
                            ),
                          ),
                          const SizedBox(height: 6),
                          ...regla.examples.map(
                            (e) => Padding(
                              padding: const EdgeInsets.only(top: 4),
                              child: Text(
                                e,
                                style: GoogleFonts.rubik(
                                  fontSize: 12.5,
                                  color: AppColors.textDim,
                                  height: 1.5,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

