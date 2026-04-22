import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../widgets/brawl_widgets.dart';
import 'org_eventos_screen.dart';
import 'org_tienda_screen.dart';
import '../shared/shared_reglas_screen.dart';
import '../shared/shared_config_screen.dart';

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

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        IndexedStack(
          index: _tab,
          children: const [
            OrgEventosScreen(),
            OrgTiendaScreen(),
            SharedReglasScreen(),
            SharedConfigScreen(isOrg: true),
          ],
        ),
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
  }
}
