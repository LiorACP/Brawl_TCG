import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:brawl_tcg/core/l10n/app_l10n.dart';
import 'package:brawl_tcg/core/theme/app_colors.dart';
import 'package:brawl_tcg/core/widgets/brawl_widgets.dart';
import 'package:brawl_tcg/core/navigation/transitions.dart';
import 'package:brawl_tcg/features/notificaciones/shared_notis_screen.dart';
import 'package:brawl_tcg/features/codigo/cliente_codigo_screen.dart';
import 'data/tournament.dart';
import 'data/enrollment.dart';
import 'services/eventos_service.dart';
import 'store_profile_sheet.dart';

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
                              L10n.fmt('HOLA, {name}', {'name': _userName}),
                              style: GoogleFonts.rubik(
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                                color: AppColors.textMute,
                                letterSpacing: 0.5,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              L10n.t('Mis eventos'),
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
                            label: L10n.t('Apuntados'),
                            active: _tab == 'apuntados',
                            onTap: () => setState(() => _tab = 'apuntados'),
                          ),
                          _TabPill(
                            label: L10n.t('Participados'),
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

// Clases que conectan los streams de Firestore con los widgets

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

// Contenido de cada pestaña

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
                color: active ? Colors.white : AppColors.text,
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
            padding: const EdgeInsets.all(16),
            radius: 22,
            tint: AppColors.bgDeep,
            border: Colors.transparent,
            child: Row(
              children: [
                GameBadge(game: active!.game.code, size: 48),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        active!.tournamentName,
                        style: GoogleFonts.rubik(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: AppColors.text,
                          letterSpacing: -0.2,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        active!.storeName,
                        style: GoogleFonts.rubik(
                            fontSize: 12, color: AppColors.textDim),
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(active!.dateLabel,
                                  style: GoogleFonts.rubik(
                                      fontSize: 9,
                                      color: AppColors.textMute,
                                      letterSpacing: 0.4)),
                              Text(active!.timeLabel,
                                  style: GoogleFonts.rubik(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.text)),
                            ],
                          ),
                          const SizedBox(width: 12),
                          Container(width: 1, height: 28, color: AppColors.stroke),
                          const SizedBox(width: 12),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(L10n.t('MESA'),
                                  style: GoogleFonts.rubik(
                                      fontSize: 9,
                                      color: AppColors.textMute,
                                      letterSpacing: 0.4)),
                              Text(active!.tableLabel,
                                  style: GoogleFonts.rubik(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.text)),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 10),
                GradBtn(
                  size: GradBtnSize.sm,
                  onTap: active!.organizerId != null
                      ? () => showStoreProfileSheet(
                            context,
                            organizerId: active!.organizerId!,
                          )
                      : null,
                  child: Text(L10n.t('Ver →')),
                ),
              ],
            ),
          ),
        ] else ...[
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.35,
            child: Center(
              child: _EmptyState(
                icon: '📅',
                message: L10n.t('No tienes torneos próximos'),
                sub: L10n.t('Usa el botón ＋ para inscribirte con un código'),
              ),
            ),
          ),
        ],
        SectionLabel(
          L10n.fmt('Próximos ({n})', {'n': '${upcoming.length}'}),
          margin: const EdgeInsets.only(left: 4, top: 18, bottom: 10),
        ),
        if (upcoming.isEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 8, bottom: 20),
            child: Text(
              L10n.t('Aquí aparecerán tus próximas inscripciones aceptadas.'),
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
        message: L10n.t('Aún no has participado'),
        sub: L10n.t('Tus resultados de torneos aparecerán aquí'),
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            _StatCard(number: stats.played.toString(), label: L10n.t('Jugados')),
            const SizedBox(width: 10),
            _StatCard(number: stats.podiums.toString(), label: L10n.t('Podios')),
            const SizedBox(width: 10),
            _StatCard(number: stats.titles.toString(), label: L10n.t('Títulos')),
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

// Widgets pequeños compartidos entre las distintas pestañas

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
            message,
            textAlign: TextAlign.center,
            style: GoogleFonts.rubik(
                fontSize: 12, color: AppColors.textMute),
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
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(icon, style: const TextStyle(fontSize: 36)),
              const SizedBox(height: 12),
              Text(
                message,
                textAlign: TextAlign.center,
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
