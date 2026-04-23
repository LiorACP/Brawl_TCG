import 'package:flutter/material.dart';
import 'package:brawl_tcg/core/theme/app_colors.dart';
import 'package:brawl_tcg/core/widgets/brawl_widgets.dart';
import 'package:brawl_tcg/features/eventos/cliente_eventos_screen.dart';
import 'package:brawl_tcg/features/mapa/mapa_screen.dart';
import 'package:brawl_tcg/features/reglas/reglas_screen.dart';
import 'package:brawl_tcg/features/config/config_screen.dart';

class ClienteShell extends StatefulWidget {
  const ClienteShell({super.key});

  @override
  State<ClienteShell> createState() => _ClienteShellState();
}

class _ClienteShellState extends State<ClienteShell> {
  int _tab = 0;

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
        // Mobile layout
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
