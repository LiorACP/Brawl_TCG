import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:brawl_tcg/core/theme/app_colors.dart';
import 'package:brawl_tcg/core/widgets/brawl_widgets.dart';
import 'package:brawl_tcg/core/navigation/transitions.dart';
import 'package:brawl_tcg/features/anuncios/org_anuncios_screen.dart';
import 'viewmodels/premios_viewmodel.dart';

class OrgPremiosScreen extends StatefulWidget {
  final String eventId;
  final String eventName;
  final double entryFee;
  final int plazas;

  const OrgPremiosScreen({
    super.key,
    required this.eventId,
    required this.eventName,
    required this.entryFee,
    required this.plazas,
  });

  @override
  State<OrgPremiosScreen> createState() => _OrgPremiosScreenState();
}

class _OrgPremiosScreenState extends State<OrgPremiosScreen> {
  int _pool = 200;
  bool _productPrize = true;
  bool _promoPrize = true;
  final _vm = PremiosViewModel();

  final _prizes = [
    _PrizeSlot(pos: '🏆  1.º', pct: 40),
    _PrizeSlot(pos: '🥈  2.º', pct: 25),
    _PrizeSlot(pos: '🥉  3.º / 4.º', pct: 20),
    _PrizeSlot(pos: '       5.º – 8.º', pct: 15),
  ];

  @override
  void initState() {
    super.initState();
    _vm.addListener(_onVmUpdate);
  }

  void _onVmUpdate() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _vm.removeListener(_onVmUpdate);
    _vm.dispose();
    super.dispose();
  }

  Future<void> _saveDraft() async {
    final ok = await _vm.saveDraft(
        widget.eventId, _pool, _productPrize, _promoPrize);
    if (ok && mounted) Navigator.of(context).popUntil((route) => route.isFirst);
  }

  Future<void> _next() async {
    final ok =
        await _vm.next(widget.eventId, _pool, _productPrize, _promoPrize);
    if (!mounted) return;
    if (ok) {
      Navigator.push(
        context,
        fadeSlideRoute(OrgAnunciosScreen(
          isCreationFlow: true,
          eventId: widget.eventId,
        )),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error al guardar los premios')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: BrawlBackground(
        seed: 37,
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
                              Text('Paso 3 de 4 · Premios',
                                  style: GoogleFonts.rubik(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.text)),
                            ],
                          ),
                        ),
                        GestureDetector(
                          onTap: _vm.isSaving ? null : _saveDraft,
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
                                  padding:
                                      EdgeInsets.only(right: i < 3 ? 6 : 0),
                                  child: Container(
                                    height: 4,
                                    decoration: BoxDecoration(
                                      gradient: i < 3
                                          ? const LinearGradient(
                                              colors:
                                                  AppColors.organizadorGradient)
                                          : null,
                                      color: i >= 3
                                          ? AppColors.surfaceHi
                                          : null,
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
                            Text('BOTE DE PREMIOS',
                                style: GoogleFonts.rubik(
                                    fontSize: 11,
                                    color: AppColors.textMute,
                                    fontWeight: FontWeight.w600,
                                    letterSpacing: 0.5)),
                            const SizedBox(height: 10),
                            Row(
                              children: [
                                GestureDetector(
                                  onTap: () => setState(() =>
                                      _pool = (_pool - 10).clamp(0, 5000)),
                                  child: Container(
                                    width: 36,
                                    height: 36,
                                    decoration: BoxDecoration(
                                      color: AppColors.surfaceHi,
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Center(
                                        child: Text('−',
                                            style: TextStyle(
                                                fontSize: 20,
                                                color: AppColors.textDim))),
                                  ),
                                ),
                                Expanded(
                                  child: Center(
                                    child: GradText(
                                      text: '€ $_pool',
                                      gradient:
                                          AppColors.organizadorGradient,
                                      style: GoogleFonts.rubikMonoOne(
                                          fontSize: 28,
                                          color: Colors.white),
                                    ),
                                  ),
                                ),
                                GestureDetector(
                                  onTap: () => setState(() =>
                                      _pool = (_pool + 10).clamp(0, 5000)),
                                  child: Container(
                                    width: 36,
                                    height: 36,
                                    decoration: BoxDecoration(
                                      gradient: const LinearGradient(
                                          colors:
                                              AppColors.organizadorGradient),
                                      borderRadius: BorderRadius.circular(12),
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
                      const SectionLabel('Distribución',
                          margin: EdgeInsets.only(
                              left: 4, top: 14, bottom: 10)),
                      ..._prizes.map((p) => Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: BrawlCard(
                              padding: const EdgeInsets.all(14),
                              radius: 18,
                              child: Row(
                                children: [
                                  SizedBox(
                                    width: 110,
                                    child: Text(p.pos,
                                        style: GoogleFonts.rubik(
                                            fontSize: 13,
                                            fontWeight: FontWeight.w600,
                                            color: AppColors.text)),
                                  ),
                                  Expanded(
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(3),
                                      child: Container(
                                        height: 5,
                                        color: AppColors.surfaceHi,
                                        child: FractionallySizedBox(
                                          widthFactor: p.pct / 100,
                                          alignment: Alignment.centerLeft,
                                          child: Container(
                                            decoration: BoxDecoration(
                                              gradient: const LinearGradient(
                                                  colors: AppColors
                                                      .organizadorGradient),
                                              borderRadius:
                                                  BorderRadius.circular(3),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  SizedBox(
                                    width: 60,
                                    child: Text(
                                      '€ ${(_pool * p.pct / 100).round()}',
                                      textAlign: TextAlign.right,
                                      style: GoogleFonts.rubikMonoOne(
                                          fontSize: 13,
                                          color: AppColors.text),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          )),
                      const SectionLabel('Extras',
                          margin: EdgeInsets.only(
                              left: 4, top: 14, bottom: 10)),
                      _ToggleRow(
                        icon: '◈',
                        color: AppColors.violet,
                        title: 'Premio en producto',
                        sub: 'Booster packs, sleeves o singles',
                        value: _productPrize,
                        onToggle: (v) => setState(() => _productPrize = v),
                      ),
                      const SizedBox(height: 8),
                      _ToggleRow(
                        icon: '✦',
                        color: AppColors.yellow,
                        title: 'Promo exclusiva Top 4',
                        sub: 'Carta promo del evento',
                        value: _promoPrize,
                        onToggle: (v) => setState(() => _promoPrize = v),
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
                        padding:
                            const EdgeInsets.symmetric(horizontal: 20),
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
                      child: _vm.isSaving
                          ? const Center(
                              child: CircularProgressIndicator(
                                  color: AppColors.orange))
                          : GradBtn(
                              size: GradBtnSize.lg,
                              gradient: AppColors.organizadorGradient,
                              width: double.infinity,
                              onTap: _next,
                              child: const Text('Siguiente · Publicar →'),
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

class _PrizeSlot {
  final String pos;
  final int pct;
  const _PrizeSlot({required this.pos, required this.pct});
}

class _ToggleRow extends StatelessWidget {
  final String icon, title, sub;
  final Color color;
  final bool value;
  final ValueChanged<bool> onToggle;
  const _ToggleRow({
    required this.icon,
    required this.color,
    required this.title,
    required this.sub,
    required this.value,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return BrawlCard(
      padding: const EdgeInsets.all(14),
      radius: 18,
      child: Row(
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(11),
              border: Border.all(color: color.withValues(alpha: 0.2)),
            ),
            child: Center(
                child: Text(icon,
                    style: TextStyle(fontSize: 15, color: color))),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: GoogleFonts.rubik(
                        fontSize: 13.5,
                        fontWeight: FontWeight.w600,
                        color: AppColors.text)),
                Text(sub,
                    style: GoogleFonts.rubik(
                        fontSize: 11, color: AppColors.textMute)),
              ],
            ),
          ),
          GestureDetector(
            onTap: () => onToggle(!value),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 40,
              height: 24,
              decoration: BoxDecoration(
                gradient: value
                    ? const LinearGradient(
                        colors: AppColors.organizadorGradient)
                    : null,
                color: value ? null : AppColors.surfaceHi,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Stack(
                children: [
                  AnimatedPositioned(
                    duration: const Duration(milliseconds: 200),
                    top: 2,
                    left: value ? null : 2,
                    right: value ? 2 : null,
                    child: Container(
                      width: 20,
                      height: 20,
                      decoration: const BoxDecoration(
                          shape: BoxShape.circle, color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
