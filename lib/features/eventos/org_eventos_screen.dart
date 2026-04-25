import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:brawl_tcg/core/theme/app_colors.dart';
import 'package:brawl_tcg/core/widgets/brawl_widgets.dart';
import 'package:brawl_tcg/core/navigation/transitions.dart';
import 'package:brawl_tcg/features/notificaciones/shared_notis_screen.dart';
import 'package:brawl_tcg/features/eventos/org_info_screen.dart';
import 'package:brawl_tcg/features/anuncios/org_anuncios_screen.dart';
import 'data/tournament.dart';
import 'data/org_kpi.dart';
import 'services/eventos_service.dart';

class OrgEventosScreen extends StatefulWidget {
  const OrgEventosScreen({super.key});

  @override
  State<OrgEventosScreen> createState() => _OrgEventosScreenState();
}

class _OrgEventosScreenState extends State<OrgEventosScreen> {
  String _activeTab = 'encurso';
  String _storeName = '...';
  String? _uid;

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  Future<void> _loadUser() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    setState(() => _uid = user.uid);
    try {
      final doc = await FirebaseFirestore.instance
          .collection('User')
          .doc(user.uid)
          .get();
      final name = doc.data()?['name'] as String? ??
          user.email?.split('@').first ??
          'Organizador';
      if (mounted) setState(() => _storeName = name.toUpperCase());
    } catch (_) {}
  }

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
                    // ── Header ──────────────────────────────────────────────
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '$_storeName · ORGANIZADOR',
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
                            _IconBtn(icon: '🔔', onTap: _openNotis),
                            const SizedBox(width: 8),
                            _IconBtn(icon: '📢', onTap: _openAnuncios),
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
                    // ── KPI row ─────────────────────────────────────────────
                    _uid == null
                        ? const _KpiSkeleton()
                        : StreamBuilder<OrgKpi>(
                            stream: EventosService.watchOrgKpi(_uid!),
                            builder: (ctx, snap) {
                              final kpi = snap.data ??
                                  const OrgKpi(
                                    todayCount: 0,
                                    totalEnrolled: 0,
                                    newEnrollments: 0,
                                    monthlyRevenue: 0,
                                  );
                              return Row(
                                children: [
                                  _KpiCard(
                                    label: 'Hoy',
                                    value: kpi.todayCount.toString(),
                                    suffix: 'torneos',
                                  ),
                                  const SizedBox(width: 8),
                                  _KpiCard(
                                    label: 'Inscritos',
                                    value: kpi.totalEnrolled.toString(),
                                    badge: kpi.newEnrollments > 0
                                        ? '+${kpi.newEnrollments}'
                                        : null,
                                  ),
                                  const SizedBox(width: 8),
                                  _KpiCard(
                                    label: 'Este mes',
                                    value: kpi.revenueLabel,
                                  ),
                                ],
                              );
                            },
                          ),
                    const SizedBox(height: 16),
                    // ── Tab row ─────────────────────────────────────────────
                    _uid == null
                        ? const SizedBox(height: 28)
                        : _TabCountsRow(
                            uid: _uid!,
                            activeTab: _activeTab,
                            onTab: (t) => setState(() => _activeTab = t),
                          ),
                    const SizedBox(height: 4),
                  ],
                ),
              ),
              // ── Tab content ───────────────────────────────────────────────
              Expanded(
                child: _uid == null
                    ? const Center(
                        child: CircularProgressIndicator(
                            color: AppColors.orange))
                    : SingleChildScrollView(
                        padding: const EdgeInsets.fromLTRB(22, 16, 22, 20),
                        child: AnimatedSwitcher(
                          duration: const Duration(milliseconds: 220),
                          child: KeyedSubtree(
                            key: ValueKey(_activeTab),
                            child: _tabContent(),
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

  Widget _tabContent() {
    final uid = _uid!;
    if (_activeTab == 'encurso') {
      return StreamBuilder<List<Tournament>>(
        stream: EventosService.watchOrgEnCurso(uid),
        builder: (ctx, snap) {
          if (!snap.hasData) return const _LoadingContent();
          final all = snap.data!;
          final live = all
              .where((t) => t.status == TournamentStatus.live)
              .toList();
          final pending = all
              .where((t) => t.status != TournamentStatus.live)
              .toList();
          if (all.isEmpty) {
            return _EmptyContent(
              icon: '◈',
              message: 'Sin torneos activos',
              sub: 'Crea tu primer torneo con el botón ＋ Crear',
              onAction: _openCrear,
              actionLabel: '＋ Crear torneo',
            );
          }
          return _EnCursoContent(
            onCrear: _openCrear,
            liveTournament: live.isEmpty ? null : live.first,
            upcomingTournaments: pending,
          );
        },
      );
    }

    if (_activeTab == 'borradores') {
      return StreamBuilder<List<Tournament>>(
        stream: EventosService.watchOrgByStatus(uid, 'Draft'),
        builder: (ctx, snap) {
          if (!snap.hasData) return const _LoadingContent();
          if (snap.data!.isEmpty) {
            return const _EmptyContent(
              icon: '✎',
              message: 'Sin borradores',
              sub: 'Los torneos guardados sin publicar aparecerán aquí',
            );
          }
          return _TournamentList(tournaments: snap.data!);
        },
      );
    }

    // finalizados
    return StreamBuilder<List<Tournament>>(
      stream: EventosService.watchOrgByStatus(uid, 'Finished'),
      builder: (ctx, snap) {
        if (!snap.hasData) return const _LoadingContent();
        if (snap.data!.isEmpty) {
          return const _EmptyContent(
            icon: '🏁',
            message: 'Sin torneos finalizados',
            sub: 'Aquí verás el historial de torneos completados',
          );
        }
        return _TournamentList(tournaments: snap.data!, finished: true);
      },
    );
  }
}

// ── Tab row with live counts ───────────────────────────────────────────────────

class _TabCountsRow extends StatelessWidget {
  final String uid;
  final String activeTab;
  final void Function(String) onTab;
  const _TabCountsRow(
      {required this.uid, required this.activeTab, required this.onTab});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<_TabCounts>(
      stream: _watchCounts(uid),
      builder: (ctx, snap) {
        final c = snap.data ?? const _TabCounts(0, 0, 0);
        return Row(
          children: [
            GestureDetector(
              onTap: () => onTab('encurso'),
              child: _UnderlineTab(
                  label: 'En curso',
                  count: c.enCurso,
                  active: activeTab == 'encurso'),
            ),
            const SizedBox(width: 16),
            GestureDetector(
              onTap: () => onTab('borradores'),
              child: _UnderlineTab(
                  label: 'Borradores',
                  count: c.draft,
                  active: activeTab == 'borradores'),
            ),
            const SizedBox(width: 16),
            GestureDetector(
              onTap: () => onTab('finalizados'),
              child: _UnderlineTab(
                  label: 'Finalizados',
                  count: c.finished,
                  active: activeTab == 'finalizados'),
            ),
          ],
        );
      },
    );
  }

  static Stream<_TabCounts> _watchCounts(String uid) {
    final orgRef =
        FirebaseFirestore.instance.collection('User').doc(uid);
    return FirebaseFirestore.instance
        .collection('Tournaments')
        .where('organizerId', isEqualTo: orgRef)
        .snapshots()
        .map((snap) {
      int enCurso = 0, draft = 0, finished = 0;
      for (final doc in snap.docs) {
        final status = (doc.data()['status'] as String? ?? '').toLowerCase();
        if (status == 'live' || status == 'pending') enCurso++;
        if (status == 'draft') draft++;
        if (status == 'finished') finished++;
      }
      return _TabCounts(enCurso, draft, finished);
    });
  }
}

class _TabCounts {
  final int enCurso, draft, finished;
  const _TabCounts(this.enCurso, this.draft, this.finished);
}

// ── Content widgets ───────────────────────────────────────────────────────────

class _EnCursoContent extends StatelessWidget {
  final VoidCallback onCrear;
  final Tournament? liveTournament;
  final List<Tournament> upcomingTournaments;

  const _EnCursoContent({
    required this.onCrear,
    required this.liveTournament,
    required this.upcomingTournaments,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if (liveTournament != null) ...[
          _LiveCard(tournament: liveTournament!),
          const SizedBox(height: 12),
        ],
        ...upcomingTournaments.map((t) => _UpcomingCard(tournament: t)),
        const SizedBox(height: 20),
      ],
    );
  }
}

class _TournamentList extends StatelessWidget {
  final List<Tournament> tournaments;
  final bool finished;
  const _TournamentList(
      {required this.tournaments, this.finished = false});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ...tournaments.map((t) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: BrawlCard(
                padding: const EdgeInsets.all(16),
                radius: 20,
                child: Row(
                  children: [
                    GameBadge(game: t.game.code, size: 40),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            t.name,
                            style: GoogleFonts.rubik(
                              fontSize: 14.5,
                              fontWeight: FontWeight.w700,
                              color: AppColors.text,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            t.detailLabel,
                            style: GoogleFonts.rubik(
                              fontSize: 12,
                              color: AppColors.textDim,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (finished)
                      BrawlTag(
                        label: 'Finalizado',
                        color: AppColors.textMute,
                      )
                    else
                      BrawlTag(
                        label: 'Borrador',
                        color: AppColors.yellow,
                      ),
                  ],
                ),
              ),
            )),
        const SizedBox(height: 20),
      ],
    );
  }
}

class _LoadingContent extends StatelessWidget {
  const _LoadingContent();

  @override
  Widget build(BuildContext context) => const SizedBox(
        height: 200,
        child: Center(
            child:
                CircularProgressIndicator(color: AppColors.orange)),
      );
}

class _EmptyContent extends StatelessWidget {
  final String icon, message, sub;
  final VoidCallback? onAction;
  final String? actionLabel;
  const _EmptyContent({
    required this.icon,
    required this.message,
    required this.sub,
    this.onAction,
    this.actionLabel,
  });

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 24),
        child: BrawlCard(
          padding: const EdgeInsets.all(28),
          radius: 22,
          child: Column(
            children: [
              Text(icon,
                  style: TextStyle(
                      fontSize: 36, color: AppColors.textMute)),
              const SizedBox(height: 12),
              Text(
                message,
                style: GoogleFonts.rubik(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: AppColors.text),
              ),
              const SizedBox(height: 4),
              Text(
                sub,
                textAlign: TextAlign.center,
                style: GoogleFonts.rubik(
                    fontSize: 12, color: AppColors.textMute),
              ),
              if (onAction != null) ...[
                const SizedBox(height: 16),
                GradBtn(
                  gradient: AppColors.organizadorGradient,
                  onTap: onAction,
                  child: Text(actionLabel ?? ''),
                ),
              ],
            ],
          ),
        ),
      );
}

// ── Reused UI widgets ─────────────────────────────────────────────────────────

class _IconBtn extends StatelessWidget {
  final String icon;
  final VoidCallback onTap;
  const _IconBtn({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: onTap,
        child: Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.stroke),
          ),
          child: Center(
              child: Text(icon, style: const TextStyle(fontSize: 15))),
        ),
      );
}

class _KpiSkeleton extends StatelessWidget {
  const _KpiSkeleton();

  @override
  Widget build(BuildContext context) => Row(
        children: List.generate(
            3,
            (_) => Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: BrawlCard(
                      padding: const EdgeInsets.all(12),
                      radius: 18,
                      child: const SizedBox(height: 38),
                    ),
                  ),
                )),
      );
}

class _KpiCard extends StatelessWidget {
  final String label, value;
  final String? suffix, badge;
  const _KpiCard(
      {required this.label,
      required this.value,
      this.suffix,
      this.badge});

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
                  letterSpacing: 0.5),
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
                      color: Colors.white),
                ),
                if (suffix != null) ...[
                  const SizedBox(width: 4),
                  Text(suffix!,
                      style: GoogleFonts.rubik(
                          fontSize: 12, color: AppColors.textMute)),
                ],
                if (badge != null) ...[
                  const SizedBox(width: 6),
                  Text(badge!,
                      style: GoogleFonts.rubik(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: AppColors.cyan)),
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
  const _UnderlineTab(
      {required this.label,
      required this.count,
      this.active = false});

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
                  fontWeight:
                      active ? FontWeight.w600 : FontWeight.w500,
                  color: active ? AppColors.text : AppColors.textMute,
                ),
              ),
              const SizedBox(width: 6),
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 6, vertical: 1),
                decoration: BoxDecoration(
                    color: AppColors.surfaceHi,
                    borderRadius: BorderRadius.circular(8)),
                child: Text('$count',
                    style: GoogleFonts.rubik(
                        fontSize: 10, color: AppColors.text)),
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
                    colors: AppColors.organizadorGradient),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
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
                      letterSpacing: 0.6),
                ),
                const Spacer(),
                Text(
                  '⏱ ${tournament.liveTimer ?? '—'}',
                  style: GoogleFonts.rubikMonoOne(
                      fontSize: 11, color: AppColors.textDim),
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
                          Text(tournament.name,
                              style: GoogleFonts.rubik(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.text)),
                          const SizedBox(height: 2),
                          Text(
                            '${tournament.enrolledCount} inscritos · ${tournament.activeTables ?? 0} mesas activas',
                            style: GoogleFonts.rubik(
                                fontSize: 12,
                                color: AppColors.textDim),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                if (progress.isNotEmpty) ...[
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
                                borderRadius: BorderRadius.circular(3)),
                            child: FractionallySizedBox(
                              widthFactor: v,
                              alignment: Alignment.centerLeft,
                              child: Container(
                                decoration: BoxDecoration(
                                  color: v == 1.0
                                      ? AppColors.cyan
                                      : AppColors.orange,
                                  borderRadius:
                                      BorderRadius.circular(3),
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
                      Text('Ronda $currentRound en juego',
                          style: GoogleFonts.rubik(
                              fontSize: 11,
                              color: AppColors.textMute)),
                      Text(
                          '${tournament.pendingResults ?? 0} resultados pendientes',
                          style: GoogleFonts.rubik(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: AppColors.cyan)),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ],
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
                        child: Text(tournament.name,
                            style: GoogleFonts.rubik(
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                                color: AppColors.text)),
                      ),
                      if (tournament.tagLabel != null) ...[
                        const SizedBox(width: 8),
                        BrawlTag(
                          label: tournament.tagLabel!,
                          color: tournament.tagColor ??
                              AppColors.textMute,
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 3),
                  Text(tournament.detailLabel,
                      style: GoogleFonts.rubik(
                          fontSize: 12, color: AppColors.textDim)),
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
                                      colors:
                                          AppColors.organizadorGradient),
                                  borderRadius:
                                      BorderRadius.circular(3),
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
                            fontSize: 11, color: AppColors.text),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
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
        vsync: this, duration: const Duration(milliseconds: 1200))
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
