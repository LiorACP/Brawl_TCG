import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:brawl_tcg/core/theme/app_colors.dart';
import 'package:brawl_tcg/core/widgets/brawl_widgets.dart';
import 'package:brawl_tcg/core/navigation/transitions.dart';
import 'package:brawl_tcg/features/premios/org_premios_screen.dart';
import 'data/tournament.dart';

class _FormatOption {
  final String name;
  final String description;
  const _FormatOption(this.name, this.description);
}

class OrgCrearScreen extends StatefulWidget {
  const OrgCrearScreen({super.key});

  @override
  State<OrgCrearScreen> createState() => _OrgCrearScreenState();
}

class _OrgCrearScreenState extends State<OrgCrearScreen> {
  TcgGame _selectedGame = TcgGame.mtg;
  int _selectedFormat = 0;
  int _plazas = 32;

  static const _games = [
    TcgGame.mtg,
    TcgGame.pok,
    TcgGame.ygo,
    TcgGame.fab,
    TcgGame.one,
    TcgGame.lor,
  ];

  static const _formatsByGame = <TcgGame, List<_FormatOption>>{
    TcgGame.mtg: [
      _FormatOption('Standard', 'Swiss · rotativo'),
      _FormatOption('Pioneer', 'Swiss · 5 rondas · Top 8'),
      _FormatOption('Modern', 'Swiss · 4 rondas'),
      _FormatOption('Legacy', 'Swiss · eternal'),
      _FormatOption('Vintage', 'Swiss · eternal irrestricto'),
      _FormatOption('Pauper', 'Solo comunes'),
      _FormatOption('Commander', 'Mesas de 4 · 3 rondas'),
      _FormatOption('Brawl', 'Mesas de 4 · estándar'),
      _FormatOption('Historic', 'Swiss · digital'),
      _FormatOption('Draft', 'Pods de 8 · sellado'),
      _FormatOption('Sealed', '6 sobres · construcción'),
      _FormatOption('Two-Headed Giant', 'Parejas · 2v2'),
    ],
    TcgGame.pok: [
      _FormatOption('Standard', 'Swiss · rotativo'),
      _FormatOption('Expanded', 'Swiss · B&W en adelante'),
      _FormatOption('Unlimited', 'Swiss · sin restricciones'),
      _FormatOption('Draft', 'Pods de 8 · sellado'),
      _FormatOption('Sealed', '6 sobres · construcción'),
      _FormatOption('Theme Deck', 'Mazos predefinidos'),
      _FormatOption('Gym Leader Challenge', '60 cartas · sin repetidos'),
    ],
    TcgGame.ygo: [
      _FormatOption('Advanced', 'Swiss · ban list vigente'),
      _FormatOption('Traditional', 'Swiss · sin ban list'),
      _FormatOption('Speed Duel', 'Formato reducido oficial'),
      _FormatOption('Rush Duel', 'Formato Rush'),
      _FormatOption('Draft', 'Pods de 8 · sellado'),
      _FormatOption('Sealed', '6 sobres · construcción'),
      _FormatOption('Goat', 'Swiss · formato 2005'),
      _FormatOption('Edison', 'Swiss · formato 2010'),
      _FormatOption('Tag Duel', 'Parejas · 2v2'),
    ],
    TcgGame.fab: [
      _FormatOption('Classic Constructed', 'Swiss · formato principal'),
      _FormatOption('Blitz', 'Swiss · partidas rápidas'),
      _FormatOption('Living Legend', 'Swiss · héroes retirados'),
      _FormatOption('Draft', 'Pods de 8 · sellado'),
      _FormatOption('Sealed', '6 sobres · construcción'),
      _FormatOption('UPF', 'Multijugador · último en pie'),
      _FormatOption('Commoner', 'Solo comunes'),
      _FormatOption('Clash', 'Formato casual'),
    ],
    TcgGame.one: [
      _FormatOption('Constructed', 'Swiss · formato principal'),
      _FormatOption('Block', 'Swiss · por saga'),
      _FormatOption('Sealed Battle', '6 sobres · construcción'),
      _FormatOption('Buddy Battle', 'Parejas · 2v2'),
    ],
    TcgGame.lor: [
      _FormatOption('Core Constructed', 'Swiss · formato principal'),
      _FormatOption('Infinity', 'Swiss · sin restricciones'),
      _FormatOption('Sealed', '6 sobres · construcción'),
      _FormatOption('Draft', 'Pods de 8 · sellado'),
      _FormatOption('Multiplayer', 'Mesas de 4 o más'),
      _FormatOption('Pack Rush', 'Apertura competitiva'),
    ],
  };

  List<_FormatOption> get _formats =>
      _formatsByGame[_selectedGame] ?? [];

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
                              style: GoogleFonts.rubik(
                                  fontSize: 12, color: AppColors.textDim)),
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
                                style: GoogleFonts.rubik(
                                    fontSize: 12, color: AppColors.textDim)),
                          ],
                        ),
                      ),
                      const SectionLabel('Juego',
                          margin: EdgeInsets.only(left: 4, top: 14, bottom: 10)),
                      GridView.count(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        crossAxisCount: 3,
                        mainAxisSpacing: 6,
                        crossAxisSpacing: 6,
                        childAspectRatio: 1.5,
                        children: _games.map((game) {
                          final active = game == _selectedGame;
                          return GestureDetector(
                            onTap: () => setState(() {
                              _selectedGame = game;
                              _selectedFormat = 0;
                            }),
                            child: BrawlCard(
                              padding: const EdgeInsets.all(8),
                              radius: 14,
                              tint: active
                                  ? AppColors.violet.withValues(alpha: 0.18)
                                  : AppColors.surface,
                              border: active
                                  ? AppColors.violet.withValues(alpha: 0.5)
                                  : AppColors.stroke,
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  GameBadge(game: game.code, size: 22),
                                  const SizedBox(height: 5),
                                  Text(
                                    game.shortName,
                                    style: GoogleFonts.rubik(
                                        fontSize: 10,
                                        fontWeight: FontWeight.w600,
                                        color: AppColors.text),
                                    textAlign: TextAlign.center,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                      const SectionLabel('Formato',
                          margin: EdgeInsets.only(left: 4, top: 14, bottom: 10)),
                      ...List.generate(_formats.length, (i) {
                        final fmt = _formats[i];
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
                                          : Border.all(
                                              color: AppColors.strokeHi, width: 2),
                                    ),
                                    child: active
                                        ? const Center(
                                            child: CircleAvatar(
                                                radius: 4,
                                                backgroundColor: Colors.white))
                                        : null,
                                  ),
                                  const SizedBox(width: 14),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(fmt.name,
                                            style: GoogleFonts.rubik(
                                                fontSize: 14,
                                                fontWeight: FontWeight.w600,
                                                color: AppColors.text)),
                                        const SizedBox(height: 2),
                                        Text(fmt.description,
                                            style: GoogleFonts.rubik(
                                                fontSize: 11.5,
                                                color: AppColors.textDim)),
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
                                                  fontSize: 22,
                                                  color: AppColors.text)),
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
                                                      fontSize: 18,
                                                      color: Colors.white))),
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
                                              fontSize: 13,
                                              color: AppColors.textMute),
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
                        onTap: () => Navigator.push(
                            context, fadeSlideRoute(const OrgPremiosScreen())),
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
