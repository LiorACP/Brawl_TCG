import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:brawl_tcg/core/theme/app_colors.dart';
import 'package:brawl_tcg/core/widgets/brawl_widgets.dart';
import 'package:brawl_tcg/core/navigation/transitions.dart';
import 'package:brawl_tcg/features/premios/org_premios_screen.dart';

class OrgCrearScreen extends StatefulWidget {
  const OrgCrearScreen({super.key});

  @override
  State<OrgCrearScreen> createState() => _OrgCrearScreenState();
}

class _OrgCrearScreenState extends State<OrgCrearScreen> {
  int _selectedGame = 0;
  int _selectedFormat = 0;
  int _plazas = 32;

  final _games = const [
    ('MTG', 'Magic'),
    ('POK', 'Pokémon'),
    ('YGO', 'YuGiOh'),
    ('LOR', 'Runeterra'),
    ('ONE', 'One Piece'),
    ('DBS', 'Dragon Ball'),
  ];

  final _formats = const [
    ('Pioneer', 'Swiss · 5 rondas · Top 8'),
    ('Modern', 'Swiss · 4 rondas'),
    ('Commander', 'Mesas de 4 · 3 rondas'),
    ('Draft', 'Pods de 8 · sellado'),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: BrawlBackground(
        seed: 33,
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(22, 18, 22, 0),
                child: Column(
                  children: [
                    Row(
                      children: [
                        const BackBtn(),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('NUEVO TORNEO',
                                  style: GoogleFonts.rubik(
                                      fontSize: 11,
                                      color: AppColors.textMute,
                                      letterSpacing: 0.5)),
                              Text('Paso 2 de 4 · Formato',
                                  style: GoogleFonts.rubik(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.text)),
                            ],
                          ),
                        ),
                        GestureDetector(
                          onTap: () => ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Borrador guardado')),
                          ),
                          child: Text('Guardar',
                              style: GoogleFonts.rubik(fontSize: 12, color: AppColors.textDim)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 18),
                    Row(
                      children: List.generate(
                          4,
                          (i) => Expanded(
                                child: Padding(
                                  padding: EdgeInsets.only(right: i < 3 ? 6 : 0),
                                  child: Container(
                                    height: 4,
                                    decoration: BoxDecoration(
                                      gradient: i < 2
                                          ? const LinearGradient(
                                              colors: AppColors.organizadorGradient)
                                          : null,
                                      color: i >= 2 ? AppColors.surfaceHi : null,
                                      borderRadius: BorderRadius.circular(2),
                                    ),
                                  ),
                                ),
                              )),
                    ),
                    const SizedBox(height: 22),
                  ],
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(22, 0, 22, 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      BrawlCard(
                        radius: 22,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('NOMBRE',
                                style: GoogleFonts.rubik(
                                    fontSize: 11,
                                    color: AppColors.textMute,
                                    fontWeight: FontWeight.w600,
                                    letterSpacing: 0.5)),
                            const SizedBox(height: 6),
                            Text('Pioneer FNM — Mayo',
                                style: GoogleFonts.rubik(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.text)),
                            const SizedBox(height: 4),
                            Text('32 caracteres · público',
                                style: GoogleFonts.rubik(fontSize: 12, color: AppColors.textDim)),
                          ],
                        ),
                      ),
                      const SectionLabel('Juego',
                          margin: EdgeInsets.only(left: 4, top: 14, bottom: 10)),
                      GridView.count(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        crossAxisCount: 3,
                        mainAxisSpacing: 8,
                        crossAxisSpacing: 8,
                        childAspectRatio: 1.0,
                        children: List.generate(_games.length, (i) {
                          final (code, name) = _games[i];
                          final active = i == _selectedGame;
                          return GestureDetector(
                            onTap: () => setState(() => _selectedGame = i),
                            child: BrawlCard(
                              padding: const EdgeInsets.all(12),
                              radius: 18,
                              tint: active
                                  ? AppColors.violet.withValues(alpha: 0.18)
                                  : AppColors.surface,
                              border: active
                                  ? AppColors.violet.withValues(alpha: 0.5)
                                  : AppColors.stroke,
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  GameBadge(game: code, size: 32),
                                  const SizedBox(height: 8),
                                  Text(name,
                                      style: GoogleFonts.rubik(
                                          fontSize: 11.5,
                                          fontWeight: FontWeight.w600,
                                          color: AppColors.text),
                                      textAlign: TextAlign.center),
                                ],
                              ),
                            ),
                          );
                        }),
                      ),
                      const SectionLabel('Formato',
                          margin: EdgeInsets.only(left: 4, top: 14, bottom: 10)),
                      ...List.generate(_formats.length, (i) {
                        final (name, desc) = _formats[i];
                        final active = i == _selectedFormat;
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: GestureDetector(
                            onTap: () => setState(() => _selectedFormat = i),
                            child: BrawlCard(
                              padding: const EdgeInsets.all(14),
                              radius: 18,
                              tint: active
                                  ? AppColors.violet.withValues(alpha: 0.12)
                                  : AppColors.surface,
                              border: active
                                  ? AppColors.violet.withValues(alpha: 0.4)
                                  : AppColors.stroke,
                              child: Row(
                                children: [
                                  Container(
                                    width: 22,
                                    height: 22,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      gradient: active
                                          ? const LinearGradient(
                                              colors: AppColors.organizadorGradient)
                                          : null,
                                      border: active
                                          ? null
                                          : Border.all(color: AppColors.strokeHi, width: 2),
                                    ),
                                    child: active
                                        ? const Center(
                                            child: CircleAvatar(
                                                radius: 4, backgroundColor: Colors.white))
                                        : null,
                                  ),
                                  const SizedBox(width: 14),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(name,
                                            style: GoogleFonts.rubik(
                                                fontSize: 14,
                                                fontWeight: FontWeight.w600,
                                                color: AppColors.text)),
                                        const SizedBox(height: 2),
                                        Text(desc,
                                            style: GoogleFonts.rubik(
                                                fontSize: 11.5, color: AppColors.textDim)),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      }),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: BrawlCard(
                              padding: const EdgeInsets.all(14),
                              radius: 18,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('PLAZAS',
                                      style: GoogleFonts.rubik(
                                          fontSize: 11,
                                          color: AppColors.textMute,
                                          fontWeight: FontWeight.w600,
                                          letterSpacing: 0.4)),
                                  const SizedBox(height: 10),
                                  Row(
                                    children: [
                                      GestureDetector(
                                        onTap: () => setState(
                                            () => _plazas = (_plazas - 1).clamp(4, 512)),
                                        child: Container(
                                          width: 28,
                                          height: 28,
                                          decoration: BoxDecoration(
                                            color: AppColors.surfaceHi,
                                            borderRadius: BorderRadius.circular(10),
                                          ),
                                          child: Center(
                                              child: Text('−',
                                                  style: TextStyle(
                                                      fontSize: 18,
                                                      color: AppColors.textDim))),
                                        ),
                                      ),
                                      Expanded(
                                        child: Center(
                                          child: Text('$_plazas',
                                              style: GoogleFonts.rubikMonoOne(
                                                  fontSize: 22, color: AppColors.text)),
                                        ),
                                      ),
                                      GestureDetector(
                                        onTap: () => setState(
                                            () => _plazas = (_plazas + 1).clamp(4, 512)),
                                        child: Container(
                                          width: 28,
                                          height: 28,
                                          decoration: BoxDecoration(
                                            gradient: const LinearGradient(
                                                colors: AppColors.organizadorGradient),
                                            borderRadius: BorderRadius.circular(10),
                                          ),
                                          child: const Center(
                                              child: Text('＋',
                                                  style: TextStyle(
                                                      fontSize: 18, color: Colors.white))),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: BrawlCard(
                              padding: const EdgeInsets.all(14),
                              radius: 18,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('INSCRIPCIÓN',
                                      style: GoogleFonts.rubik(
                                          fontSize: 11,
                                          color: AppColors.textMute,
                                          fontWeight: FontWeight.w600,
                                          letterSpacing: 0.4)),
                                  const SizedBox(height: 10),
                                  RichText(
                                    text: TextSpan(
                                      children: [
                                        TextSpan(
                                          text: '€ 8',
                                          style: GoogleFonts.rubikMonoOne(
                                              fontSize: 22, color: AppColors.text),
                                        ),
                                        TextSpan(
                                          text: ',00',
                                          style: GoogleFonts.rubik(
                                              fontSize: 13, color: AppColors.textMute),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 80),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(22, 0, 22, 20),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Container(
                        height: 50,
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: BorderRadius.circular(999),
                          border: Border.all(color: AppColors.stroke),
                        ),
                        child: Center(
                          child: Text('Atrás',
                              style: GoogleFonts.rubik(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.text)),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: GradBtn(
                        size: GradBtnSize.lg,
                        gradient: AppColors.organizadorGradient,
                        width: double.infinity,
                        onTap: () =>
                            Navigator.push(context, fadeSlideRoute(const OrgPremiosScreen())),
                        child: const Text('Siguiente · Premios →'),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
