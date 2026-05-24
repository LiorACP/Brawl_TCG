import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:brawl_tcg/core/l10n/app_l10n.dart';
import 'package:brawl_tcg/core/theme/app_colors.dart';
import 'package:brawl_tcg/core/widgets/brawl_widgets.dart';
import 'data/notification.dart';
import 'services/notificaciones_service.dart';

class SharedNotisScreen extends StatelessWidget {
  const SharedNotisScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser?.uid;

    return Scaffold(
      backgroundColor: AppColors.bg,
      body: BrawlBackground(
        seed: 77,
        child: SafeArea(
          child: uid == null
              ? const Center(
                  child: CircularProgressIndicator(color: AppColors.cyan),
                )
              : _NotisBody(uid: uid),
        ),
      ),
    );
  }
}

class _NotisBody extends StatefulWidget {
  final String uid;
  const _NotisBody({required this.uid});

  @override
  State<_NotisBody> createState() => _NotisBodyState();
}

class _NotisBodyState extends State<_NotisBody> {
  String _filter = 'all';

  @override
  void initState() {
    super.initState();
    NotificacionesService.markAllRead(widget.uid);
  }

  List<(String, String)> get _filters => [
        ('all', L10n.t('Todas')),
        ('events', L10n.t('Eventos')),
        ('results', L10n.t('Resultados')),
        ('social', L10n.t('Social')),
        ('system', L10n.t('Sistema')),
      ];

  List<AppNotification> _filtered(List<AppNotification> notis) {
    if (_filter == 'all') return notis;
    final type = switch (_filter) {
      'events' => NotificationType.event,
      'results' => NotificationType.result,
      'social' => NotificationType.social,
      'system' => NotificationType.system,
      _ => null,
    };
    if (type == null) return notis;
    return notis.where((n) => n.type == type).toList();
  }

  Future<void> _markAllRead() async {
    await NotificacionesService.markAllRead(widget.uid);
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<NotiBundle>(
      stream: NotificacionesService.watchNotifications(widget.uid),
      builder: (context, snap) {
        if (snap.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(color: AppColors.cyan),
          );
        }

        final bundle = snap.data ??
            (today: <AppNotification>[], yesterday: <AppNotification>[], unreadCount: 0);

        final todayVisible = _filtered(bundle.today);
        final yesterdayVisible = _filtered(bundle.yesterday);

        return Column(
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
                            Text(L10n.t('CENTRO'),
                                style: GoogleFonts.rubik(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.textMute,
                                    letterSpacing: 0.5)),
                            Text(L10n.t('Notificaciones'),
                                style: GoogleFonts.rubik(
                                    fontSize: 22,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.text,
                                    letterSpacing: -0.5)),
                          ],
                        ),
                      ),
                      if (bundle.unreadCount > 0)
                        GestureDetector(
                          onTap: _markAllRead,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 6),
                            decoration: BoxDecoration(
                              color: AppColors.surface,
                              borderRadius: BorderRadius.circular(999),
                              border: Border.all(color: AppColors.stroke),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  width: 6,
                                  height: 6,
                                  decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: AppColors.cyan),
                                ),
                                const SizedBox(width: 4),
                                Text(L10n.fmt('{n} sin leer',
                                        {'n': '${bundle.unreadCount}'}),
                                    style: GoogleFonts.rubik(
                                        fontSize: 11,
                                        color: AppColors.textDim)),
                              ],
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: _filters.map((f) {
                        final (key, label) = f;
                        return Padding(
                          padding: const EdgeInsets.only(right: 6),
                          child: GestureDetector(
                            onTap: () => setState(() => _filter = key),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 150),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 14, vertical: 7),
                              decoration: BoxDecoration(
                                gradient: _filter == key
                                    ? const LinearGradient(
                                        colors: AppColors.clienteGradient)
                                    : null,
                                color: _filter == key
                                    ? null
                                    : AppColors.surface,
                                borderRadius: BorderRadius.circular(999),
                                border: _filter == key
                                    ? null
                                    : Border.all(color: AppColors.stroke),
                              ),
                              child: Text(
                                label,
                                style: GoogleFonts.rubik(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: _filter == key
                                      ? Colors.white
                                      : AppColors.text,
                                ),
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                  const SizedBox(height: 4),
                ],
              ),
            ),
            Expanded(
              child: todayVisible.isEmpty && yesterdayVisible.isEmpty
                  ? _EmptyState(filter: _filter)
                  : SingleChildScrollView(
                      padding: const EdgeInsets.fromLTRB(22, 4, 22, 20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (todayVisible.isNotEmpty) ...[
                            SectionLabel(L10n.t('Hoy'),
                                margin:
                                    const EdgeInsets.only(left: 4, bottom: 10, top: 4)),
                            ...todayVisible.map(
                              (n) => _NotiItem(notification: n, unread: !n.isRead),
                            ),
                          ],
                          if (yesterdayVisible.isNotEmpty) ...[
                            SectionLabel(L10n.t('Ayer'),
                                margin: const EdgeInsets.only(
                                    left: 4, bottom: 10, top: 16)),
                            ...yesterdayVisible.map(
                              (n) =>
                                  _NotiItem(notification: n, unread: false, dim: true),
                            ),
                          ],
                          const SizedBox(height: 20),
                        ],
                      ),
                    ),
            ),
          ],
        );
      },
    );
  }
}

class _NotiItem extends StatelessWidget {
  final AppNotification notification;
  final bool unread;
  final bool dim;
  const _NotiItem({
    required this.notification,
    this.unread = false,
    this.dim = false,
  });

  Future<void> _openLink() async {
    final uri = Uri.tryParse(notification.link!);
    if (uri != null) await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  @override
  Widget build(BuildContext context) {
    final hasLink = notification.link != null && notification.link!.isNotEmpty;
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: GestureDetector(
        onTap: hasLink ? _openLink : null,
        child: Opacity(
        opacity: dim ? 0.85 : 1.0,
        child: Container(
          padding: const EdgeInsets.all(13),
          decoration: BoxDecoration(
            color: unread ? AppColors.surface : Colors.transparent,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
                color: unread ? AppColors.stroke : Colors.transparent),
          ),
          child: Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: notification.color
                      .withValues(alpha: unread ? 0.12 : 0.08),
                  borderRadius: BorderRadius.circular(13),
                  border: Border.all(
                      color: notification.color
                          .withValues(alpha: unread ? 0.2 : 0.13)),
                ),
                child: Center(
                  child: Text(notification.icon,
                      style: TextStyle(
                          fontSize: 16, color: notification.color)),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            notification.title,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.rubik(
                              fontSize: 13.5,
                              fontWeight: FontWeight.w600,
                              color: dim ? AppColors.textDim : AppColors.text,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(notification.timeLabel,
                            style: GoogleFonts.rubik(
                                fontSize: 10.5, color: AppColors.textMute)),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(notification.body,
                        style: GoogleFonts.rubik(
                          fontSize: 12,
                          color:
                              dim ? AppColors.textMute : AppColors.textDim,
                          height: 1.35,
                        )),
                  ],
                ),
              ),
              if (unread)
                Padding(
                  padding: const EdgeInsets.only(left: 8),
                  child: Container(
                    width: 6,
                    height: 6,
                    decoration: BoxDecoration(
                        shape: BoxShape.circle, color: notification.color),
                  ),
                ),
            ],
          ),
        ),
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final String filter;
  const _EmptyState({required this.filter});

  @override
  Widget build(BuildContext context) {
    final isFiltered = filter != 'all';
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('🔔', style: const TextStyle(fontSize: 40)),
            const SizedBox(height: 12),
            Text(
              isFiltered
                  ? L10n.t('Sin notificaciones de este tipo')
                  : L10n.t('Todo al día'),
              style: GoogleFonts.rubik(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: AppColors.text,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              isFiltered
                  ? L10n.t('No hay notificaciones recientes en esta categoría')
                  : L10n.t('No tienes notificaciones en las últimas 48h'),
              textAlign: TextAlign.center,
              style: GoogleFonts.rubik(fontSize: 12, color: AppColors.textMute),
            ),
          ],
        ),
      ),
    );
  }
}
