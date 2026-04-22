import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../widgets/brawl_widgets.dart';
import 'cliente_eventos_screen.dart';
import 'cliente_mapa_screen.dart';
import '../shared/shared_reglas_screen.dart';
import '../shared/shared_config_screen.dart';

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

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        IndexedStack(
          index: _tab,
          children: const [
            ClienteEventosScreen(),
            ClienteMapaScreen(),
            SharedReglasScreen(),
            SharedConfigScreen(isOrg: false),
          ],
        ),
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
  }
}
