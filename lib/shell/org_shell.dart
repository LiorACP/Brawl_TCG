import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:brawl_tcg/core/l10n/app_l10n.dart';
import 'package:brawl_tcg/core/state/app_prefs_notifier.dart';
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
import 'package:brawl_tcg/features/notificaciones/noti_banner.dart';

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

  List<BrawlTabBarItem> get _tabs => [
        BrawlTabBarItem(icon: '◈', label: L10n.t('Eventos')),
        BrawlTabBarItem(icon: '⌂', label: L10n.t('Tienda')),
        BrawlTabBarItem(icon: '＃', label: L10n.t('Reglas')),
        BrawlTabBarItem(icon: '♢', label: L10n.t('Perfil')),
      ];

  List<Widget> get _screens => const [
        OrgEventosScreen(),
        OrgTiendaScreen(),
        SharedReglasScreen(),
        SharedConfigScreen(isOrg: true),
      ];

  @override
  void initState() {
    super.initState();
    _uid = FirebaseAuth.instance.currentUser?.uid;
    AppPrefsNotifier.instance.addListener(_onPrefsChanged);
    if (_uid != null) _startListening();
  }

  void _onPrefsChanged() {
    if (mounted) setState(() {});
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
      builder: (_) => NotiBanner(
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
    AppPrefsNotifier.instance.removeListener(_onPrefsChanged);
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