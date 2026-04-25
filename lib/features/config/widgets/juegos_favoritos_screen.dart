import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:brawl_tcg/core/theme/app_colors.dart';
import 'package:brawl_tcg/core/widgets/brawl_widgets.dart';
import 'config_field.dart';

class JuegosFavoritosScreen extends StatefulWidget {
  final Set<String> selected;
  final List<Color> accent;
  final void Function(Set<String>)? onSave;

  const JuegosFavoritosScreen({
    super.key,
    this.selected = const {},
    this.accent = AppColors.clienteGradient,
    this.onSave,
  });

  @override
  State<JuegosFavoritosScreen> createState() => _JuegosFavoritosScreenState();
}

class _JuegosFavoritosScreenState extends State<JuegosFavoritosScreen> {
  late Set<String> _selected;

  static const _juegos = [
    ('MTG', 'Magic: The Gathering'),
    ('POK', 'Pokémon TCG'),
    ('YGO', 'Yu-Gi-Oh!'),
    ('LRC', 'Lorcana'),
    ('FAB', 'Flesh & Blood'),
    ('ONE', 'One Piece TCG'),
    ('DBS', 'Dragon Ball Super'),
  ];

  @override
  void initState() {
    super.initState();
    _selected = Set.from(widget.selected);
  }

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
                padding: const EdgeInsets.fromLTRB(22, 18, 22, 20),
                child: Row(
                  children: [
                    const BackBtn(),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Text('Mis juegos favoritos',
                          style: GoogleFonts.rubik(
                              fontSize: 20,
                              fontWeight: FontWeight.w700,
                              color: AppColors.text)),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(22, 0, 22, 32),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const ConfigSectionHeader('Selecciona tus juegos'),
                      ...List.generate(_juegos.length, (i) {
                        final (code, name) = _juegos[i];
                        final isSelected = _selected.contains(code);
                        final colors = AppColors.gameBadgePalettes[code] ??
                            AppColors.clienteGradient;
                        return GestureDetector(
                          onTap: () => setState(() {
                            if (isSelected) {
                              _selected.remove(code);
                            } else {
                              _selected.add(code);
                            }
                          }),
                          child: Container(
                            margin: const EdgeInsets.only(bottom: 10),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? colors.first.withValues(alpha: 0.10)
                                  : AppColors.surface,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: isSelected
                                    ? colors.first.withValues(alpha: 0.40)
                                    : AppColors.stroke,
                                width: isSelected ? 1.5 : 1,
                              ),
                            ),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 14, vertical: 13),
                            child: Row(
                              children: [
                                GameBadge(game: code, size: 38),
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
                                      Text(code,
                                          style: GoogleFonts.rubik(
                                              fontSize: 11,
                                              color: AppColors.textMute)),
                                    ],
                                  ),
                                ),
                                AnimatedContainer(
                                  duration: const Duration(milliseconds: 180),
                                  width: 22,
                                  height: 22,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    gradient: isSelected
                                        ? LinearGradient(colors: colors)
                                        : null,
                                    border: Border.all(
                                      color: isSelected
                                          ? Colors.transparent
                                          : AppColors.stroke,
                                      width: 1.5,
                                    ),
                                  ),
                                  child: isSelected
                                      ? const Icon(Icons.check,
                                          size: 13, color: Colors.white)
                                      : null,
                                ),
                              ],
                            ),
                          ),
                        );
                      }),
                      const SizedBox(height: 22),
                      GradBtn(
                        width: double.infinity,
                        size: GradBtnSize.lg,
                        gradient: widget.accent,
                        onTap: () {
                          widget.onSave?.call(_selected);
                          Navigator.pop(context);
                        },
                        child: Text('Guardar (${_selected.length} juegos)'),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
