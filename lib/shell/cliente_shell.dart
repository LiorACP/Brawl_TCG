import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:brawl_tcg/core/l10n/app_l10n.dart';
import 'package:brawl_tcg/core/state/app_prefs_notifier.dart';
import 'package:brawl_tcg/core/theme/app_colors.dart';
import 'package:brawl_tcg/core/widgets/brawl_widgets.dart';
import 'package:brawl_tcg/core/navigation/transitions.dart';
import 'package:brawl_tcg/features/eventos/cliente_eventos_screen.dart';
import 'package:brawl_tcg/features/eventos/cliente_vs_screen.dart';
import 'package:brawl_tcg/features/eventos/cliente_espera_screen.dart';
import 'package:brawl_tcg/features/eventos/services/torneo_live_service.dart';
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
  StreamSubscription<LiveMatchData?>? _matchSub;
  final Set<String> _seenIds = {};
  bool _initialized = false;
  OverlayEntry? _bannerEntry;
  LiveMatchData? _liveMatch;
  String? _lastShownMatchId;

  List<BrawlTabBarItem> get _tabs => [
        BrawlTabBarItem(icon: '◎', label: L10n.t('Eventos')),
        BrawlTabBarItem(icon: '⬡', label: L10n.t('Mapa')),
        BrawlTabBarItem(icon: '＃', label: L10n.t('Reglas')),
        BrawlTabBarItem(icon: '♢', label: L10n.t('Perfil')),
      ];

  // No const: Flutter crea nuevas instancias en cada build, permitiendo
  // que el diffing propague los cambios de tema/idioma a los hijos.
  List<Widget> get _screens => const [
        ClienteEventosScreen(),
        ClienteMapaScreen(),
        SharedReglasScreen(),
        SharedConfigScreen(isOrg: false),
      ];

  @override
  void initState() {
    super.initState();
    _uid = FirebaseAuth.instance.currentUser?.uid;
    AppPrefsNotifier.instance.addListener(_onPrefsChanged);
    if (_uid != null) {
      _startListening();
      _startMatchListener();
    }
  }

  void _onPrefsChanged() {
    if (mounted) setState(() {});
  }

  void _startMatchListener() {
    _matchSub =
        TorneoLiveService.watchLiveMatch(_uid!).listen(_onLiveMatch);
  }

  void _onLiveMatch(LiveMatchData? data) {
    if (!mounted) return;
    setState(() => _liveMatch = data);

    // Nueva ronda detectada: matchId cambia y active = true
    if (data != null && data.active && data.matchId != _lastShownMatchId) {
      _lastShownMatchId = data.matchId;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        Navigator.push(
          context,
          slideRoute(ClienteVsScreen(matchData: data)),
        );
      });
    }
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
    AppPrefsNotifier.instance.removeListener(_onPrefsChanged);
    _notiSub?.cancel();
    _matchSub?.cancel();
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
            // Botón flotante "Volver a la ronda" cuando hay partida activa
            if (_liveMatch != null)
              Positioned(
                top: MediaQuery.of(context).padding.top + 10,
                left: 16,
                right: 16,
                child: GestureDetector(
                  onTap: () {
                    final m = _liveMatch!;
                    if (!m.roundFinished) {
                      Navigator.push(context,
                          slideRoute(ClienteVsScreen(matchData: m)));
                    } else {
                      Navigator.push(context,
                          slideRoute(ClienteEsperaScreen(matchData: m)));
                    }
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 10),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                          colors: AppColors.clienteGradient),
                      borderRadius: BorderRadius.circular(14),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.cyan.withValues(alpha: 0.35),
                          blurRadius: 16,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.sports_esports,
                            color: Colors.white, size: 16),
                        const SizedBox(width: 8),
                        Text(
                          _liveMatch!.roundFinished
                              ? 'Esperando resultados · Ronda ${_liveMatch!.roundNum}'
                              : '⚔  Ronda ${_liveMatch!.roundNum} en curso · Volver',
                          style: GoogleFonts.rubik(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}