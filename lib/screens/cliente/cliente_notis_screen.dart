import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../theme/app_colors.dart';
import '../../widgets/brawl_widgets.dart';

class ClienteNotisScreen extends StatelessWidget {
  const ClienteNotisScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: BrawlBackground(
        seed: 22,
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(22, 18, 22, 18),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Notificaciones',
                      style: GoogleFonts.rubik(
                        fontSize: 28,
                        fontWeight: FontWeight.w700,
                        color: AppColors.text,
                        letterSpacing: -0.5,
                      ),
                    ),
                    Text(
                      'Marcar leídas',
                      style: GoogleFonts.rubik(fontSize: 12, color: AppColors.textDim),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(22, 0, 22, 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Hero next event
                      BrawlCard(
                        padding: EdgeInsets.zero,
                        radius: 26,
                        tint: const Color(0xFF1A1228),
                        border: AppColors.violet.withValues(alpha: 0.25),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Stack(
                            children: [
                              Positioned(
                                top: -40,
                                right: -40,
                                child: Container(
                                  width: 140,
                                  height: 140,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    gradient: RadialGradient(
                                      colors: [
                                        AppColors.cyan.withValues(alpha: 0.5),
                                        AppColors.violet.withValues(alpha: 0.3),
                                        Colors.transparent,
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  BrawlTag(label: '⏱ En 1h 42min', color: AppColors.cyan),
                                  const SizedBox(height: 10),
                                  Text(
                                    'Pioneer FNM\nempieza pronto',
                                    style: GoogleFonts.rubik(
                                      fontSize: 22,
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.text,
                                      letterSpacing: -0.3,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Dragón Rojo Store · 2,3 km',
                                    style: GoogleFonts.rubik(fontSize: 12.5, color: AppColors.textDim),
                                  ),
                                  const SizedBox(height: 14),
                                  Row(
                                    children: [
                                      GradBtn(size: GradBtnSize.sm, child: const Text('Ir ahora →')),
                                      const SizedBox(width: 8),
                                      Container(
                                        height: 36,
                                        padding: const EdgeInsets.symmetric(horizontal: 14),
                                        decoration: BoxDecoration(
                                          color: AppColors.surface,
                                          borderRadius: BorderRadius.circular(999),
                                          border: Border.all(color: AppColors.stroke),
                                        ),
                                        child: Center(
                                          child: Text(
                                            'Cómo llegar',
                                            style: GoogleFonts.rubik(
                                                fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.text),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SectionLabel('Hoy', margin: EdgeInsets.only(left: 4, bottom: 10, top: 0)),
                      ..._todayNotis.map((n) => _NotiRow(data: n)),
                      const SectionLabel('Esta semana', margin: EdgeInsets.only(left: 4, bottom: 10, top: 14)),
                      ..._weekNotis.map((n) => _NotiRow(data: n, dim: true)),
                    ],
                  ),
                ),
              ),
              BrawlTabBar(
                active: 3,
                tabs: const [
                  BrawlTabBarItem(icon: '◎', label: 'Eventos'),
                  BrawlTabBarItem(icon: '⬡', label: 'Buscar'),
                  BrawlTabBarItem(icon: '＃', label: 'Código'),
                  BrawlTabBarItem(icon: '♢', label: 'Perfil'),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NotiData {
  final String icon, title, body, time;
  final Color color;
  final bool unread;
  const _NotiData({
    required this.icon,
    required this.color,
    required this.title,
    required this.body,
    required this.time,
    this.unread = false,
  });
}

const _todayNotis = [
  _NotiData(icon: '⏰', color: AppColors.cyan, title: 'Torneo en 1h 42min', body: 'Pioneer FNM · Dragón Rojo Store', time: 'hace 5 min', unread: true),
  _NotiData(icon: '✦', color: AppColors.violet, title: 'Nuevo torneo de Yu-Gi-Oh!', body: 'El Refugio ha publicado un torneo para el domingo', time: 'hace 1h', unread: true),
  _NotiData(icon: '⚔', color: AppColors.pink, title: 'Emparejamiento disponible', body: 'Ronda 2 contra Laura M. · Mesa 14', time: 'hace 2h', unread: true),
  _NotiData(icon: '🏆', color: AppColors.yellow, title: 'Resultado publicado', body: 'Terminaste 2º en Commander Night. Premio: 15 € en tienda', time: 'Ayer'),
];

const _weekNotis = [
  _NotiData(icon: '📍', color: AppColors.blue, title: 'Nueva tienda cerca', body: 'Puzzle Games ha abierto a 1,2 km de ti', time: 'Mar'),
  _NotiData(icon: '✎', color: AppColors.orange, title: 'Reglas actualizadas', body: 'Magic Standard · nueva ban list el 28 Abr', time: 'Lun'),
];

class _NotiRow extends StatelessWidget {
  final _NotiData data;
  final bool dim;
  const _NotiRow({required this.data, this.dim = false});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: data.unread ? AppColors.surface : Colors.transparent,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: data.unread ? AppColors.stroke : Colors.transparent,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: data.color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: data.color.withValues(alpha: 0.2)),
              ),
              child: Center(
                child: Text(data.icon, style: const TextStyle(fontSize: 18)),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          data.title,
                          style: GoogleFonts.rubik(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: dim ? AppColors.textDim : AppColors.text,
                          ),
                        ),
                      ),
                      Text(
                        data.time,
                        style: GoogleFonts.rubik(fontSize: 10.5, color: AppColors.textMute),
                      ),
                    ],
                  ),
                  const SizedBox(height: 3),
                  Text(
                    data.body,
                    style: GoogleFonts.rubik(
                      fontSize: 12.5,
                      color: dim ? AppColors.textMute : AppColors.textDim,
                      height: 1.35,
                    ),
                  ),
                ],
              ),
            ),
            if (data.unread)
              Padding(
                padding: const EdgeInsets.only(left: 8),
                child: Container(
                  width: 6,
                  height: 6,
                  decoration: BoxDecoration(shape: BoxShape.circle, color: data.color),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
