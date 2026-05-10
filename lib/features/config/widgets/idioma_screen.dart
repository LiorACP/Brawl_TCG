import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:brawl_tcg/core/l10n/app_l10n.dart';
import 'package:brawl_tcg/core/theme/app_colors.dart';
import 'package:brawl_tcg/core/widgets/brawl_widgets.dart';

class IdiomaScreen extends StatefulWidget {
  final String selected;
  final List<Color> accent;
  final void Function(String)? onSave;

  const IdiomaScreen({
    super.key,
    this.selected = 'es',
    this.accent = AppColors.clienteGradient,
    this.onSave,
  });

  @override
  State<IdiomaScreen> createState() => _IdiomaScreenState();
}

class _IdiomaScreenState extends State<IdiomaScreen> {
  late String _selected;

  static const _idiomas = [
    ('es', '🇪🇸', 'Español', 'España'),
    ('en', '🇬🇧', 'English', 'United Kingdom'),
  ];

  // La pantalla de idioma siempre muestra ambas opciones en su idioma nativo,
  // pero el título sí se traduce.
  String get _title => L10n.t('Idioma');
  String get _sectionLabel => L10n.t('SELECCIONA UN IDIOMA');

  @override
  void initState() {
    super.initState();
    _selected = widget.selected;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: BrawlBackground(
        seed: 27,
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(22, 18, 22, 20),
                child: Row(
                  children: [
                    const BackBtn(),
                    const SizedBox(width: 14),
                    Text(_title,
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
                        padding: const EdgeInsets.only(left: 4, bottom: 10),
                        child: Text(
                          _sectionLabel,
                          style: GoogleFonts.rubik(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textMute,
                              letterSpacing: 0.8),
                        ),
                      ),
                      BrawlCard(
                        padding: EdgeInsets.zero,
                        radius: 18,
                        child: Column(
                          children: List.generate(_idiomas.length, (i) {
                            final (code, flag, name, region) = _idiomas[i];
                            final isSelected = _selected == code;
                            return GestureDetector(
                              onTap: () {
                                setState(() => _selected = code);
                                widget.onSave?.call(code);
                                Navigator.pop(context);
                              },
                              child: Container(
                                decoration: BoxDecoration(
                                  border: i < _idiomas.length - 1
                                      ? Border(
                                          bottom: BorderSide(color: AppColors.stroke))
                                      : null,
                                ),
                                child: Padding(
                                  padding:
                                      const EdgeInsets.fromLTRB(14, 14, 14, 14),
                                  child: Row(
                                    children: [
                                      Text(flag,
                                          style: const TextStyle(fontSize: 28)),
                                      const SizedBox(width: 14),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(name,
                                                style: GoogleFonts.rubik(
                                                    fontSize: 14,
                                                    fontWeight: FontWeight.w600,
                                                    color: AppColors.text)),
                                            Text(region,
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
                                              ? LinearGradient(colors: widget.accent)
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
                              ),
                            );
                          }),
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
