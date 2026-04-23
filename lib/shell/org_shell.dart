import 'package:flutter/material.dart';
import 'package:brawl_tcg/core/theme/app_colors.dart';
import 'package:brawl_tcg/core/widgets/brawl_widgets.dart';
import 'package:brawl_tcg/features/eventos/org_eventos_screen.dart';
import 'package:brawl_tcg/features/tienda/org_tienda_screen.dart';
import 'package:brawl_tcg/features/reglas/reglas_screen.dart';
import 'package:brawl_tcg/features/config/config_screen.dart';

class OrgShell extends StatefulWidget {
  const OrgShell({super.key});

  @override
  State<OrgShell> createState() => _OrgShellState();
}

class _OrgShellState extends State<OrgShell> {
  int _tab = 0;

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
