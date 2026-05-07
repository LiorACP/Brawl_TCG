import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:brawl_tcg/core/theme/app_colors.dart';
import 'services/torneo_live_service.dart';

class ClienteEsperaScreen extends StatefulWidget {
  final LiveMatchData matchData;
  const ClienteEsperaScreen({super.key, required this.matchData});

  @override
  State<ClienteEsperaScreen> createState() => _ClienteEsperaScreenState();
}

class _ClienteEsperaScreenState extends State<ClienteEsperaScreen>
    with TickerProviderStateMixin {
  late AnimationController _floatCtrl;
  late AnimationController _glowCtrl;

  @override
  void initState() {
    super.initState();
    _floatCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 6),
    )..repeat();
    _glowCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _floatCtrl.dispose();
    _glowCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Fondo con gradiente
          Container(
            decoration: const BoxDecoration(
              gradient: RadialGradient(
                center: Alignment.center,
                radius: 1.2,
                colors: [Color(0xFF1A0A2E), Colors.black],
              ),
            ),
          ),

          // Puntos de luz de fondo
          AnimatedBuilder(
            animation: _glowCtrl,
            builder: (_, __) => CustomPaint(
              painter: _GlowDotsPainter(_glowCtrl.value),
              size: Size.infinite,
            ),
          ),

          // Cartas TCG flotando
          AnimatedBuilder(
            animation: _floatCtrl,
            builder: (_, __) {
              return Stack(
                children: _cardData
                    .asMap()
                    .entries
                    .map((e) => _buildFloatingCard(
                          context,
                          e.value,
                          e.key,
                          _floatCtrl.value,
                        ))
                    .toList(),
              );
            },
          ),

          // Contenido central
          AnimatedBuilder(
            animation: _glowCtrl,
            builder: (_, __) {
              final glow = 0.4 + 0.6 * _glowCtrl.value;
              return Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Icono de espera con glow
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: const LinearGradient(
                          colors: AppColors.clienteGradient,
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.cyan.withValues(alpha: glow * 0.5),
                            blurRadius: 30 * glow,
                            spreadRadius: 4 * glow,
                          ),
                        ],
                      ),
                      child: Center(
                        child: Text(
                          '⚔',
                          style: TextStyle(fontSize: 34),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'RONDA ${widget.matchData.roundNum} COMPLETADA',
                      style: GoogleFonts.rubikMonoOne(
                        fontSize: 11,
                        color: AppColors.cyan.withValues(alpha: 0.8),
                        letterSpacing: 1.5,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'Esperando a los demás\njugadores...',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.rubik(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                        height: 1.3,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      widget.matchData.tournamentName,
                      style: GoogleFonts.rubik(
                        fontSize: 13,
                        color: Colors.white.withValues(alpha: 0.45),
                      ),
                    ),
                    const SizedBox(height: 32),
                    _WaitingDots(animation: _glowCtrl),
                  ],
                ),
              );
            },
          ),

          // Botón volver
          Positioned(
            bottom: 40,
            left: 24,
            right: 24,
            child: GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(
                height: 50,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                      color: Colors.white.withValues(alpha: 0.15)),
                ),
                child: Center(
                  child: Text(
                    'Volver al inicio',
                    style: GoogleFonts.rubik(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.white.withValues(alpha: 0.7),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFloatingCard(
      BuildContext context, _CardData card, int index, double t) {
    final size = MediaQuery.of(context).size;
    final phase = card.phase;
    final speed = card.speed;

    // Movimiento flotante senoidal
    final x = card.baseX * size.width +
        math.cos(phase + t * speed * math.pi * 2) * card.amplX * size.width;
    final y = card.baseY * size.height +
        math.sin(phase * 1.7 + t * speed * math.pi * 2) *
            card.amplY *
            size.height;
    final rot = math.sin(phase + t * speed * math.pi) * 0.18;
    final opacity = 0.15 + 0.1 * math.sin(phase + t * math.pi * 2);

    return Positioned(
      left: x - 30,
      top: y - 42,
      child: Transform.rotate(
        angle: rot,
        child: Opacity(
          opacity: opacity.clamp(0.05, 0.35),
          child: Container(
            width: 60,
            height: 84,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: card.colors,
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                  color: card.colors.first.withValues(alpha: 0.4),
                  width: 1.5),
            ),
            child: Center(
              child: Text(
                card.label,
                style: GoogleFonts.rubik(
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                  color: Colors.white.withValues(alpha: 0.9),
                  letterSpacing: -0.5,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// Datos de las cartas flotantes decorativas
class _CardData {
  final String label;
  final List<Color> colors;
  final double baseX, baseY, amplX, amplY, phase, speed;
  const _CardData({
    required this.label,
    required this.colors,
    required this.baseX,
    required this.baseY,
    required this.amplX,
    required this.amplY,
    required this.phase,
    required this.speed,
  });
}

const _cardData = [
  _CardData(
    label: 'MTG',
    colors: [Color(0xFFFF8A42), Color(0xFFF7D048)],
    baseX: 0.12, baseY: 0.18, amplX: 0.06, amplY: 0.04,
    phase: 0.0, speed: 0.8,
  ),
  _CardData(
    label: 'POK',
    colors: [Color(0xFF29E8E0), Color(0xFF4A6CF7)],
    baseX: 0.82, baseY: 0.22, amplX: 0.05, amplY: 0.05,
    phase: 1.2, speed: 0.65,
  ),
  _CardData(
    label: 'YGO',
    colors: [Color(0xFF8A4BFF), Color(0xFFE04AE0)],
    baseX: 0.15, baseY: 0.75, amplX: 0.07, amplY: 0.04,
    phase: 2.4, speed: 0.9,
  ),
  _CardData(
    label: 'LRC',
    colors: [Color(0xFF29E8E0), Color(0xFFFF5CA8)],
    baseX: 0.80, baseY: 0.70, amplX: 0.05, amplY: 0.06,
    phase: 3.7, speed: 0.7,
  ),
  _CardData(
    label: 'FAB',
    colors: [Color(0xFFFF5CA8), Color(0xFF8A4BFF)],
    baseX: 0.50, baseY: 0.10, amplX: 0.08, amplY: 0.03,
    phase: 0.9, speed: 0.55,
  ),
  _CardData(
    label: 'ONE',
    colors: [Color(0xFFE04AE0), Color(0xFFFF8A42)],
    baseX: 0.50, baseY: 0.88, amplX: 0.07, amplY: 0.04,
    phase: 4.5, speed: 0.75,
  ),
];

class _WaitingDots extends StatelessWidget {
  final Animation<double> animation;
  const _WaitingDots({required this.animation});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animation,
      builder: (_, __) {
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(3, (i) {
            final phase = (animation.value - i * 0.2).clamp(0.0, 1.0);
            final scale = 0.6 + 0.4 * math.sin(phase * math.pi);
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Transform.scale(
                scale: scale,
                child: Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.cyan.withValues(alpha: 0.4 + 0.6 * scale),
                  ),
                ),
              ),
            );
          }),
        );
      },
    );
  }
}

class _GlowDotsPainter extends CustomPainter {
  final double t;
  const _GlowDotsPainter(this.t);

  @override
  void paint(Canvas canvas, Size size) {
    final rand = math.Random(7);
    final paint = Paint()..maskFilter = const MaskFilter.blur(BlurStyle.normal, 12);
    for (int i = 0; i < 12; i++) {
      final x = rand.nextDouble() * size.width;
      final y = rand.nextDouble() * size.height;
      final phase = rand.nextDouble() * math.pi * 2;
      final alpha = (0.04 + 0.04 * math.sin(t * math.pi * 2 + phase)).clamp(0.0, 0.12);
      paint.color = AppColors.violet.withValues(alpha: alpha);
      canvas.drawCircle(Offset(x, y), 20 + rand.nextDouble() * 30, paint);
    }
  }

  @override
  bool shouldRepaint(_GlowDotsPainter old) => old.t != t;
}
