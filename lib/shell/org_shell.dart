import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:brawl_tcg/core/theme/app_colors.dart';
import 'package:brawl_tcg/core/widgets/brawl_widgets.dart';
import 'package:brawl_tcg/core/navigation/transitions.dart';
import 'package:brawl_tcg/features/eventos/org_eventos_screen.dart';
import 'package:brawl_tcg/features/tienda/org_tienda_screen.dart';
import 'package:brawl_tcg/features/reglas/reglas_screen.dart';
import 'package:brawl_tcg/features/config/config_screen.dart';
import 'package:brawl_tcg/features/notificaciones/data/notification.dart';
import 'package:brawl_tcg/features/notificaciones/services/notificaciones_service.dart';
import 'package:brawl_tcg/features/notificaciones/shared_notis_screen.dart';

class OrgShell extends StatefulWidget {
  const OrgShell({super.key});

  @override
  State<OrgShell> createState() => _OrgShellState();
}

class _OrgShellState extends State<OrgShell> {
  int _tab = 0;
  String? _uid;
  StreamSubscription<NotiBundle>? _notiSub;
  final Set<String> _seenIds = {};
  bool _initialized = false;
  OverlayEntry? _bannerEntry;

  static const _tabs = [
    BrawlTabBarItem(icon: '◈', label: 'Eventos'),
    BrawlTabBarItem(icon: '⌂', label: 'Tienda'),
    BrawlTabBarItem(icon: '＃', label: 'Reglas'),
    BrawlTabBarItem(icon: '♢', label: 'Perfil'),
  ];

  static const _screens = [
    OrgEventosScreen(),
    OrgTiendaScreen(),
    SharedReglasScreen(),
    SharedConfigScreen(isOrg: true),
  ];

  @override
  void initState() {
    super.initState();
    _uid = FirebaseAuth.instance.currentUser?.uid;
    if (_uid != null) _startListening();
  }

  void _startListening() {
    _notiSub =
        NotificacionesService.watchNotifications(_uid!).listen((bundle) {
      // Primera emisión: solo guardo los IDs ya existentes, no muestro banner
      if (!_initialized) {
        for (final n in [...bundle.today, ...bundle.yesterday]) {
          _seenIds.add(n.id);
        }
        _initialized = true;
        return;
      }

      // Busco notificaciones nuevas que no haya visto antes
      final all = [...bundle.today, ...bundle.yesterday];
      for (final n in all) {
        if (!_seenIds.contains(n.id)) {
          _seenIds.add(n.id);
          if (!n.isRead) _showBanner(n);
          break;
        }
      }
    });
  }

  void _showBanner(AppNotification notif) {
    if (!mounted) return;
    _dismissBanner();

    _bannerEntry = OverlayEntry(
      builder: (_) => _NotiBanner(
        notification: notif,
        onDismiss: _dismissBanner,
        onTap: () {
          _dismissBanner();
          Navigator.push(
            context,
            fadeSlideRoute(const SharedNotisScreen()),
          );
        },
      ),
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || _bannerEntry == null) return;
      Overlay.of(context, rootOverlay: true).insert(_bannerEntry!);
      Future.delayed(const Duration(seconds: 5), _dismissBanner);
    });
  }

  void _dismissBanner() {
    _bannerEntry?.remove();
    _bannerEntry = null;
  }

  @override
  void dispose() {
    _notiSub?.cancel();
    _dismissBanner();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth >= 1024) {
          return BrawlDesktopShell(
            tab: _tab,
            tabs: _tabs,
            screens: _screens,
            accent: AppColors.organizadorGradient,
            roleLabel: 'ORGANIZADOR',
            onTabChange: (i) => setState(() => _tab = i),
          );
        }
        return Stack(
          children: [
            IndexedStack(index: _tab, children: _screens),
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: BrawlTabBar(
                active: _tab,
                tabs: _tabs,
                accent: AppColors.organizadorGradient,
                onTap: (i) => setState(() => _tab = i),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _NotiBanner extends StatefulWidget {
  final AppNotification notification;
  final VoidCallback onDismiss;
  final VoidCallback onTap;

  const _NotiBanner({
    required this.notification,
    required this.onDismiss,
    required this.onTap,
  });

  @override
  State<_NotiBanner> createState() => _NotiBannerState();
}

class _NotiBannerState extends State<_NotiBanner>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<Offset> _slide;
  late Animation<double> _fade;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 350),
    );
    _slide = Tween<Offset>(
      begin: const Offset(0, -1),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOutCubic));
    _fade = CurvedAnimation(parent: _ctrl, curve: Curves.easeIn);
    _ctrl.forward();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final n = widget.notification;
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(14, 10, 14, 0),
        child: SlideTransition(
          position: _slide,
          child: FadeTransition(
            opacity: _fade,
            child: GestureDetector(
              onTap: widget.onTap,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: n.color.withValues(alpha: 0.35)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.35),
                      blurRadius: 20,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      width: 38,
                      height: 38,
                      decoration: BoxDecoration(
                        color: n.color.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: n.color.withValues(alpha: 0.25)),
                      ),
                      child: Center(
                        child: Text(n.icon,
                            style: TextStyle(fontSize: 16, color: n.color)),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            n.title,
                            style: GoogleFonts.rubik(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: AppColors.text,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            n.body,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.rubik(
                              fontSize: 12,
                              color: AppColors.textDim,
                              height: 1.3,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    GestureDetector(
                      onTap: widget.onDismiss,
                      child: Padding(
                        padding: const EdgeInsets.all(4),
                        child: Text('✕',
                            style: TextStyle(
                                fontSize: 12, color: AppColors.textMute)),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}