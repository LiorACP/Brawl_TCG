import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../theme/app_colors.dart';
import '../../widgets/brawl_widgets.dart';
import '../../navigation/transitions.dart';
import '../shared/shared_notis_screen.dart';
import 'org_crear_screen.dart';
import 'org_anuncios_screen.dart';

class OrgEventosScreen extends StatefulWidget {
  const OrgEventosScreen({super.key});

  @override
  State<OrgEventosScreen> createState() => _OrgEventosScreenState();
}

class _OrgEventosScreenState extends State<OrgEventosScreen> {
  String _activeTab = 'encurso';

  void _openNotis() =>
      Navigator.push(context, fadeSlideRoute(const SharedNotisScreen()));

  void _openCrear() =>
      Navigator.push(context, fadeSlideRoute(const OrgCrearScreen()));

  void _openAnuncios() =>
      Navigator.push(context, fadeSlideRoute(const OrgAnunciosScreen()));

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: BrawlBackground(
        seed: 31,
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(22, 18, 22, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('DRAGÓN ROJO · ORGANIZADOR',
                                style: GoogleFonts.rubik(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.textMute,
                                    letterSpacing: 0.5)),
                            const SizedBox(height: 2),
                            Text('Eventos',
                                style: GoogleFonts.rubik(
                                    fontSize: 26,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.text,
                                    letterSpacing: -0.5)),
                          ],
                        ),
                        Row(
                          children: [
                            // Bell → notis
                            GestureDetector(
                              onTap: _openNotis,
                              child: Container(
                                width: 36,
                                height: 36,
                                decoration: BoxDecoration(
                                  color: AppColors.surface,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: AppColors.stroke),
                                ),
                                child: const Center(
                                  child: Text('🔔', style: TextStyle(fontSize: 15)),
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            // Megaphone → anuncios
                            GestureDetector(
                              onTap: _openAnuncios,
                              child: Container(
                                width: 36,
                                height: 36,
                                decoration: BoxDecoration(
                                  color: AppColors.surface,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: AppColors.stroke),
                                ),
                                child: Center(
                                  child: Text('📢',
                                      style: TextStyle(fontSize: 15, color: AppColors.orange)),
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            // + Crear
                            GradBtn(
                              size: GradBtnSize.sm,
                              gradient: AppColors.organizadorGradient,
                              onTap: _openCrear,
                              child: const Text('＋ Crear'),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    // KPI row
                    Row(
                      children: [
                        _KpiCard(label: 'Hoy', value: '2', suffix: 'torneos'),
                        const SizedBox(width: 8),
                        _KpiCard(label: 'Inscritos', value: '48', badge: '+6'),
                        const SizedBox(width: 8),
                        _KpiCard(label: 'Este mes', value: '€ 1.240'),
                      ],
                    ),
                    const SizedBox(height: 16),
                    // Tabs underline
                    Row(
                      children: [
                        GestureDetector(
                          onTap: () => setState(() => _activeTab = 'encurso'),
                          child: _UnderlineTab(
                              label: 'En curso', count: 2, active: _activeTab == 'encurso'),
                        ),
                        const SizedBox(width: 16),
                        GestureDetector(
                          onTap: () => setState(() => _activeTab = 'borradores'),
                          child: _UnderlineTab(
                              label: 'Borradores', count: 1, active: _activeTab == 'borradores'),
                        ),
                        const SizedBox(width: 16),
                        GestureDetector(
                          onTap: () => setState(() => _activeTab = 'finalizados'),
                          child: _UnderlineTab(
                              label: 'Finalizados', count: 14, active: _activeTab == 'finalizados'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                  ],
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(22, 16, 22, 20),
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 220),
                    child: _activeTab == 'encurso'
                        ? _EnCursoContent(key: const ValueKey('encurso'), onCrear: _openCrear)
                        : _PlaceholderContent(
                            key: ValueKey(_activeTab),
                            label: _activeTab == 'borradores' ? 'Borradores' : 'Finalizados',
                          ),
                  ),
                ),
              ),
              // Placeholder para BrawlTabBar del OrgShell
              const SizedBox(height: 106),
            ],
          ),
        ),
      ),
    );
  }
}

class _EnCursoContent extends StatelessWidget {
  final VoidCallback onCrear;
  const _EnCursoContent({super.key, required this.onCrear});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Live card
        BrawlCard(
          padding: EdgeInsets.zero,
          radius: 24,
          tint: const Color(0xFF110D1E),
          border: AppColors.pink.withValues(alpha: 0.3),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
                child: Row(
                  children: [
                    _PulseDot(color: AppColors.pink),
                    const SizedBox(width: 10),
                    Text('EN VIVO · RONDA 3 / 5',
                        style: GoogleFonts.rubik(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: AppColors.pink,
                            letterSpacing: 0.6)),
                    const Spacer(),
                    Text('⏱ 22:14',
                        style: GoogleFonts.rubikMonoOne(fontSize: 11, color: AppColors.textDim)),
                  ],
                ),
              ),
              Container(height: 1, color: AppColors.stroke),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Row(
                      children: [
                        const GameBadge(game: 'MTG', size: 42),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Pioneer FNM Abril',
                                  style: GoogleFonts.rubik(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.text)),
                              const SizedBox(height: 2),
                              Text('32 inscritos · 16 mesas activas',
                                  style: GoogleFonts.rubik(fontSize: 12, color: AppColors.textDim)),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    Row(
                      children: List.generate(5, (i) {
                        final v = [1.0, 1.0, 1.0, 0.6, 0.0][i];
                        return Expanded(
                          child: Padding(
                            padding: const EdgeInsets.only(right: 4),
                            child: Container(
                              height: 6,
                              decoration: BoxDecoration(
                                color: AppColors.surfaceHi,
                                borderRadius: BorderRadius.circular(3),
                              ),
                              child: FractionallySizedBox(
                                widthFactor: v,
                                alignment: Alignment.centerLeft,
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: v == 1.0 ? AppColors.cyan : AppColors.orange,
                                    borderRadius: BorderRadius.circular(3),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        );
                      }),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Ronda 3 en juego',
                            style: GoogleFonts.rubik(fontSize: 11, color: AppColors.textMute)),
                        Text('18 resultados pendientes',
                            style: GoogleFonts.rubik(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: AppColors.cyan)),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        _UpcomingCard(
            game: 'POK',
            title: 'Prerelease Stellar',
            detail: 'Sáb · 10:00 · 16 plazas',
            fill: 0.75,
            current: 12,
            total: 16,
            tag: 'Mañana',
            tagColor: AppColors.yellow),
        _UpcomingCard(
            game: 'YGO',
            title: 'Liga Master Duel — J3',
            detail: 'Dom · 17:00 · 24 plazas',
            fill: 0.33,
            current: 8,
            total: 24,
            tag: 'Dom',
            tagColor: AppColors.violet),
        _UpcomingCard(
            game: 'LOR',
            title: 'Runeterra Showdown',
            detail: 'Vie 1 May · 19:30 · Online',
            fill: 0.12,
            current: 4,
            total: 32,
            tag: 'En 6 días',
            tagColor: AppColors.cyan,
            opacity: 0.8),
        const SizedBox(height: 20),
      ],
    );
  }
}

class _PlaceholderContent extends StatelessWidget {
  final String label;
  const _PlaceholderContent({super.key, required this.label});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 300,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('—', style: TextStyle(fontSize: 32, color: AppColors.textMute)),
            const SizedBox(height: 8),
            Text('No hay $label',
                style: GoogleFonts.rubik(fontSize: 14, color: AppColors.textMute)),
          ],
        ),
      ),
    );
  }
}

class _KpiCard extends StatelessWidget {
  final String label, value;
  final String? suffix, badge;
  const _KpiCard({required this.label, required this.value, this.suffix, this.badge});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: BrawlCard(
        padding: const EdgeInsets.all(12),
        radius: 18,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label.toUpperCase(),
                style: GoogleFonts.rubik(
                    fontSize: 10.5, color: AppColors.textMute, letterSpacing: 0.5)),
            const SizedBox(height: 2),
            Row(
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                GradText(
                  text: value,
                  gradient: AppColors.organizadorGradient,
                  style: GoogleFonts.rubik(
                      fontSize: 22, fontWeight: FontWeight.w700, color: Colors.white),
                ),
                if (suffix != null) ...[
                  const SizedBox(width: 4),
                  Text(suffix!,
                      style: GoogleFonts.rubik(fontSize: 12, color: AppColors.textMute)),
                ],
                if (badge != null) ...[
                  const SizedBox(width: 6),
                  Text(badge!,
                      style: GoogleFonts.rubik(
                          fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.cyan)),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _UnderlineTab extends StatelessWidget {
  final String label;
  final int count;
  final bool active;
  const _UnderlineTab({required this.label, required this.count, this.active = false});

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Row(
            children: [
              Text(label,
                  style: GoogleFonts.rubik(
                      fontSize: 13,
                      fontWeight: active ? FontWeight.w600 : FontWeight.w500,
                      color: active ? AppColors.text : AppColors.textMute)),
              const SizedBox(width: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                decoration: BoxDecoration(
                    color: AppColors.surfaceHi, borderRadius: BorderRadius.circular(8)),
                child: Text('$count',
                    style: GoogleFonts.rubik(fontSize: 10, color: AppColors.text)),
              ),
            ],
          ),
        ),
        if (active)
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              height: 2,
              decoration: BoxDecoration(
                gradient: const LinearGradient(colors: AppColors.organizadorGradient),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
      ],
    );
  }
}

class _PulseDot extends StatefulWidget {
  final Color color;
  const _PulseDot({required this.color});

  @override
  State<_PulseDot> createState() => _PulseDotState();
}

class _PulseDotState extends State<_PulseDot> with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 1200))
      ..repeat(reverse: true);
    _anim = Tween(begin: 0.25, end: 0.8).animate(_ctrl);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _anim,
      builder: (_, __) => Container(
        width: 8,
        height: 8,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: widget.color.withValues(alpha: _anim.value),
        ),
      ),
    );
  }
}

class _UpcomingCard extends StatelessWidget {
  final String game, title, detail, tag;
  final Color tagColor;
  final double fill;
  final int current, total;
  final double opacity;
  const _UpcomingCard({
    required this.game,
    required this.title,
    required this.detail,
    required this.tag,
    required this.tagColor,
    required this.fill,
    required this.current,
    required this.total,
    this.opacity = 1.0,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Opacity(
        opacity: opacity,
        child: BrawlCard(
          padding: const EdgeInsets.all(16),
          radius: 24,
          child: Row(
            children: [
              GameBadge(game: game, size: 42),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(title,
                              style: GoogleFonts.rubik(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.text)),
                        ),
                        const SizedBox(width: 8),
                        BrawlTag(label: tag, color: tagColor),
                      ],
                    ),
                    const SizedBox(height: 3),
                    Text(detail,
                        style: GoogleFonts.rubik(fontSize: 12, color: AppColors.textDim)),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(3),
                            child: Container(
                              height: 5,
                              color: AppColors.surfaceHi,
                              child: FractionallySizedBox(
                                widthFactor: fill,
                                alignment: Alignment.centerLeft,
                                child: Container(
                                  decoration: BoxDecoration(
                                    gradient: const LinearGradient(
                                        colors: AppColors.organizadorGradient),
                                    borderRadius: BorderRadius.circular(3),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 14),
                        Text('$current/$total',
                            style:
                                GoogleFonts.rubikMonoOne(fontSize: 11, color: AppColors.text)),
                      ],
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
