import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:brawl_tcg/core/l10n/app_l10n.dart';
import 'package:brawl_tcg/core/theme/app_colors.dart';
import 'package:brawl_tcg/core/widgets/brawl_widgets.dart';
import 'config_field.dart';

class UnidadesScreen extends StatefulWidget {
  final String distancia;
  final String hora;
  final List<Color> accent;
  final void Function(String distancia, String hora)? onSave;

  const UnidadesScreen({
    super.key,
    this.distancia = 'km',
    this.hora = '24h',
    this.accent = AppColors.clienteGradient,
    this.onSave,
  });

  @override
  State<UnidadesScreen> createState() => _UnidadesScreenState();
}

class _UnidadesScreenState extends State<UnidadesScreen> {
  late String _distancia;
  late String _hora;

  @override
  void initState() {
    super.initState();
    _distancia = widget.distancia;
    _hora = widget.hora;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: BrawlBackground(
        seed: 61,
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(22, 18, 22, 20),
                child: Row(
                  children: [
                    const BackBtn(),
                    const SizedBox(width: 14),
                    Text(L10n.t('Unidades'),
                        style: GoogleFonts.rubik(
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                            color: AppColors.text)),
                  ],
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(22, 0, 22, 32),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ConfigSectionHeader(L10n.t('Distancia')),
                      _SegmentedPicker(
                        options: [
                          ('km', L10n.t('📍 Kilómetros')),
                          ('mi', L10n.t('📍 Millas')),
                        ],
                        selected: _distancia,
                        accent: widget.accent,
                        onChanged: (v) => setState(() => _distancia = v),
                      ),
                      const SizedBox(height: 24),
                      ConfigSectionHeader(L10n.t('Formato de hora')),
                      _SegmentedPicker(
                        options: [
                          ('24h', L10n.t('🕐 24 horas')),
                          ('12h', L10n.t('🕐 12 horas (AM/PM)')),
                        ],
                        selected: _hora,
                        accent: widget.accent,
                        onChanged: (v) => setState(() => _hora = v),
                      ),
                      const SizedBox(height: 32),
                      GradBtn(
                        width: double.infinity,
                        size: GradBtnSize.lg,
                        gradient: widget.accent,
                        onTap: () {
                          widget.onSave?.call(_distancia, _hora);
                          Navigator.pop(context);
                        },
                        child: Text(L10n.t('Guardar cambios')),
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

class _SegmentedPicker extends StatelessWidget {
  final List<(String, String)> options;
  final String selected;
  final List<Color> accent;
  final void Function(String) onChanged;

  const _SegmentedPicker({
    required this.options,
    required this.selected,
    required this.accent,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return BrawlCard(
      padding: EdgeInsets.zero,
      radius: 18,
      child: Column(
        children: List.generate(options.length, (i) {
          final (value, label) = options[i];
          final isSelected = selected == value;
          return GestureDetector(
            onTap: () => onChanged(value),
            child: Container(
              decoration: BoxDecoration(
                color: isSelected ? accent.first.withValues(alpha: 0.08) : null,
                border: i < options.length - 1
                    ? Border(bottom: BorderSide(color: AppColors.stroke))
                    : null,
              ),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(label,
                          style: GoogleFonts.rubik(
                              fontSize: 14,
                              fontWeight: isSelected
                                  ? FontWeight.w600
                                  : FontWeight.w400,
                              color: isSelected
                                  ? AppColors.text
                                  : AppColors.textDim)),
                    ),
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 180),
                      width: 22,
                      height: 22,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: isSelected
                            ? LinearGradient(colors: accent)
                            : null,
                        border: Border.all(
                          color: isSelected
                              ? Colors.transparent
                              : AppColors.stroke,
                          width: 1.5,
                        ),
                      ),
                      child: isSelected
                          ? const Icon(Icons.check, size: 13, color: Colors.white)
                          : null,
                    ),
                  ],
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}
