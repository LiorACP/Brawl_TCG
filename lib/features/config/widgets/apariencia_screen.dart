import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:brawl_tcg/core/theme/app_colors.dart';
import 'package:brawl_tcg/core/widgets/brawl_widgets.dart';

class AparienciaScreen extends StatefulWidget {
  final String selected;
  final List<Color> accent;
  final void Function(String)? onSave;

  const AparienciaScreen({
    super.key,
    this.selected = 'dark',
    this.accent = AppColors.clienteGradient,
    this.onSave,
  });

  @override
  State<AparienciaScreen> createState() => _AparienciaScreenState();
}

class _AparienciaScreenState extends State<AparienciaScreen> {
  late String _selected;

  @override
  void initState() {
    super.initState();
    _selected = widget.selected;
  }

  void _pick(String value) {
    setState(() => _selected = value);
    widget.onSave?.call(value);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: BrawlBackground(
        seed: 18,
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(22, 18, 22, 20),
                child: Row(
                  children: [
                    const BackBtn(),
                    const SizedBox(width: 14),
                    Text('Apariencia',
                        style: GoogleFonts.rubik(
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                            color: AppColors.text)),
                  ],
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(22, 0, 22, 32),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(left: 4, bottom: 14),
                        child: Text(
                          'TEMA DE LA APLICACIÓN',
                          style: GoogleFonts.rubik(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textMute,
                              letterSpacing: 0.8),
                        ),
                      ),
                      Row(
                        children: [
                          Expanded(
                              child: _ThemeCard(
                            label: 'Oscuro',
                            icon: '🌙',
                            value: 'dark',
                            selected: _selected,
                            bgColor: const Color(0xFF1A1823),
                            cardColor: const Color(0xFF2D2A3D),
                            textColor: const Color(0xFFF2EEFF),
                            accent: widget.accent,
                            onTap: () => _pick('dark'),
                          )),
                          const SizedBox(width: 12),
                          Expanded(
                              child: _ThemeCard(
                            label: 'Claro',
                            icon: '☀️',
                            value: 'light',
                            selected: _selected,
                            bgColor: const Color(0xFFF5F4FF),
                            cardColor: Colors.white,
                            textColor: const Color(0xFF1A1823),
                            accent: widget.accent,
                            onTap: () => _pick('light'),
                          )),
                        ],
                      ),
                      const SizedBox(height: 20),
                      BrawlCard(
                        padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
                        radius: 14,
                        child: Row(
                          children: [
                            const Text('ℹ️', style: TextStyle(fontSize: 16)),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                'El modo claro está disponible pero la experiencia está optimizada para el modo oscuro.',
                                style: GoogleFonts.rubik(
                                    fontSize: 12, color: AppColors.textDim),
                              ),
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
        ),
      ),
    );
  }
}

class _ThemeCard extends StatelessWidget {
  final String label;
  final String icon;
  final String value;
  final String selected;
  final Color bgColor;
  final Color cardColor;
  final Color textColor;
  final List<Color> accent;
  final VoidCallback onTap;

  const _ThemeCard({
    required this.label,
    required this.icon,
    required this.value,
    required this.selected,
    required this.bgColor,
    required this.cardColor,
    required this.textColor,
    required this.accent,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isSelected = selected == value;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: isSelected ? accent.first : AppColors.stroke,
            width: isSelected ? 2 : 1,
          ),
          color: AppColors.surface,
        ),
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            Container(
              height: 110,
              decoration: BoxDecoration(
                color: bgColor,
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    height: 8,
                    width: 60,
                    decoration: BoxDecoration(
                      color: textColor.withValues(alpha: 0.9),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    height: 36,
                    decoration: BoxDecoration(
                      color: cardColor,
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  const Spacer(),
                  Row(
                    children: [
                      Container(
                        height: 22,
                        width: 22,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(6),
                          gradient: LinearGradient(colors: accent),
                        ),
                      ),
                      const SizedBox(width: 4),
                      Container(
                        height: 6,
                        width: 30,
                        decoration: BoxDecoration(
                          color: textColor.withValues(alpha: 0.4),
                          borderRadius: BorderRadius.circular(3),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(icon, style: const TextStyle(fontSize: 14)),
                const SizedBox(width: 6),
                Text(label,
                    style: GoogleFonts.rubik(
                        fontSize: 13,
                        fontWeight:
                            isSelected ? FontWeight.w700 : FontWeight.w500,
                        color: isSelected ? AppColors.text : AppColors.textDim)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
