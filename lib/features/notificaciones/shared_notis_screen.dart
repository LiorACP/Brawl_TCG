import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:brawl_tcg/core/theme/app_colors.dart';
import 'package:brawl_tcg/core/widgets/brawl_widgets.dart';

class SharedNotisScreen extends StatefulWidget {
  const SharedNotisScreen({super.key});

  @override
  State<SharedNotisScreen> createState() => _SharedNotisScreenState();
}

class _SharedNotisScreenState extends State<SharedNotisScreen> {
  String _filter = 'all';

  static const _filters = [
    ('all', 'Todas'),
    ('events', 'Eventos'),
    ('results', 'Resultados'),
    ('social', 'Social'),
    ('system', 'Sistema'),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: BrawlBackground(
        seed: 77,
        child: SafeArea(
          child: Column(
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
                              Text('CENTRO',
                                  style: GoogleFonts.rubik(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.textMute,
                                      letterSpacing: 0.5)),
                              Text('Notificaciones',
                                  style: GoogleFonts.rubik(
                                      fontSize: 22,
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.text,
                                      letterSpacing: -0.5)),
                            ],
                          ),
                        ),
                        GestureDetector(
                          onTap: () => setState(() {}),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
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
                                  decoration:
                                      BoxDecoration(shape: BoxShape.circle, color: AppColors.cyan),
                                ),
                                const SizedBox(width: 4),
                                Text('5 sin leer',
                                    style: GoogleFonts.rubik(fontSize: 11, color: AppColors.textDim)),
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
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                                decoration: BoxDecoration(
                                  gradient: _filter == key
                                      ? const LinearGradient(colors: AppColors.clienteGradient)
                                      : null,
                                  color: _filter == key ? null : AppColors.surface,
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
                                    color: Colors.white,
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
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(22, 4, 22, 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SectionLabel('Hoy',
                          margin: EdgeInsets.only(left: 4, bottom: 10, top: 4)),
                      ..._todayNotis.map((n) => _NotiItem(data: n, unread: true)),
                      const SectionLabel('Ayer',
                          margin: EdgeInsets.only(left: 4, bottom: 10, top: 16)),
                      ..._yesterdayNotis.map((n) => _NotiItem(data: n, unread: false, dim: true)),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
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
  const _NotiData(
      {required this.icon,
      required this.color,
      required this.title,
      required this.body,
      required this.time});
}

const _todayNotis = [
  _NotiData(
      icon: '⏰',
      color: AppColors.cyan,
      title: 'Torneo empieza en 1h 42min',
      body: 'Pioneer FNM · Dragón Rojo Store',
      time: '5m'),
  _NotiData(
      icon: '⚔',
      color: AppColors.pink,
      title: 'Nueva ronda disponible',
      body: 'R2 contra Laura M. · Mesa 14',
      time: '12m'),
  _NotiData(
      icon: '✉',
      color: AppColors.violet,
      title: 'Invitación de David R.',
      body: '"Te apuntas al Commander del sábado?"',
      time: '1h'),
  _NotiData(
      icon: '◉',
      color: AppColors.orange,
      title: 'Nuevo anuncio de El Refugio',
      body: 'Torneo de Yu-Gi-Oh! publicado · 24 plazas',
      time: '2h'),
  _NotiData(
      icon: '🏆',
      color: AppColors.yellow,
      title: 'Resultado final publicado',
      body: 'Terminaste 2º · +18 pts de ranking · 15 € en tienda',
      time: '3h'),
];

const _yesterdayNotis = [
  _NotiData(
      icon: '★',
      color: AppColors.yellow,
      title: 'Laura M. dejó una reseña de 5★',
      body: '"Organización perfecta, volveré"',
      time: '18h'),
  _NotiData(
      icon: '📍',
      color: AppColors.blue,
      title: 'Nueva tienda cerca',
      body: 'Puzzle Games a 1,2 km',
      time: '20h'),
  _NotiData(
      icon: '✎',
      color: AppColors.orange,
      title: 'Reglas actualizadas · Magic',
      body: 'Nueva ban list efectiva el 28 Abr',
      time: '22h'),
];

class _NotiItem extends StatelessWidget {
  final _NotiData data;
  final bool unread;
  final bool dim;
  const _NotiItem({required this.data, this.unread = false, this.dim = false});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Opacity(
        opacity: dim ? 0.85 : 1.0,
        child: Container(
          padding: const EdgeInsets.all(13),
          decoration: BoxDecoration(
            color: unread ? AppColors.surface : Colors.transparent,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: unread ? AppColors.stroke : Colors.transparent),
          ),
          child: Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: data.color.withValues(alpha: unread ? 0.12 : 0.08),
                  borderRadius: BorderRadius.circular(13),
                  border: Border.all(
                      color: data.color.withValues(alpha: unread ? 0.2 : 0.13)),
                ),
                child: Center(
                  child: Text(data.icon, style: TextStyle(fontSize: 16, color: data.color)),
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
                            data.title,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.rubik(
                              fontSize: 13.5,
                              fontWeight: FontWeight.w600,
                              color: dim ? AppColors.textDim : AppColors.text,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(data.time,
                            style:
                                GoogleFonts.rubik(fontSize: 10.5, color: AppColors.textMute)),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(data.body,
                        style: GoogleFonts.rubik(
                          fontSize: 12,
                          color: dim ? AppColors.textMute : AppColors.textDim,
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
                    decoration:
                        BoxDecoration(shape: BoxShape.circle, color: data.color),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
