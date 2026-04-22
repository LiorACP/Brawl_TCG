import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../theme/app_colors.dart';
import '../../widgets/brawl_widgets.dart';
import '../../navigation/transitions.dart';
import '../shared/shared_notis_screen.dart';
import 'cliente_codigo_screen.dart';

class ClienteEventosScreen extends StatefulWidget {
  const ClienteEventosScreen({super.key});

  @override
  State<ClienteEventosScreen> createState() => _ClienteEventosScreenState();
}

class _ClienteEventosScreenState extends State<ClienteEventosScreen> {
  String _tab = 'apuntados';

  void _openNotis() =>
      Navigator.push(context, fadeSlideRoute(const SharedNotisScreen()));

  void _openCodigo() =>
      Navigator.push(context, fadeSlideRoute(const ClienteCodigoScreen()));

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: BrawlBackground(
        seed: 7,
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(22, 18, 22, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'HOLA, MARCO',
                              style: GoogleFonts.rubik(
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                                color: AppColors.textMute,
                                letterSpacing: 0.5,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'Mis eventos',
                              style: GoogleFonts.rubik(
                                fontSize: 28,
                                fontWeight: FontWeight.w700,
                                color: AppColors.text,
                                letterSpacing: -0.5,
                              ),
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            // Bell → notificaciones
                            GestureDetector(
                              onTap: _openNotis,
                              child: Container(
                                width: 40,
                                height: 40,
                                decoration: BoxDecoration(
                                  color: AppColors.surface,
                                  borderRadius: BorderRadius.circular(14),
                                  border: Border.all(color: AppColors.stroke),
                                ),
                                child: Stack(
                                  children: [
                                    const Center(
                                      child: Text('🔔', style: TextStyle(fontSize: 17)),
                                    ),
                                    Positioned(
                                      top: 6,
                                      right: 7,
                                      child: Container(
                                        width: 8,
                                        height: 8,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: AppColors.pink,
                                          border: Border.all(color: AppColors.bg, width: 1.5),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            // + → código del torneo
                            GestureDetector(
                              onTap: _openCodigo,
                              child: Container(
                                width: 40,
                                height: 40,
                                decoration: BoxDecoration(
                                  gradient: const LinearGradient(colors: AppColors.clienteGradient),
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                child: const Center(
                                  child: Text('＋',
                                      style: TextStyle(
                                          fontSize: 20,
                                          color: Colors.white,
                                          fontWeight: FontWeight.w600)),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 18),
                    // Tab pills
                    Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(999),
                        border: Border.all(color: AppColors.stroke),
                      ),
                      child: Row(
                        children: [
                          _TabPill(
                            label: 'Apuntados',
                            active: _tab == 'apuntados',
                            onTap: () => setState(() => _tab = 'apuntados'),
                          ),
                          _TabPill(
                            label: 'Participados',
                            active: _tab == 'participados',
                            onTap: () => setState(() => _tab = 'participados'),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 18),
                  ],
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(22, 0, 22, 20),
                  child: _tab == 'apuntados' ? _ApuntadosTab() : _ParticipadosTab(),
                ),
              ),
              // Placeholder para BrawlTabBar del ClienteShell
              const SizedBox(height: 106),
            ],
          ),
        ),
      ),
    );
  }
}

class _TabPill extends StatelessWidget {
  final String label;
  final bool active;
  final VoidCallback onTap;
  const _TabPill({required this.label, required this.active, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          height: 38,
          decoration: BoxDecoration(
            gradient: active ? const LinearGradient(colors: AppColors.clienteGradient) : null,
            borderRadius: BorderRadius.circular(999),
            boxShadow: active
                ? [
                    BoxShadow(
                      color: AppColors.blue.withValues(alpha: 0.35),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    )
                  ]
                : null,
          ),
          child: Center(
            child: Text(label,
                style: GoogleFonts.rubik(
                    fontSize: 13, fontWeight: FontWeight.w600, color: Colors.white)),
          ),
        ),
      ),
    );
  }
}

class _ApuntadosTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        BrawlCard(
          padding: EdgeInsets.zero,
          radius: 26,
          tint: const Color(0xFF0F0C1A),
          border: Colors.transparent,
          child: Column(
            children: [
              Container(
                height: 130,
                decoration: const BoxDecoration(
                  borderRadius: BorderRadius.vertical(top: Radius.circular(26)),
                ),
                child: Stack(
                  children: [
                    Positioned(
                      top: -30,
                      right: -40,
                      child: Container(
                        width: 200,
                        height: 200,
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
                    const Positioned(
                      bottom: 14,
                      left: 14,
                      child: GameBadge(game: 'MTG', size: 36),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(18, 14, 18, 18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Standard FNM — Pioneer',
                        style: GoogleFonts.rubik(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: AppColors.text,
                            letterSpacing: -0.3)),
                    const SizedBox(height: 4),
                    Text('Dragón Rojo Store · Barcelona',
                        style: GoogleFonts.rubik(fontSize: 13, color: AppColors.textDim)),
                    const SizedBox(height: 14),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Row(
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('HOY',
                                    style: GoogleFonts.rubik(
                                        fontSize: 10,
                                        color: AppColors.textMute,
                                        letterSpacing: 0.5)),
                                Text('18:30',
                                    style: GoogleFonts.rubik(
                                        fontSize: 20,
                                        fontWeight: FontWeight.w700,
                                        color: AppColors.text)),
                              ],
                            ),
                            const SizedBox(width: 18),
                            Container(width: 1, height: 36, color: AppColors.stroke),
                            const SizedBox(width: 18),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('MESA',
                                    style: GoogleFonts.rubik(
                                        fontSize: 10,
                                        color: AppColors.textMute,
                                        letterSpacing: 0.5)),
                                Text('#07',
                                    style: GoogleFonts.rubik(
                                        fontSize: 20,
                                        fontWeight: FontWeight.w700,
                                        color: AppColors.text)),
                              ],
                            ),
                          ],
                        ),
                        GradBtn(size: GradBtnSize.sm, child: const Text('Ver →')),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SectionLabel('Próximos (3)',
            margin: EdgeInsets.only(left: 4, top: 18, bottom: 10)),
        ...const [
          _EventRow(
              game: 'POK',
              title: 'Copa de Primavera',
              store: 'Puzzle Games · Madrid',
              date: 'Sáb 25 Abr',
              time: '10:00',
              tag: 'Clasificación',
              tagColor: AppColors.violet),
          _EventRow(
              game: 'YGO',
              title: 'Torneo Master Duel',
              store: 'El Refugio · Valencia',
              date: 'Dom 26 Abr',
              time: '17:00',
              tag: 'Amistoso',
              tagColor: AppColors.violet),
          _EventRow(
              game: 'LOR',
              title: 'Riot Runeterra Open',
              store: 'Online',
              date: 'Vie 1 May',
              time: '19:30',
              tag: 'Online',
              tagColor: AppColors.cyan),
        ],
        const SizedBox(height: 20),
      ],
    );
  }
}

class _EventRow extends StatelessWidget {
  final String game, title, store, date, time, tag;
  final Color tagColor;
  const _EventRow({
    required this.game,
    required this.title,
    required this.store,
    required this.date,
    required this.time,
    required this.tag,
    required this.tagColor,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: BrawlCard(
        radius: 20,
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            GameBadge(game: game, size: 44),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: GoogleFonts.rubik(
                          fontSize: 14.5,
                          fontWeight: FontWeight.w600,
                          color: AppColors.text)),
                  const SizedBox(height: 1),
                  Text(store,
                      style: GoogleFonts.rubik(fontSize: 12, color: AppColors.textDim)),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      BrawlTag(label: tag, color: tagColor),
                      const SizedBox(width: 8),
                      Text('$date · $time',
                          style:
                              GoogleFonts.rubik(fontSize: 11, color: AppColors.textMute)),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ParticipadosTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            _StatCard(number: '27', label: 'Jugados'),
            const SizedBox(width: 10),
            _StatCard(number: '8', label: 'Podios'),
            const SizedBox(width: 10),
            _StatCard(number: '2', label: 'Títulos'),
          ],
        ),
        const SizedBox(height: 14),
        ...const [
          _ResultRow(game: 'MTG', title: 'Pioneer Challenge #14', pos: '2º / 32', date: '18 Abr', win: true),
          _ResultRow(game: 'YGO', title: 'Liga local primavera', pos: '5º / 24', date: '12 Abr', win: false),
          _ResultRow(game: 'POK', title: 'Prerelease Scarlet', pos: '🏆 1º / 18', date: '6 Abr', win: true),
          _ResultRow(game: 'MTG', title: 'Commander Night', pos: '8º / 16', date: '29 Mar', win: false),
        ],
        const SizedBox(height: 20),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  final String number, label;
  const _StatCard({required this.number, required this.label});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: BrawlCard(
        padding: const EdgeInsets.all(14),
        radius: 18,
        child: Column(
          children: [
            GradText(
              text: number,
              style: GoogleFonts.rubik(
                  fontSize: 24, fontWeight: FontWeight.w700, color: Colors.white),
            ),
            const SizedBox(height: 2),
            Text(label.toUpperCase(),
                style: GoogleFonts.rubik(
                    fontSize: 10.5, color: AppColors.textMute, letterSpacing: 0.5)),
          ],
        ),
      ),
    );
  }
}

class _ResultRow extends StatelessWidget {
  final String game, title, pos, date;
  final bool win;
  const _ResultRow(
      {required this.game,
      required this.title,
      required this.pos,
      required this.date,
      required this.win});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: BrawlCard(
        radius: 20,
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            GameBadge(game: game, size: 40),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: GoogleFonts.rubik(
                          fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.text)),
                  const SizedBox(height: 2),
                  Text(date,
                      style: GoogleFonts.rubik(fontSize: 11, color: AppColors.textMute)),
                ],
              ),
            ),
            Text(pos,
                style: GoogleFonts.rubik(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: win ? AppColors.cyan : AppColors.text)),
          ],
        ),
      ),
    );
  }
}
