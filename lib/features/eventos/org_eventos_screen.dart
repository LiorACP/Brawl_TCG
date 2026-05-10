import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:brawl_tcg/core/l10n/app_l10n.dart';
import 'package:brawl_tcg/core/theme/app_colors.dart';
import 'package:brawl_tcg/core/widgets/brawl_widgets.dart';
import 'package:brawl_tcg/core/navigation/transitions.dart';
import 'package:brawl_tcg/features/notificaciones/shared_notis_screen.dart';
import 'package:brawl_tcg/features/notificaciones/services/notificaciones_service.dart';
import 'package:brawl_tcg/features/eventos/org_info_screen.dart';
import 'package:brawl_tcg/features/eventos/org_crear_screen.dart';
import 'package:brawl_tcg/features/premios/org_premios_screen.dart';
import 'package:brawl_tcg/features/anuncios/org_anuncios_screen.dart';
import 'data/tournament.dart';
import 'data/org_kpi.dart';
import 'services/eventos_service.dart';
import 'org_inscripciones_screen.dart';
import 'org_participantes_screen.dart';
import 'org_ranking_screen.dart';
import 'services/torneo_live_service.dart';

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
      final name =
          doc.data()?['name'] as String? ??
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

  void _showTournamentOptions(Tournament t) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          border: Border.all(color: AppColors.stroke),
        ),
        padding: const EdgeInsets.fromLTRB(22, 16, 22, 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.stroke,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              t.name,
              style: GoogleFonts.rubik(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: AppColors.text,
              ),
            ),
            const SizedBox(height: 16),
            _OptionRow(
              icon: '✉',
              label: L10n.t('Ver inscripciones pendientes'),
              color: AppColors.violet,
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  fadeSlideRoute(OrgInscripcionesScreen(tournament: t)),
                );
              },
            ),
            const SizedBox(height: 2),
            _OptionRow(
              icon: '👥',
              label: L10n.t('Ver participantes'),
              color: AppColors.cyan,
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  fadeSlideRoute(OrgParticipantesScreen(tournament: t)),
                );
              },
            ),
            const SizedBox(height: 2),
            _OptionRow(
              icon: '✎',
              label: L10n.t('Editar torneo'),
              color: AppColors.cyan,
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  fadeSlideRoute(
                    OrgAnunciosScreen(isCreationFlow: false, eventId: t.id),
                  ),
                );
              },
            ),
            const SizedBox(height: 2),
            _OptionRow(
              icon: '🗑',
              label: L10n.t('Eliminar torneo'),
              color: AppColors.pink,
              onTap: () {
                Navigator.pop(context);
                _confirmDeleteTournament(t);
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _confirmDeleteTournament(Tournament t) async {
    final confirm = await _showDeleteDialog(L10n.t('Eliminar torneo'), t.name);
    if (confirm != true) return;
    await _doDeleteTournament(t, notifyPlayers: true);
  }

  Future<void> _deleteDraft(Tournament t) async {
    final confirm = await _showDeleteDialog(L10n.t('Eliminar borrador'), t.name);
    if (confirm != true) return;
    await _doDeleteTournament(t, notifyPlayers: false);
  }

  Future<bool?> _showDeleteDialog(String title, String name) {
    return showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          title,
          style: GoogleFonts.rubik(
              fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.text),
        ),
        content: Text(
          '¿Seguro que quieres eliminar "$name"? Esta acción no se puede deshacer.',
          style: GoogleFonts.rubik(fontSize: 13, color: AppColors.textDim),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(L10n.t('Cancelar'),
                style:
                    GoogleFonts.rubik(fontSize: 13, color: AppColors.textMute)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(L10n.t('Eliminar'),
                style: GoogleFonts.rubik(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: AppColors.pink)),
          ),
        ],
      ),
    );
  }

  Future<void> _doDeleteTournament(Tournament t,
      {required bool notifyPlayers}) async {
    final db = FirebaseFirestore.instance;
    final tournRef = db.collection('Tournaments').doc(t.id);

    // 1. Inscripciones: notificar jugadores activos y borrar documentos
    final regSnap = await tournRef.collection('registration').get();
    var batch = db.batch();
    int ops = 0;

    for (final regDoc in regSnap.docs) {
      if (notifyPlayers) {
        final status = regDoc.data()['status'] as String?;
        if (status == 'Pending' || status == 'Accepted') {
          final playerRef = regDoc.data()['userId'] as DocumentReference?;
          if (playerRef != null) {
            db.collection('Notifications').add({
              'userID': playerRef,
              'date': FieldValue.serverTimestamp(),
              'type': 'torneo_cancelado',
              'title': 'Torneo cancelado',
              'mensaje': 'El torneo "${t.name}" ha sido cancelado.',
              'icon': '❌',
              'isRead': false,
              'tournamentId': t.id,
            });
          }
        }
      }
      batch.delete(regDoc.reference);
      if (++ops == 499) {
        await batch.commit();
        batch = db.batch();
        ops = 0;
      }
    }

    // 2. Rondas y partidas anidadas
    final roundsSnap = await tournRef.collection('rounds').get();
    for (final roundDoc in roundsSnap.docs) {
      final matchesSnap =
          await roundDoc.reference.collection('matches').get();
      for (final matchDoc in matchesSnap.docs) {
        batch.delete(matchDoc.reference);
        if (++ops == 499) {
          await batch.commit();
          batch = db.batch();
          ops = 0;
        }
      }
      batch.delete(roundDoc.reference);
      if (++ops == 499) {
        await batch.commit();
        batch = db.batch();
        ops = 0;
      }
    }

    if (ops > 0) await batch.commit();

    // 3. Borrar el documento del torneo
    await tournRef.delete();
  }

  void _openDraft(Tournament t) {
    final Widget screen;
    if (t.format.isEmpty) {
      // Todavía no tiene formato, retomo desde el paso 2
      screen = OrgCrearScreen(
        eventId: t.id,
        eventName: t.name,
        eventDate: t.date ?? DateTime.now(),
      );
    } else if (t.prizeInfo == null || t.prizeInfo!.isEmpty) {
      // Ya tiene formato pero le faltan los premios, paso 3
      screen = OrgPremiosScreen(
        eventId: t.id,
        eventName: t.name,
        entryFee: t.entryFee ?? 0,
        plazas: t.totalSlots,
      );
    } else {
      // Todo configurado, solo le queda publicar
      screen = OrgAnunciosScreen(isCreationFlow: true, eventId: t.id);
    }
    Navigator.push(context, fadeSlideRoute(screen));
  }

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
                    // Cabecera con el nombre del organizador
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '$_storeName · ${L10n.t('ORGANIZADOR')}',
                              style: GoogleFonts.rubik(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textMute,
                                letterSpacing: 0.5,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              L10n.t('Eventos'),
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
                            _uid == null
                                ? _IconBtn(icon: '🔔', onTap: _openNotis)
                                : StreamBuilder<NotiBundle>(
                                    stream:
                                        NotificacionesService.watchNotifications(
                                          _uid!,
                                        ),
                                    builder: (ctx, snap) {
                                      final unread =
                                          snap.data?.unreadCount ?? 0;
                                      return Stack(
                                        clipBehavior: Clip.none,
                                        children: [
                                          _IconBtn(
                                            icon: '🔔',
                                            onTap: _openNotis,
                                          ),
                                          if (unread > 0)
                                            Positioned(
                                              top: -4,
                                              right: -4,
                                              child: Container(
                                                width: 16,
                                                height: 16,
                                                decoration: const BoxDecoration(
                                                  color: AppColors.pink,
                                                  shape: BoxShape.circle,
                                                ),
                                                child: Center(
                                                  child: Text(
                                                    unread > 9
                                                        ? '9+'
                                                        : '$unread',
                                                    style: const TextStyle(
                                                      fontSize: 9,
                                                      fontWeight:
                                                          FontWeight.w700,
                                                      color: Colors.white,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                        ],
                                      );
                                    },
                                  ),
                            const SizedBox(width: 8),
                            _IconBtn(icon: '📢', onTap: _openAnuncios),
                            const SizedBox(width: 8),
                            GradBtn(
                              size: GradBtnSize.sm,
                              gradient: AppColors.organizadorGradient,
                              onTap: _openCrear,
                              child: Text(L10n.t('＋ Crear')),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    // Fila de estadísticas rápidas
                    _uid == null
                        ? const _KpiSkeleton()
                        : StreamBuilder<OrgKpi>(
                            stream: EventosService.watchOrgKpi(_uid!),
                            builder: (ctx, snap) {
                              final kpi =
                                  snap.data ??
                                  const OrgKpi(
                                    todayCount: 0,
                                    totalEnrolled: 0,
                                    newEnrollments: 0,
                                    monthlyRevenue: 0,
                                  );
                              return Row(
                                children: [
                                  _KpiCard(
                                    label: L10n.t('Hoy'),
                                    value: kpi.todayCount.toString(),
                                    suffix: L10n.t('Torneos').toLowerCase(),
                                  ),
                                  const SizedBox(width: 8),
                                  _KpiCard(
                                    label: L10n.t('Inscritos'),
                                    value: kpi.totalEnrolled.toString(),
                                    badge: kpi.newEnrollments > 0
                                        ? '+${kpi.newEnrollments}'
                                        : null,
                                  ),
                                  const SizedBox(width: 8),
                                  _KpiCard(
                                    label: L10n.t('Este mes'),
                                    value: kpi.revenueLabel,
                                  ),
                                ],
                              );
                            },
                          ),
                    const SizedBox(height: 16),
                    // Fila de pestañas
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
              // Contenido que cambia según la pestaña activa
              Expanded(
                child: _uid == null
                    ? const Center(
                        child: CircularProgressIndicator(
                          color: AppColors.orange,
                        ),
                      )
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
              message: L10n.t('Sin torneos activos'),
              sub: L10n.t('Crea tu primer torneo con el botón ＋ Crear'),
              onAction: _openCrear,
              actionLabel: L10n.t('＋ Crear'),
            );
          }
          return _EnCursoContent(
            onCrear: _openCrear,
            onOptions: _showTournamentOptions,
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
            return _EmptyContent(
              icon: '✎',
              message: L10n.t('Sin borradores'),
              sub: L10n.t('Los torneos guardados sin publicar aparecerán aquí'),
            );
          }
          return _TournamentList(
            tournaments: snap.data!,
            onTap: _openDraft,
            onDelete: _deleteDraft,
          );
        },
      );
    }

    // Torneos que ya han terminado
    return StreamBuilder<List<Tournament>>(
      stream: EventosService.watchOrgByStatus(uid, 'Finished'),
      builder: (ctx, snap) {
        if (!snap.hasData) return const _LoadingContent();
        if (snap.data!.isEmpty) {
          return _EmptyContent(
            icon: '🏁',
            message: L10n.t('Sin torneos finalizados'),
            sub: L10n.t('Aquí verás el historial de torneos completados'),
          );
        }
        return _TournamentList(tournaments: snap.data!, finished: true);
      },
    );
  }
}

// Pestañas con contador en tiempo real de torneos

class _TabCountsRow extends StatelessWidget {
  final String uid;
  final String activeTab;
  final void Function(String) onTab;
  const _TabCountsRow({
    required this.uid,
    required this.activeTab,
    required this.onTab,
  });

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
                label: L10n.t('En curso'),
                count: c.enCurso,
                active: activeTab == 'encurso',
              ),
            ),
            const SizedBox(width: 16),
            GestureDetector(
              onTap: () => onTab('borradores'),
              child: _UnderlineTab(
                label: L10n.t('Borradores'),
                count: c.draft,
                active: activeTab == 'borradores',
              ),
            ),
            const SizedBox(width: 16),
            GestureDetector(
              onTap: () => onTab('finalizados'),
              child: _UnderlineTab(
                label: L10n.t('Finalizados'),
                count: c.finished,
                active: activeTab == 'finalizados',
              ),
            ),
          ],
        );
      },
    );
  }

  static Stream<_TabCounts> _watchCounts(String uid) {
    final orgRef = FirebaseFirestore.instance.collection('User').doc(uid);
    return FirebaseFirestore.instance
        .collection('Tournaments')
        .where('organizerId', isEqualTo: orgRef)
        .snapshots()
        .map((snap) {
          int enCurso = 0, draft = 0, finished = 0;
          for (final doc in snap.docs) {
            final status = (doc.data()['status'] as String? ?? '')
                .toLowerCase();
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

// Contenido de cada pestaña

class _EnCursoContent extends StatelessWidget {
  final VoidCallback onCrear;
  final void Function(Tournament) onOptions;
  final Tournament? liveTournament;
  final List<Tournament> upcomingTournaments;

  const _EnCursoContent({
    required this.onCrear,
    required this.onOptions,
    required this.liveTournament,
    required this.upcomingTournaments,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if (liveTournament != null) ...[
          _LiveCard(tournament: liveTournament!, onOptions: onOptions),
          const SizedBox(height: 12),
        ],
        ...upcomingTournaments.map(
          (t) => _UpcomingCard(tournament: t, onOptions: onOptions),
        ),
        const SizedBox(height: 20),
      ],
    );
  }
}

class _TournamentList extends StatelessWidget {
  final List<Tournament> tournaments;
  final bool finished;
  final void Function(Tournament)? onTap;
  final void Function(Tournament)? onDelete;
  const _TournamentList({
    required this.tournaments,
    this.finished = false,
    this.onTap,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ...tournaments.map(
          (t) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: GestureDetector(
              onTap: onTap != null ? () => onTap!(t) : null,
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
                      BrawlTag(label: L10n.t('Finalizado'), color: AppColors.textMute)
                    else ...[
                      if (onDelete != null)
                        GestureDetector(
                          onTap: () => onDelete!(t),
                          child: Container(
                            width: 30,
                            height: 30,
                            margin: const EdgeInsets.only(right: 8),
                            decoration: BoxDecoration(
                              color: AppColors.pink.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(9),
                              border: Border.all(
                                color: AppColors.pink.withValues(alpha: 0.25),
                              ),
                            ),
                            child: Center(
                              child: Text(
                                '🗑',
                                style: const TextStyle(fontSize: 13),
                              ),
                            ),
                          ),
                        ),
                      BrawlTag(label: L10n.t('Borrador'), color: AppColors.yellow),
                      if (onTap != null) ...[
                        const SizedBox(width: 8),
                        Text(
                          '›',
                          style: TextStyle(
                            fontSize: 20,
                            color: AppColors.textMute,
                          ),
                        ),
                      ],
                    ],
                  ],
                ),
              ),
            ),
          ),
        ),
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
    child: Center(child: CircularProgressIndicator(color: AppColors.orange)),
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
          Text(icon, style: TextStyle(fontSize: 36, color: AppColors.textMute)),
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
            style: GoogleFonts.rubik(fontSize: 12, color: AppColors.textMute),
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

// Widgets pequeños que se reutilizan en varios sitios

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
      child: Center(child: Text(icon, style: const TextStyle(fontSize: 15))),
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
      ),
    ),
  );
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

class _LiveCard extends StatefulWidget {
  final Tournament tournament;
  final void Function(Tournament) onOptions;
  const _LiveCard({required this.tournament, required this.onOptions});

  @override
  State<_LiveCard> createState() => _LiveCardState();
}

class _LiveCardState extends State<_LiveCard> {
  bool _finalizando = false;

  Future<void> _confirmarFinalizar() async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: Text(L10n.t('Finalizar torneo'),
            style: GoogleFonts.rubik(
                color: AppColors.text, fontWeight: FontWeight.w700)),
        content: Text(
          '¿Seguro que quieres finalizar "${widget.tournament.name}"? '
          'Esta acción no se puede deshacer.',
          style: GoogleFonts.rubik(color: AppColors.textDim, fontSize: 14),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(L10n.t('Cancelar'),
                style: GoogleFonts.rubik(color: AppColors.textMute)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(L10n.t('Finalizar'),
                style: GoogleFonts.rubik(
                    color: AppColors.pink, fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
    if (ok != true || !mounted) return;
    setState(() => _finalizando = true);
    try {
      await TorneoLiveService.finalizarTorneo(widget.tournament.id);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(L10n.fmt('Error al finalizar: {e}', {'e': '$e'}))),
        );
      }
    } finally {
      if (mounted) setState(() => _finalizando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = widget.tournament;
    final progress = t.roundProgress ?? [];
    final currentRound = t.currentRound ?? 0;
    final totalRounds = t.totalRounds ?? 0;

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
                  L10n.fmt('EN VIVO · RONDA {r} / {t}', {'r': '$currentRound', 't': '$totalRounds'}),
                  style: GoogleFonts.rubik(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: AppColors.pink,
                    letterSpacing: 0.6,
                  ),
                ),
                const Spacer(),
                Text(
                  '⏱ ${t.liveTimer ?? '—'}',
                  style: GoogleFonts.rubikMonoOne(
                    fontSize: 11,
                    color: AppColors.textDim,
                  ),
                ),
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: () => Navigator.push(
                    context,
                    fadeSlideRoute(OrgRankingScreen(tournament: t)),
                  ),
                  child: Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      color: AppColors.cyan.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: AppColors.cyan.withValues(alpha: 0.3),
                      ),
                    ),
                    child: Center(
                      child: Icon(
                        Icons.visibility_outlined,
                        size: 15,
                        color: AppColors.cyan,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 6),
                GestureDetector(
                  onTap: () => widget.onOptions(t),
                  child: Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      color: AppColors.surfaceHi,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Center(
                      child: Text(
                        '⋯',
                        style: TextStyle(
                          fontSize: 14,
                          color: AppColors.textDim,
                        ),
                      ),
                    ),
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
                    GameBadge(game: t.game.code, size: 42),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            t.name,
                            style: GoogleFonts.rubik(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: AppColors.text,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '${t.enrolledCount} inscritos · ${t.activeTables ?? 0} mesas activas',
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
                        L10n.fmt('Ronda {r} en juego', {'r': '$currentRound'}),
                        style: GoogleFonts.rubik(
                          fontSize: 11,
                          color: AppColors.textMute,
                        ),
                      ),
                      Text(
                        '${t.pendingResults ?? 0} resultados pendientes',
                        style: GoogleFonts.rubik(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: AppColors.cyan,
                        ),
                      ),
                    ],
                  ),
                ],
                const SizedBox(height: 14),
                SizedBox(
                  width: double.infinity,
                  child: GestureDetector(
                    onTap: _finalizando ? null : _confirmarFinalizar,
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 11),
                      decoration: BoxDecoration(
                        color: AppColors.pink.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: AppColors.pink.withValues(alpha: 0.35),
                        ),
                      ),
                      child: Center(
                        child: _finalizando
                            ? SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: AppColors.pink,
                                ),
                              )
                            : Text(
                                L10n.t('Finalizar torneo'),
                                style: GoogleFonts.rubik(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.pink,
                                ),
                              ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _UpcomingCard extends StatefulWidget {
  final Tournament tournament;
  final void Function(Tournament) onOptions;
  const _UpcomingCard({required this.tournament, required this.onOptions});

  @override
  State<_UpcomingCard> createState() => _UpcomingCardState();
}

class _UpcomingCardState extends State<_UpcomingCard> {
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 30), (_) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  bool get _isReady {
    final date = widget.tournament.date;
    if (date == null) return false;
    final diff = date.difference(DateTime.now());
    return diff.inMinutes <= 15 && diff.inSeconds > 0;
  }

  String get _countdownLabel {
    final date = widget.tournament.date;
    if (date == null) return '00:00';
    final diff = date.difference(DateTime.now());
    if (diff.inSeconds <= 0) return '00:00';
    final mins = diff.inMinutes;
    final secs = diff.inSeconds % 60;
    return '${mins.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }

  bool _loading = false;

  void _iniciar() {
    if (_loading) return;
    setState(() => _loading = true);
    final orgId =
        widget.tournament.organizerId ??
        FirebaseAuth.instance.currentUser?.uid ??
        '';
    TorneoLiveService.startRound(
      tournamentId: widget.tournament.id,
      tournamentName: widget.tournament.name,
      organizerId: orgId,
      roundNum: 1,
      randomize: true,
    ).catchError((e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(L10n.fmt('Error al iniciar: {e}', {'e': '$e'}))),
        );
      }
    }).whenComplete(() {
      if (mounted) setState(() => _loading = false);
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isReady) {
      return _ReadyCard(
        tournament: widget.tournament,
        countdownLabel: _countdownLabel,
        onIniciar: _loading ? null : _iniciar,
        onOptions: widget.onOptions,
        loading: _loading,
      );
    }
    return _UpcomingCardBody(
      tournament: widget.tournament,
      onOptions: widget.onOptions,
    );
  }
}

class _UpcomingCardBody extends StatelessWidget {
  final Tournament tournament;
  final void Function(Tournament) onOptions;
  const _UpcomingCardBody({required this.tournament, required this.onOptions});

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
                      const SizedBox(width: 8),
                      GestureDetector(
                        onTap: () => onOptions(tournament),
                        child: Container(
                          width: 28,
                          height: 28,
                          decoration: BoxDecoration(
                            color: AppColors.surfaceHi,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Center(
                            child: Text(
                              '⋯',
                              style: TextStyle(
                                fontSize: 14,
                                color: AppColors.textDim,
                              ),
                            ),
                          ),
                        ),
                      ),
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
                  if (tournament.accessCode != null) ...[
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Text(
                          'Código: ',
                          style: GoogleFonts.rubik(
                            fontSize: 11,
                            color: AppColors.textMute,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 7,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.violet.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(
                              color: AppColors.violet.withValues(alpha: 0.35),
                            ),
                          ),
                          child: Text(
                            tournament.accessCode!,
                            style: GoogleFonts.rubikMonoOne(
                              fontSize: 11,
                              color: AppColors.violet,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
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
    );
  }
}

class _ReadyCard extends StatelessWidget {
  final Tournament tournament;
  final String countdownLabel;
  final VoidCallback? onIniciar;
  final void Function(Tournament) onOptions;
  final bool loading;
  const _ReadyCard({
    required this.tournament,
    required this.countdownLabel,
    required this.onIniciar,
    required this.onOptions,
    this.loading = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: BrawlCard(
        padding: EdgeInsets.zero,
        radius: 24,
        tint: const Color(0xFF110D1E),
        border: AppColors.pink.withValues(alpha: 0.4),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
              child: Row(
                children: [
                  _PulseDot(color: AppColors.pink),
                  const SizedBox(width: 10),
                  Text(
                    'LISTO PARA INICIAR',
                    style: GoogleFonts.rubik(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: AppColors.pink,
                      letterSpacing: 0.6,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    '⏱ $countdownLabel',
                    style: GoogleFonts.rubikMonoOne(
                      fontSize: 11,
                      color: AppColors.textDim,
                    ),
                  ),
                  const SizedBox(width: 10),
                  GestureDetector(
                    onTap: () => onOptions(tournament),
                    child: Container(
                      width: 28,
                      height: 28,
                      decoration: BoxDecoration(
                        color: AppColors.surfaceHi,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Center(
                        child: Text(
                          '⋯',
                          style: TextStyle(
                            fontSize: 14,
                            color: AppColors.textDim,
                          ),
                        ),
                      ),
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
                              '${tournament.enrolledCount} inscritos',
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
                    children: List.generate(
                      5,
                      (i) => Expanded(
                        child: Padding(
                          padding: const EdgeInsets.only(right: 4),
                          child: Container(
                            height: 6,
                            decoration: BoxDecoration(
                              color: AppColors.surfaceHi,
                              borderRadius: BorderRadius.circular(3),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  loading
                      ? const Center(
                          child: SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.5,
                              color: AppColors.orange,
                            ),
                          ),
                        )
                      : GradBtn(
                          gradient: AppColors.organizadorGradient,
                          onTap: onIniciar,
                          child: Text(
                            'Iniciar torneo',
                            style: GoogleFonts.rubik(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
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

class _OptionRow extends StatelessWidget {
  final String icon, label;
  final Color color;
  final VoidCallback onTap;
  const _OptionRow({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.07),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: color.withValues(alpha: 0.15)),
        ),
        child: Row(
          children: [
            Text(icon, style: const TextStyle(fontSize: 16)),
            const SizedBox(width: 12),
            Text(
              label,
              style: GoogleFonts.rubik(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: color,
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
