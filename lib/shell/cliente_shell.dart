import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:brawl_tcg/core/theme/app_colors.dart';
import 'package:brawl_tcg/core/widgets/brawl_widgets.dart';
import 'package:brawl_tcg/core/navigation/transitions.dart';
import 'package:brawl_tcg/features/eventos/cliente_eventos_screen.dart';
import 'package:brawl_tcg/features/mapa/mapa_screen.dart';
import 'package:brawl_tcg/features/reglas/reglas_screen.dart';
import 'package:brawl_tcg/features/config/config_screen.dart';
import 'package:brawl_tcg/features/notificaciones/data/notification.dart';
import 'package:brawl_tcg/features/notificaciones/services/notificaciones_service.dart';
import 'package:brawl_tcg/features/notificaciones/shared_notis_screen.dart';
import 'package:brawl_tcg/features/notificaciones/noti_banner.dart';

class ClienteShell extends StatefulWidget {
  const ClienteShell({super.key});

  @override
  State<ClienteShell> createState() => _ClienteShellState();
}

class _ClienteShellState extends State<ClienteShell> {
  int _tab = 0;
  String? _uid;
  StreamSubscription<NotiBundle>? _notiSub;
  final Set<String> _seenIds = {};
  bool _initialized = false;
  OverlayEntry? _bannerEntry;

  static const _tabs = [
    BrawlTabBarItem(icon: '◎', label: 'Eventos'),
    BrawlTabBarItem(icon: '⬡', label: 'Mapa'),
    BrawlTabBarItem(icon: '＃', label: 'Reglas'),
    BrawlTabBarItem(icon: '♢', label: 'Perfil'),
  ];

  static const _screens = [
    ClienteEventosScreen(),
    ClienteMapaScreen(),
    SharedReglasScreen(),
    SharedConfigScreen(isOrg: false),
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
      if (!_initialized) {
        for (final n in [...bundle.today, ...bundle.yesterday]) {
          _seenIds.add(n.id);
        }
        _initialized = true;
        return;
      }

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
            accent: AppColors.clienteGradient,
            roleLabel: 'CLIENTE',
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
                accent: AppColors.clienteGradient,
                onTap: (i) => setState(() => _tab = i),
              ),
            ),
          ],
        );
      },
    );
  }
}