import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:brawl_tcg/core/theme/app_colors.dart';
import 'package:brawl_tcg/core/widgets/brawl_widgets.dart';
import 'package:brawl_tcg/core/navigation/transitions.dart';
import 'package:brawl_tcg/features/notificaciones/shared_notis_screen.dart';
import 'package:brawl_tcg/features/codigo/cliente_codigo_screen.dart';
import 'data/tournament.dart';
import 'data/enrollment.dart';
import 'services/eventos_service.dart';

class ClienteEventosScreen extends StatefulWidget {
  const ClienteEventosScreen({super.key});

  @override
  State<ClienteEventosScreen> createState() => _ClienteEventosScreenState();
}

class _ClienteEventosScreenState extends State<ClienteEventosScreen> {
  String _tab = 'apuntados';
  String _userName = '...';
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
          'JUGADOR';
      if (mounted) setState(() => _userName = name.toUpperCase());
    } catch (_) {
      if (mounted) {
        setState(() => _userName =
            user.email?.split('@').first.toUpperCase() ?? 'JUGADOR');
      }
    }
  }

  void _openNotis() =>
      Navigator.push(context, fadeSlideRoute(const SharedNotisScreen()));

  void _openCodigo() =>
      Navigator.push(context, fadeSlideRoute(const ClienteCodigoScreen()));

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: BrawlBackground(
        seed: 7,
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
                              'HOLA, $_userName',
                              style: GoogleFonts.rubik(
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                                color: AppColors.textMute,
                                letterSpacing: 0.5,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'Mis eventos',
                              style: GoogleFonts.rubik(
                                fontSize: 28,
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
                                width: 40,
                                height: 40,
                                decoration: BoxDecoration(
                                  color: AppColors.surface,
                                  borderRadius: BorderRadius.circular(14),
                                  border: Border.all(color: AppColors.stroke),
                                ),
                                child: const Stack(
                                  children: [
                                    Center(
                                      child: Text(
                                        '🔔',
                                        style: TextStyle(fontSize: 17),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            GestureDetector(
                              onTap: _openCodigo,
                              child: Container(
                                width: 40,
                                height: 40,
                                decoration: BoxDecoration(
                                  gradient: const LinearGradient(
                                    colors: AppColors.clienteGradient,
                                  ),
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                child: const Center(
                                  child: Text(
                                    '＋',
                                    style: TextStyle(
                                      fontSize: 20,
                                      color: Colors.white,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 18),
                    Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(999),
                        border: Border.all(color: AppColors.stroke),
                      ),
                      child: Row(
                        children: [
                          _TabPill(
                            label: 'Apuntados',
                            active: _tab == 'apuntados',
                            onTap: () => setState(() => _tab = 'apuntados'),
                          ),
                          _TabPill(
                            label: 'Participados',
                            active: _tab == 'participados',
                            onTap: () =>
                                setState(() => _tab = 'participados'),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 18),
                  ],
                ),
              ),
              Expanded(
                child: _uid == null
                    ? const Center(
                        child: CircularProgressIndicator(
                            color: AppColors.cyan),
                      )
                    : SingleChildScrollView(
                        padding: const EdgeInsets.fromLTRB(22, 0, 22, 20),
                        child: _tab == 'apuntados'
                            ? _ApuntadosStream(uid: _uid!)
                            : _ParticipadosStream(uid: _uid!),
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

// ── Stream wrappers ────────────────────────────────────────────────────────────

class _ApuntadosStream extends StatelessWidget {
  final String uid;
  const _ApuntadosStream({required this.uid});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<(Enrollment? active, List<Enrollment> upcoming)>(
      stream: EventosService.watchClienteApuntados(uid),
      builder: (context, snap) {
        if (snap.connectionState == ConnectionState.waiting) {
          return const _LoadingSliver();
        }
        if (snap.hasError) {
          return _ErrorSliver(message: snap.error.toString());
        }
        final (active, upcoming) = snap.data ?? (null, <Enrollment>[]);
        return _ApuntadosTab(active: active, upcoming: upcoming);
      },
    );
  }
}

class _ParticipadosStream extends StatelessWidget {
  final String uid;
  const _ParticipadosStream({required this.uid});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<(PlayerStats stats, List<TournamentResult> results)>(
      stream: EventosService.watchClienteParticipados(uid),
      builder: (context, snap) {
        if (snap.connectionState == ConnectionState.waiting) {
          return const _LoadingSliver();
        }
        if (snap.hasError) {
          return _ErrorSliver(message: snap.error.toString());
        }
        final (stats, results) = snap.data ??
            (const PlayerStats(played: 0, podiums: 0, titles: 0),
                <TournamentResult>[]);
        return _ParticipadosTab(stats: stats, results: results);
      },
    );
  }
}

// ── Tab content ───────────────────────────────────────────────────────────────

class _TabPill extends StatelessWidget {
  final String label;
  final bool active;
  final VoidCallback onTap;
  const _TabPill(
      {required this.label, required this.active, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          height: 38,
          decoration: BoxDecoration(
            gradient: active
                ? const LinearGradient(colors: AppColors.clienteGradient)
                : null,
            borderRadius: BorderRadius.circular(999),
            boxShadow: active
                ? [
                    BoxShadow(
                      color: AppColors.blue.withValues(alpha: 0.35),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ]
                : null,
          ),
          child: Center(
            child: Text(
              label,
              style: GoogleFonts.rubik(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ApuntadosTab extends StatelessWidget {
  final Enrollment? active;
  final List<Enrollment> upcoming;
  const _ApuntadosTab({required this.active, required this.upcoming});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (active != null) ...[
          BrawlCard(
            padding: EdgeInsets.zero,
            radius: 26,
            tint: const Color(0xFF0F0C1A),
            border: Colors.transparent,
            child: Column(
              children: [
                Container(
                  height: 130,
                  decoration: const BoxDecoration(
                    borderRadius:
                        BorderRadius.vertical(top: Radius.circular(26)),
                  ),
                  child: Stack(
                    children: [
                      Positioned(
                        top: -30,
                        right: -40,
                        child: Container(
                          width: 200,
                          height: 200,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: RadialGradient(
                              colors: [
                                AppColors.cyan.withValues(alpha: 0.5),
                                AppColors.violet.withValues(alpha: 0.3),
                                Colors.transparent,
                              ],
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        bottom: 14,
                        left: 14,
                        child: GameBadge(game: active!.game.code, size: 36),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(18, 14, 18, 18),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        active!.tournamentName,
                        style: GoogleFonts.rubik(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: AppColors.text,
                          letterSpacing: -0.3,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        active!.storeName,
                        style: GoogleFonts.rubik(
                          fontSize: 13,
                          color: AppColors.textDim,
                        ),
                      ),
                      const SizedBox(height: 14),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Row(
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    active!.dateLabel,
                                    style: GoogleFonts.rubik(
                                      fontSize: 10,
                                      color: AppColors.textMute,
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                                  Text(
                                    active!.timeLabel,
                                    style: GoogleFonts.rubik(
                                      fontSize: 20,
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.text,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(width: 18),
                              Container(
                                  width: 1,
                                  height: 36,
                                  color: AppColors.stroke),
                              const SizedBox(width: 18),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'MESA',
                                    style: GoogleFonts.rubik(
                                      fontSize: 10,
                                      color: AppColors.textMute,
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                                  Text(
                                    active!.tableLabel,
                                    style: GoogleFonts.rubik(
                                      fontSize: 20,
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.text,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          GradBtn(
                            size: GradBtnSize.sm,
                            child: const Text('Ver →'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ] else ...[
          _EmptyState(
            icon: '📅',
            message: 'No tienes torneos próximos',
            sub: 'Usa el botón ＋ para inscribirte con un código',
          ),
        ],
        SectionLabel(
          'Próximos (${upcoming.length})',
          margin: const EdgeInsets.only(left: 4, top: 18, bottom: 10),
        ),
        if (upcoming.isEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 8, bottom: 20),
            child: Text(
              'Aquí aparecerán tus próximas inscripciones aceptadas.',
              style: GoogleFonts.rubik(
                  fontSize: 13, color: AppColors.textMute),
            ),
          )
        else
          ...upcoming.map((e) => _EventRow(enrollment: e)),
        const SizedBox(height: 20),
      ],
    );
  }
}

class _EventRow extends StatelessWidget {
  final Enrollment enrollment;
  const _EventRow({required this.enrollment});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: BrawlCard(
        radius: 20,
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            GameBadge(game: enrollment.game.code, size: 44),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    enrollment.tournamentName,
                    style: GoogleFonts.rubik(
                      fontSize: 14.5,
                      fontWeight: FontWeight.w600,
                      color: AppColors.text,
                    ),
                  ),
                  const SizedBox(height: 1),
                  Text(
                    enrollment.storeName,
                    style: GoogleFonts.rubik(
                        fontSize: 12, color: AppColors.textDim),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      if (enrollment.tagLabel != null) ...[
                        BrawlTag(
                          label: enrollment.tagLabel!,
                          color: enrollment.tagColor ?? AppColors.textMute,
                        ),
                        const SizedBox(width: 8),
                      ],
                      Text(
                        '${enrollment.dateLabel} · ${enrollment.timeLabel}',
                        style: GoogleFonts.rubik(
                            fontSize: 11, color: AppColors.textMute),
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

class _ParticipadosTab extends StatelessWidget {
  final PlayerStats stats;
  final List<TournamentResult> results;
  const _ParticipadosTab(
      {required this.stats, required this.results});

  @override
  Widget build(BuildContext context) {
    if (stats.played == 0) {
      return _EmptyState(
        icon: '🏆',
        message: 'Aún no has participado',
        sub: 'Tus resultados de torneos aparecerán aquí',
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            _StatCard(number: stats.played.toString(), label: 'Jugados'),
            const SizedBox(width: 10),
            _StatCard(number: stats.podiums.toString(), label: 'Podios'),
            const SizedBox(width: 10),
            _StatCard(number: stats.titles.toString(), label: 'Títulos'),
          ],
        ),
        const SizedBox(height: 14),
        ...results.map((r) => _ResultRow(result: r)),
        const SizedBox(height: 20),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  final String number, label;
  const _StatCard({required this.number, required this.label});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: BrawlCard(
        padding: const EdgeInsets.all(14),
        radius: 18,
        child: Column(
          children: [
            GradText(
              text: number,
              style: GoogleFonts.rubik(
                fontSize: 24,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label.toUpperCase(),
              style: GoogleFonts.rubik(
                fontSize: 10.5,
                color: AppColors.textMute,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ResultRow extends StatelessWidget {
  final TournamentResult result;
  const _ResultRow({required this.result});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: BrawlCard(
        radius: 20,
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            GameBadge(game: result.game.code, size: 40),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    result.tournamentName,
                    style: GoogleFonts.rubik(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.text,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    result.dateLabel,
                    style: GoogleFonts.rubik(
                        fontSize: 11, color: AppColors.textMute),
                  ),
                ],
              ),
            ),
            Text(
              result.positionLabel,
              style: GoogleFonts.rubik(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: result.isTop ? AppColors.cyan : AppColors.text,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Shared helpers ─────────────────────────────────────────────────────────────

class _LoadingSliver extends StatelessWidget {
  const _LoadingSliver();

  @override
  Widget build(BuildContext context) => const SizedBox(
        height: 200,
        child: Center(
            child: CircularProgressIndicator(color: AppColors.cyan)),
      );
}

class _ErrorSliver extends StatelessWidget {
  final String message;
  const _ErrorSliver({required this.message});

  @override
  Widget build(BuildContext context) => SizedBox(
        height: 200,
        child: Center(
          child: Text(
            'Error al cargar datos',
            style: GoogleFonts.rubik(
                fontSize: 13, color: AppColors.textMute),
          ),
        ),
      );
}

class _EmptyState extends StatelessWidget {
  final String icon, message, sub;
  const _EmptyState(
      {required this.icon, required this.message, required this.sub});

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 24),
        child: BrawlCard(
          padding: const EdgeInsets.all(24),
          radius: 22,
          child: Column(
            children: [
              Text(icon, style: const TextStyle(fontSize: 36)),
              const SizedBox(height: 12),
              Text(
                message,
                style: GoogleFonts.rubik(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: AppColors.text,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                sub,
                textAlign: TextAlign.center,
                style: GoogleFonts.rubik(
                    fontSize: 12, color: AppColors.textMute),
              ),
            ],
          ),
        ),
      );
}
