import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:brawl_tcg/core/theme/app_colors.dart';
import 'package:brawl_tcg/core/widgets/brawl_widgets.dart';
import 'package:brawl_tcg/core/navigation/transitions.dart';
import 'package:brawl_tcg/features/notificaciones/shared_notis_screen.dart';
import 'package:brawl_tcg/features/eventos/org_info_screen.dart';
import 'package:brawl_tcg/features/anuncios/org_anuncios_screen.dart';
import 'data/tournament.dart';
import 'viewmodels/org_eventos_viewmodel.dart';

class OrgEventosScreen extends StatefulWidget {
  const OrgEventosScreen({super.key});

  @override
  State<OrgEventosScreen> createState() => _OrgEventosScreenState();
}

class _OrgEventosScreenState extends State<OrgEventosScreen> {
  String _activeTab = 'encurso';
  final _vm = OrgEventosViewModel.mock();

  void _openNotis() =>
      Navigator.push(context, fadeSlideRoute(const SharedNotisScreen()));

  void _openCrear() =>
      Navigator.push(context, fadeSlideRoute(const OrgInfoScreen()));

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
                            Text(
                              'DRAGÓN ROJO · ORGANIZADOR',
                              style: GoogleFonts.rubik(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textMute,
                                letterSpacing: 0.5,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'Eventos',
                              style: GoogleFonts.rubik(
                                fontSize: 26,
                                fontWeight: FontWeight.w700,
                                color: AppColors.text,
                                letterSpacing: -0.5,
                              ),
                            ),
                          ],
                        ),
                        Row(
                          children: [
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
                                  child: Text(
                                    '🔔',
                                    style: TextStyle(fontSize: 15),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
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
                                  child: Text(
                                    '📢',
                                    style: TextStyle(
                                      fontSize: 15,
                                      color: AppColors.orange,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
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
                    Row(
                      children: [
                        _KpiCard(
                          label: 'Hoy',
                          value: _vm.kpi.todayCount.toString(),
                          suffix: 'torneos',
                        ),
                        const SizedBox(width: 8),
                        _KpiCard(
                          label: 'Inscritos',
                          value: _vm.kpi.totalEnrolled.toString(),
                          badge: '+${_vm.kpi.newEnrollments}',
                        ),
                        const SizedBox(width: 8),
                        _KpiCard(
                          label: 'Este mes',
                          value: _vm.kpi.revenueLabel,
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        GestureDetector(
                          onTap: () => setState(() => _activeTab = 'encurso'),
                          child: _UnderlineTab(
                            label: 'En curso',
                            count: _vm.enCursoCount,
                            active: _activeTab == 'encurso',
                          ),
                        ),
                        const SizedBox(width: 16),
                        GestureDetector(
                          onTap: () =>
                              setState(() => _activeTab = 'borradores'),
                          child: _UnderlineTab(
                            label: 'Borradores',
                            count: _vm.draftCount,
                            active: _activeTab == 'borradores',
                          ),
                        ),
                        const SizedBox(width: 16),
                        GestureDetector(
                          onTap: () =>
                              setState(() => _activeTab = 'finalizados'),
                          child: _UnderlineTab(
                            label: 'Finalizados',
                            count: _vm.finishedCount,
                            active: _activeTab == 'finalizados',
                          ),
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
                        ? _EnCursoContent(
                            key: const ValueKey('encurso'),
                            onCrear: _openCrear,
                            liveTournament: _vm.liveTournament,
                            upcomingTournaments: _vm.upcomingTournaments,
                          )
                        : _PlaceholderContent(
                            key: ValueKey(_activeTab),
                            label: _activeTab == 'borradores'
                                ? 'Borradores'
                                : 'Finalizados',
                          ),
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

class _EnCursoContent extends StatelessWidget {
  final VoidCallback onCrear;
  final Tournament liveTournament;
  final List<Tournament> upcomingTournaments;

  const _EnCursoContent({
    super.key,
    required this.onCrear,
    required this.liveTournament,
    required this.upcomingTournaments,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _LiveCard(tournament: liveTournament),
        const SizedBox(height: 12),
        ...upcomingTournaments.map((t) => _UpcomingCard(tournament: t)),
        const SizedBox(height: 20),
      ],
    );
  }
}

class _LiveCard extends StatelessWidget {
  final Tournament tournament;
  const _LiveCard({required this.tournament});

  @override
  Widget build(BuildContext context) {
    final progress = tournament.roundProgress ?? [];
    final currentRound = tournament.currentRound ?? 0;
    final totalRounds = tournament.totalRounds ?? 0;

    return BrawlCard(
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
                Text(
                  'EN VIVO · RONDA $currentRound / $totalRounds',
                  style: GoogleFonts.rubik(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: AppColors.pink,
                    letterSpacing: 0.6,
                  ),
                ),
                const Spacer(),
                Text(
                  '⏱ ${tournament.liveTimer ?? '—'}',
                  style: GoogleFonts.rubikMonoOne(
                    fontSize: 11,
                    color: AppColors.textDim,
                  ),
                ),
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
                    GameBadge(game: tournament.game.code, size: 42),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            tournament.name,
                            style: GoogleFonts.rubik(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: AppColors.text,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '${tournament.enrolledCount} inscritos · ${tournament.activeTables ?? 0} mesas activas',
                            style: GoogleFonts.rubik(
                              fontSize: 12,
                              color: AppColors.textDim,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                Row(
                  children: List.generate(progress.length, (i) {
                    final v = progress[i];
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
                                color: v == 1.0
                                    ? AppColors.cyan
                                    : AppColors.orange,
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
                    Text(
                      'Ronda $currentRound en juego',
                      style: GoogleFonts.rubik(
                        fontSize: 11,
                        color: AppColors.textMute,
                      ),
                    ),
                    Text(
                      '${tournament.pendingResults ?? 0} resultados pendientes',
                      style: GoogleFonts.rubik(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: AppColors.cyan,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
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
            Text(
              '—',
              style: TextStyle(fontSize: 32, color: AppColors.textMute),
            ),
            const SizedBox(height: 8),
            Text(
              'No hay $label',
              style: GoogleFonts.rubik(fontSize: 14, color: AppColors.textMute),
            ),
          ],
        ),
      ),
    );
  }
}

class _KpiCard extends StatelessWidget {
  final String label, value;
  final String? suffix, badge;
  const _KpiCard({
    required this.label,
    required this.value,
    this.suffix,
    this.badge,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: BrawlCard(
        padding: const EdgeInsets.all(12),
        radius: 18,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label.toUpperCase(),
              style: GoogleFonts.rubik(
                fontSize: 10.5,
                color: AppColors.textMute,
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 2),
            Row(
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                GradText(
                  text: value,
                  gradient: AppColors.organizadorGradient,
                  style: GoogleFonts.rubik(
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
                if (suffix != null) ...[
                  const SizedBox(width: 4),
                  Text(
                    suffix!,
                    style: GoogleFonts.rubik(
                      fontSize: 12,
                      color: AppColors.textMute,
                    ),
                  ),
                ],
                if (badge != null) ...[
                  const SizedBox(width: 6),
                  Text(
                    badge!,
                    style: GoogleFonts.rubik(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppColors.cyan,
                    ),
                  ),
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
  const _UnderlineTab({
    required this.label,
    required this.count,
    this.active = false,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Row(
            children: [
              Text(
                label,
                style: GoogleFonts.rubik(
                  fontSize: 13,
                  fontWeight: active ? FontWeight.w600 : FontWeight.w500,
                  color: active ? AppColors.text : AppColors.textMute,
                ),
              ),
              const SizedBox(width: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                decoration: BoxDecoration(
                  color: AppColors.surfaceHi,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '$count',
                  style: GoogleFonts.rubik(fontSize: 10, color: AppColors.text),
                ),
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
                gradient: const LinearGradient(
                  colors: AppColors.organizadorGradient,
                ),
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

class _PulseDotState extends State<_PulseDot>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);
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
  final Tournament tournament;
  const _UpcomingCard({required this.tournament});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Opacity(
        opacity: tournament.opacity,
        child: BrawlCard(
          padding: const EdgeInsets.all(16),
          radius: 24,
          child: Row(
            children: [
              GameBadge(game: tournament.game.code, size: 42),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            tournament.name,
                            style: GoogleFonts.rubik(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              color: AppColors.text,
                            ),
                          ),
                        ),
                        if (tournament.tagLabel != null) ...[
                          const SizedBox(width: 8),
                          BrawlTag(
                            label: tournament.tagLabel!,
                            color: tournament.tagColor ?? AppColors.textMute,
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 3),
                    Text(
                      tournament.detailLabel,
                      style: GoogleFonts.rubik(
                        fontSize: 12,
                        color: AppColors.textDim,
                      ),
                    ),
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
                                widthFactor: tournament.fillFraction,
                                alignment: Alignment.centerLeft,
                                child: Container(
                                  decoration: BoxDecoration(
                                    gradient: const LinearGradient(
                                      colors: AppColors.organizadorGradient,
                                    ),
                                    borderRadius: BorderRadius.circular(3),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 14),
                        Text(
                          '${tournament.enrolledCount}/${tournament.totalSlots}',
                          style: GoogleFonts.rubikMonoOne(
                            fontSize: 11,
                            color: AppColors.text,
                          ),
                        ),
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
