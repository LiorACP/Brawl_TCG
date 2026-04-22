import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../theme/app_colors.dart';
import '../../widgets/brawl_widgets.dart';
import '../../navigation/transitions.dart';
import '../shared/shared_notis_screen.dart';

class ClienteMapaScreen extends StatefulWidget {
  const ClienteMapaScreen({super.key});

  @override
  State<ClienteMapaScreen> createState() => _ClienteMapaScreenState();
}

class _ClienteMapaScreenState extends State<ClienteMapaScreen> {
  String _activeFilter = 'Todos';
  _PinData? _selectedPin;

  final _filters = const ['Todos', 'MTG', 'Pokémon', 'YuGiOh', '< 5 km'];

  void _openNotis() =>
      Navigator.push(context, fadeSlideRoute(const SharedNotisScreen()));

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0B0914),
      body: SafeArea(
        child: Stack(
          children: [
            // Map background
            const _MapBackground(),
            // Pins
            ..._pins.map((p) => Positioned(
                  top: p.top,
                  left: p.left,
                  child: GestureDetector(
                    onTap: () => setState(() => _selectedPin = p),
                    child: _MapPin(game: p.game, count: p.count, selected: _selectedPin == p),
                  ),
                )),
            // My location pulse
            const Positioned(top: 370, left: 180, child: _LocationPulse()),
            // Top bar
            Positioned(
              top: 60,
              left: 16,
              right: 16,
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: const Color(0xE0120E1C),
                      borderRadius: BorderRadius.circular(26),
                      border: Border.all(color: AppColors.stroke),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.search, size: 18, color: AppColors.textDim),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text('Barcelona',
                              style: GoogleFonts.rubik(fontSize: 14, color: AppColors.text)),
                        ),
                        GestureDetector(
                          onTap: _openNotis,
                          child: Container(
                            width: 28,
                            height: 28,
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(colors: AppColors.clienteGradient),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Icon(Icons.notifications_outlined,
                                size: 14, color: Colors.white),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: _filters.map((f) {
                        final active = f == _activeFilter;
                        return Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: GestureDetector(
                            onTap: () => setState(() => _activeFilter = f),
                            child: _FilterChip(label: f, active: active),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ],
              ),
            ),
            // Bottom sheet — store detail
            AnimatedPositioned(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOutCubic,
              bottom: _selectedPin != null ? 106 : -200,
              left: 12,
              right: 12,
              child: Container(
                decoration: BoxDecoration(
                  color: const Color(0xEB120E1C),
                  borderRadius: BorderRadius.circular(26),
                  border: Border.all(color: AppColors.stroke),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const SizedBox(height: 10),
                    Container(
                      width: 36,
                      height: 4,
                      decoration: BoxDecoration(
                        color: AppColors.stroke,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(18, 14, 18, 6),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Dragón Rojo Store',
                                style: GoogleFonts.rubik(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.text),
                              ),
                              const SizedBox(height: 2),
                              Text('C/ Aragón 214 · A 450 m',
                                  style:
                                      GoogleFonts.rubik(fontSize: 12, color: AppColors.textDim)),
                            ],
                          ),
                          BrawlTag(label: 'Abierto · cierra 22h', color: AppColors.cyan),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(18, 8, 18, 14),
                      child: Row(
                        children: const [
                          _TournamentSlot(game: 'MTG', time: 'Hoy 18:30'),
                          SizedBox(width: 14),
                          _TournamentSlot(game: 'POK', time: 'Sáb 10:00'),
                          SizedBox(width: 14),
                          _TournamentSlot(game: 'YGO', time: 'Dom 17:00'),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // Tap fuera para cerrar
            if (_selectedPin != null)
              Positioned.fill(
                child: GestureDetector(
                  behavior: HitTestBehavior.translucent,
                  onTap: () => setState(() => _selectedPin = null),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

const _pins = [
  _PinData(top: 250, left: 120, game: 'MTG', count: 3),
  _PinData(top: 320, left: 250, game: 'POK'),
  _PinData(top: 420, left: 80, game: 'YGO'),
  _PinData(top: 480, left: 220, game: 'LOR'),
  _PinData(top: 560, left: 310, game: 'ONE'),
  _PinData(top: 180, left: 290, game: 'DBS'),
];

class _PinData {
  final double top, left;
  final String game;
  final int? count;
  const _PinData({required this.top, required this.left, required this.game, this.count});
}

class _MapPin extends StatelessWidget {
  final String game;
  final int? count;
  final bool selected;
  const _MapPin({required this.game, this.count, this.selected = false});

  @override
  Widget build(BuildContext context) {
    return AnimatedScale(
      scale: selected ? 1.2 : 1.0,
      duration: const Duration(milliseconds: 200),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Stack(
            clipBehavior: Clip.none,
            children: [
              GameBadge(game: game, size: 36),
              if (count != null)
                Positioned(
                  top: -4,
                  right: -4,
                  child: Container(
                    width: 14,
                    height: 14,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.pink,
                      border: Border.all(color: const Color(0xFF0B0914), width: 2),
                    ),
                    child: Center(
                      child: Text('$count',
                          style: GoogleFonts.rubik(
                              fontSize: 8, fontWeight: FontWeight.w700, color: Colors.white)),
                    ),
                  ),
                ),
            ],
          ),
          CustomPaint(size: const Size(12, 8), painter: _PinTailPainter()),
        ],
      ),
    );
  }
}

class _PinTailPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.black.withValues(alpha: 0.4);
    final path = Path()
      ..moveTo(0, 0)
      ..lineTo(size.width, 0)
      ..lineTo(size.width / 2, size.height)
      ..close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(_) => false;
}

class _LocationPulse extends StatefulWidget {
  const _LocationPulse();

  @override
  State<_LocationPulse> createState() => _LocationPulseState();
}

class _LocationPulseState extends State<_LocationPulse> with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(seconds: 2))
      ..repeat(reverse: true);
    _anim = Tween(begin: 0.15, end: 0.7).animate(_ctrl);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        AnimatedBuilder(
          animation: _anim,
          builder: (_, __) => Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.cyan.withValues(alpha: _anim.value * 0.15),
            ),
          ),
        ),
        Container(
          width: 18,
          height: 18,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: AppColors.cyan,
            border: Border.all(color: const Color(0xFF0B0914), width: 3),
            boxShadow: [
              BoxShadow(color: AppColors.cyan.withValues(alpha: 0.5), blurRadius: 6),
            ],
          ),
        ),
      ],
    );
  }
}

class _MapBackground extends StatelessWidget {
  const _MapBackground();

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(child: CustomPaint(painter: _MapGridPainter()));
  }
}

class _MapGridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final gridPaint = Paint()
      ..color = AppColors.violet.withValues(alpha: 0.18)
      ..strokeWidth = 1;
    final minorPaint = Paint()
      ..color = AppColors.violet.withValues(alpha: 0.06)
      ..strokeWidth = 0.5;

    for (double x = 0; x < size.width; x += 60) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), gridPaint);
    }
    for (double y = 0; y < size.height; y += 60) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }
    for (double x = 0; x < size.width; x += 15) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), minorPaint);
    }

    canvas.drawPath(
      Path()
        ..moveTo(-50, 400)
        ..quadraticBezierTo(200, 350, size.width + 50, 420),
      Paint()
        ..color = AppColors.cyan.withValues(alpha: 0.4)
        ..strokeWidth = 3
        ..style = PaintingStyle.stroke,
    );
    canvas.drawPath(
      Path()
        ..moveTo(80, -50)
        ..quadraticBezierTo(120, 400, 200, size.height + 50),
      Paint()
        ..color = AppColors.violet.withValues(alpha: 0.4)
        ..strokeWidth = 3
        ..style = PaintingStyle.stroke,
    );
    canvas.drawPath(
      Path()
        ..moveTo(-50, 550)
        ..quadraticBezierTo(250, 530, size.width + 50, 580),
      Paint()
        ..color = AppColors.magenta.withValues(alpha: 0.3)
        ..strokeWidth = 2
        ..style = PaintingStyle.stroke,
    );
  }

  @override
  bool shouldRepaint(_) => false;
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool active;
  const _FilterChip({required this.label, this.active = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
      decoration: BoxDecoration(
        gradient: active ? const LinearGradient(colors: AppColors.clienteGradient) : null,
        color: active ? null : const Color(0xE0120E1C),
        borderRadius: BorderRadius.circular(999),
        border: active ? null : Border.all(color: AppColors.stroke),
      ),
      child: Text(label,
          style: GoogleFonts.rubik(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.white)),
    );
  }
}

class _TournamentSlot extends StatelessWidget {
  final String game, time;
  const _TournamentSlot({required this.game, required this.time});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.fromLTRB(10, 10, 10, 8),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.stroke),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            GameBadge(game: game, size: 26),
            const SizedBox(height: 6),
            Text(time,
                style: GoogleFonts.rubikMonoOne(fontSize: 11, color: AppColors.textDim)),
          ],
        ),
      ),
    );
  }
}
