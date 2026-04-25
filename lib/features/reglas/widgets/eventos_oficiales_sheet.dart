import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:brawl_tcg/core/theme/app_colors.dart';
import 'package:brawl_tcg/core/widgets/brawl_widgets.dart';

class _OfficialGame {
  final String name;
  final String subtitle;
  final String code;
  final String url;

  const _OfficialGame({
    required this.name,
    required this.subtitle,
    required this.code,
    required this.url,
  });
}

const _kGames = [
  _OfficialGame(
    name: 'Magic: The Gathering',
    subtitle: 'locator.wizards.com',
    code: 'MTG',
    url: 'https://locator.wizards.com',
  ),
  _OfficialGame(
    name: 'Yu-Gi-Oh! Trading Card Game',
    subtitle: 'yugioh-card.com',
    code: 'YGO',
    url: 'https://www.yugioh-card.com/en/events/',
  ),
  _OfficialGame(
    name: 'Pokémon Trading Card Game',
    subtitle: 'events.pokemon.com',
    code: 'POK',
    url: 'https://events.pokemon.com',
  ),
  _OfficialGame(
    name: 'Flesh and Blood',
    subtitle: 'fabtcg.com',
    code: 'FAB',
    url: 'https://fabtcg.com/events/',
  ),
  _OfficialGame(
    name: 'One Piece Card Game',
    subtitle: 'bandai-tcg-plus.com',
    code: 'ONE',
    url: 'https://www.bandai-tcg-plus.com/home',
  ),
  _OfficialGame(
    name: 'Disney Lorcana',
    subtitle: 'disneylorcana.com',
    code: 'LRC',
    url: 'https://www.disneylorcana.com/en-US/play/lorcana-challenge',
  ),
];

void showEventosOficialesSheet(BuildContext context) {
  showModalBottomSheet(
    context: context,
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    builder: (_) => const _EventosOficialesSheet(),
  );
}

class _EventosOficialesSheet extends StatelessWidget {
  const _EventosOficialesSheet();

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.65,
      minChildSize: 0.4,
      maxChildSize: 0.92,
      builder: (context, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: AppColors.bg,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
            border: Border(
              top: BorderSide(color: AppColors.stroke),
              left: BorderSide(color: AppColors.stroke),
              right: BorderSide(color: AppColors.stroke),
            ),
          ),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 12, bottom: 6),
                child: Container(
                  width: 36,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.strokeHi,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(22, 8, 22, 0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'RECURSOS OFICIALES',
                            style: GoogleFonts.rubik(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textMute,
                              letterSpacing: 0.5,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Eventos Oficiales',
                            style: GoogleFonts.rubik(
                              fontSize: 22,
                              fontWeight: FontWeight.w700,
                              color: AppColors.text,
                              letterSpacing: -0.4,
                            ),
                          ),
                        ],
                      ),
                    ),
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Container(
                        width: 34,
                        height: 34,
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: AppColors.stroke),
                        ),
                        child: Icon(
                          Icons.close,
                          size: 16,
                          color: AppColors.textDim,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(22, 8, 22, 14),
                child: Text(
                  'Selecciona un juego para ver los torneos oficiales en su web.',
                  style: GoogleFonts.rubik(
                    fontSize: 12.5,
                    color: AppColors.textDim,
                    height: 1.4,
                  ),
                ),
              ),
              Expanded(
                child: ListView.separated(
                  controller: scrollController,
                  padding: const EdgeInsets.fromLTRB(22, 0, 22, 28),
                  itemCount: _kGames.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 8),
                  itemBuilder: (context, i) => _GameCard(game: _kGames[i]),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _GameCard extends StatefulWidget {
  final _OfficialGame game;
  const _GameCard({required this.game});

  @override
  State<_GameCard> createState() => _GameCardState();
}

class _GameCardState extends State<_GameCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 90),
      reverseDuration: const Duration(milliseconds: 160),
    );
    _scale = Tween<double>(
      begin: 1.0,
      end: 0.96,
    ).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOut));
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  void _onTapDown(TapDownDetails _) => _ctrl.forward();
  void _onTapUp(TapUpDetails _) => _ctrl.reverse();
  void _onTapCancel() => _ctrl.reverse();

  void _onTap(BuildContext context) {
    _ctrl.reverse();
    _showConfirmDialog(context, widget.game);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _onTap(context),
      onTapDown: _onTapDown,
      onTapUp: _onTapUp,
      onTapCancel: _onTapCancel,
      child: ScaleTransition(
        scale: _scale,
        child: BrawlCard(
          padding: const EdgeInsets.all(14),
          radius: 20,
          child: Row(
            children: [
              GameBadge(game: widget.game.code, size: 44),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.game.name,
                      style: GoogleFonts.rubik(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: AppColors.text,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Row(
                      children: [
                        Icon(
                          Icons.language_rounded,
                          size: 11,
                          color: AppColors.textMute,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          widget.game.subtitle,
                          style: GoogleFonts.rubik(
                            fontSize: 11.5,
                            color: AppColors.textDim,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Container(
                width: 30,
                height: 30,
                decoration: BoxDecoration(
                  color: AppColors.surfaceHi,
                  borderRadius: BorderRadius.circular(9),
                ),
                child: Center(
                  child: Icon(
                    Icons.arrow_forward_ios_rounded,
                    size: 13,
                    color: AppColors.textDim,
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

void _showConfirmDialog(BuildContext context, _OfficialGame game) {
  showDialog(
    context: context,
    builder: (ctx) => Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 28),
      child: BrawlCard(
        radius: 24,
        padding: const EdgeInsets.fromLTRB(22, 22, 22, 18),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                GameBadge(game: game.code, size: 36),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    game.name,
                    style: GoogleFonts.rubik(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: AppColors.text,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              'Serás redirigido a la web oficial para ver torneos actualizados',
              style: GoogleFonts.rubik(
                fontSize: 14,
                color: AppColors.textDim,
                height: 1.45,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              game.subtitle,
              style: GoogleFonts.rubik(
                fontSize: 11.5,
                color: AppColors.textMute,
              ),
            ),
            const SizedBox(height: 22),
            Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () => Navigator.pop(ctx),
                    child: Container(
                      height: 44,
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(999),
                        border: Border.all(color: AppColors.stroke),
                      ),
                      child: Center(
                        child: Text(
                          'Cancelar',
                          style: GoogleFonts.rubik(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: AppColors.text,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: GradBtn(
                    size: GradBtnSize.md,
                    gradient: AppColors.clienteGradient,
                    width: double.infinity,
                    onTap: () async {
                      Navigator.pop(ctx);
                      final uri = Uri.parse(game.url);
                      if (await canLaunchUrl(uri)) {
                        await launchUrl(
                          uri,
                          mode: LaunchMode.externalApplication,
                        );
                      }
                    },
                    child: const Text('Continuar'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    ),
  );
}
