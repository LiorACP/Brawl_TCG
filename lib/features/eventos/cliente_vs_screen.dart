import 'dart:async';
import 'dart:math' as math;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:brawl_tcg/core/theme/app_colors.dart';
import 'services/torneo_live_service.dart';
import 'cliente_espera_screen.dart';

class ClienteVsScreen extends StatefulWidget {
  final LiveMatchData matchData;
  const ClienteVsScreen({super.key, required this.matchData});

  @override
  State<ClienteVsScreen> createState() => _ClienteVsScreenState();
}

class _ClienteVsScreenState extends State<ClienteVsScreen>
    with TickerProviderStateMixin {
  // Controlador principal: animación de intro (una sola vez)
  late AnimationController _intro;
  // Controlador de pulso sostenido (bucle)
  late AnimationController _pulse;

  // --- Animaciones individuales (todas sobre _intro) ---
  late Animation<double> _gridFade; // fondo
  late Animation<double> _p1Slide; // panel izquierdo
  late Animation<double> _p2Slide; // panel derecho
  late Animation<double> _namesFade; // nombres en paneles
  late Animation<double> _flashOpacity; // destello en impacto
  late Animation<double> _vsScale; // escala texto VS
  late Animation<double> _vsOpacity; // opacidad texto VS
  late Animation<double> _linesOpacity; // líneas de velocidad
  late Animation<double> _sparks; // partículas 0→1
  late Animation<double> _buttonFade; // botón final

  bool _submitting = false;
  StreamSubscription<LiveMatchData?>? _matchSub;

  @override
  void initState() {
    super.initState();

    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid != null) {
      _matchSub = TorneoLiveService.watchLiveMatch(uid).listen((data) {
        if (!mounted) return;
        if (data == null || !data.active) Navigator.of(context).popUntil((r) => r.isFirst);
      });
    }

    _intro = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 4200),
    )..forward();

    _pulse = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat(reverse: true);

    // ── Curvas de cada fase ──────────────────────────────────
    _gridFade = Tween(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _intro, curve: const Interval(0.0, 0.12)),
    );

    _p1Slide = Tween(begin: -1.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _intro,
        curve: const Interval(0.0, 0.52, curve: Curves.easeOutBack),
      ),
    );

    _p2Slide = Tween(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _intro,
        curve: const Interval(0.0, 0.52, curve: Curves.easeOutBack),
      ),
    );

    _namesFade = Tween(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _intro, curve: const Interval(0.25, 0.50)),
    );

    _flashOpacity =
        TweenSequence<double>([
          TweenSequenceItem(tween: Tween(begin: 0.0, end: 0.85), weight: 35),
          TweenSequenceItem(tween: Tween(begin: 0.85, end: 0.0), weight: 65),
        ]).animate(
          CurvedAnimation(parent: _intro, curve: const Interval(0.50, 0.68)),
        );

    _vsScale = Tween(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _intro,
        curve: const Interval(0.52, 0.70, curve: Curves.elasticOut),
      ),
    );

    _vsOpacity = Tween(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _intro, curve: const Interval(0.52, 0.64)),
    );

    _linesOpacity =
        TweenSequence<double>([
          TweenSequenceItem(tween: Tween(begin: 0.0, end: 1.0), weight: 30),
          TweenSequenceItem(tween: Tween(begin: 1.0, end: 0.0), weight: 70),
        ]).animate(
          CurvedAnimation(parent: _intro, curve: const Interval(0.50, 0.82)),
        );

    _sparks = Tween(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _intro, curve: const Interval(0.50, 0.90)),
    );

    _buttonFade = Tween(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _intro, curve: const Interval(0.85, 1.0)),
    );
  }

  @override
  void dispose() {
    _matchSub?.cancel();
    _intro.dispose();
    _pulse.dispose();
    super.dispose();
  }

  /// Saltar animación al estado final
  void _skipIntro() {
    if (_intro.value < 0.85) _intro.value = 0.85;
  }

  Future<void> _marcarTerminado() async {
    if (_submitting) return;
    setState(() => _submitting = true);
    final uid = FirebaseAuth.instance.currentUser?.uid ?? '';
    try {
      await TorneoLiveService.markRoundDone(
        uid: uid,
        tournamentId: widget.matchData.tournamentId,
        matchId: widget.matchData.matchId,
        roundNum: widget.matchData.roundNum,
        isPlayer1: widget.matchData.isPlayer1,
        organizerId: widget.matchData.organizerId,
        playerName: widget.matchData.myName,
        tournamentName: widget.matchData.tournamentName,
      );
      if (mounted) {
        Navigator.pushReplacement(
          context,
          PageRouteBuilder(
            pageBuilder: (_, __, ___) =>
                ClienteEsperaScreen(matchData: widget.matchData),
            transitionDuration: const Duration(milliseconds: 400),
            transitionsBuilder: (_, anim, __, child) =>
                FadeTransition(opacity: anim, child: child),
          ),
        );
      }
    } catch (_) {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final md = widget.matchData;

    // Desde el POV del cliente: su panel siempre a la izquierda
    final leftName = md.isPlayer1 ? md.myName : md.opponentName;
    final rightName = md.isPlayer1 ? md.opponentName : md.myName;
    final leftIsMe = md.isPlayer1;
    final rightIsMe = !md.isPlayer1;

    return GestureDetector(
      onTap: _skipIntro,
      child: Scaffold(
        backgroundColor: Colors.black,
        body: AnimatedBuilder(
          animation: Listenable.merge([_intro, _pulse]),
          builder: (_, __) {
            final pulseGlow = 0.5 + 0.5 * _pulse.value;
            return Stack(
              children: [
                // ── Capa 1: Grid de neón ───────────────────────────────
                Positioned.fill(
                  child: CustomPaint(painter: _GridPainter(_gridFade.value)),
                ),

                // ── Capa 2: Panel izquierdo (desliza desde la izquierda)
                Positioned(
                  left: 0,
                  top: 0,
                  bottom: 0,
                  width: size.width / 2,
                  child: Transform.translate(
                    offset: Offset(_p1Slide.value * size.width, 0),
                    child: _Panel(
                      name: leftName,
                      isLeft: true,
                      isMe: leftIsMe,
                      nameFade: _namesFade.value,
                      colors: const [
                        Color(0xFF0A1628),
                        Color(0xFF0D3A8C),
                        Color(0xFF1565C0),
                      ],
                      accentColor: const Color(0xFF4A9EFF),
                    ),
                  ),
                ),

                // ── Capa 3: Panel derecho (desliza desde la derecha) ──
                Positioned(
                  right: 0,
                  top: 0,
                  bottom: 0,
                  width: size.width / 2,
                  child: Transform.translate(
                    offset: Offset(_p2Slide.value * size.width, 0),
                    child: _Panel(
                      name: rightName,
                      isLeft: false,
                      isMe: rightIsMe,
                      nameFade: _namesFade.value,
                      colors: const [
                        Color(0xFF280A1A),
                        Color(0xFF8C0D2D),
                        Color(0xFFC0152B),
                      ],
                      accentColor: const Color(0xFFFF4A6A),
                    ),
                  ),
                ),

                // ── Capa 4: Efectos del impacto (líneas + chispas + aura)
                Positioned.fill(
                  child: CustomPaint(
                    painter: _ImpactPainter(
                      linesOpacity: _linesOpacity.value,
                      sparksProgress: _sparks.value,
                      pulseGlow: pulseGlow,
                      afterImpact: _intro.value > 0.52,
                    ),
                  ),
                ),

                // ── Capa 5: Texto VS ───────────────────────────────────
                Center(
                  child: Transform.scale(
                    scale: _vsScale.value,
                    child: Opacity(
                      opacity: _vsOpacity.value,
                      child: _VsText(pulseGlow: pulseGlow),
                    ),
                  ),
                ),

                // ── Capa 6: Flash blanco en impacto ───────────────────
                if (_flashOpacity.value > 0)
                  Positioned.fill(
                    child: ColoredBox(
                      color: Colors.white.withValues(
                        alpha: _flashOpacity.value,
                      ),
                    ),
                  ),

                // ── Capa 7: Info de ronda (aparece con el VS) ─────────
                if (_vsOpacity.value > 0)
                  Positioned(
                    top: MediaQuery.of(context).padding.top + 20,
                    left: 0,
                    right: 0,
                    child: Opacity(
                      opacity: _vsOpacity.value,
                      child: Center(
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: 0.55),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: Colors.white.withValues(alpha: 0.12),
                            ),
                          ),
                          child: Text(
                            '${md.tournamentName}  ·  RONDA ${md.roundNum}',
                            style: GoogleFonts.rubikMonoOne(
                              fontSize: 10,
                              color: Colors.white.withValues(alpha: 0.7),
                              letterSpacing: 0.8,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),

                // ── Capa 8: Botón "He terminado" ──────────────────────
                Positioned(
                  bottom: 40,
                  left: 24,
                  right: 24,
                  child: Opacity(
                    opacity: _buttonFade.value,
                    child: IgnorePointer(
                      ignoring: _buttonFade.value < 0.5,
                      child: _submitting
                          ? const Center(
                              child: CircularProgressIndicator(
                                color: AppColors.cyan,
                              ),
                            )
                          : _DoneButton(onTap: _marcarTerminado),
                    ),
                  ),
                ),

                // ── Hint skip ─────────────────────────────────────────
                if (_intro.value < 0.85 && _intro.value > 0.05)
                  Positioned(
                    bottom: 16,
                    right: 20,
                    child: Opacity(
                      opacity: (0.4 * (1 - _buttonFade.value)).clamp(0, 0.4),
                      child: Text(
                        'Toca para saltar',
                        style: GoogleFonts.rubik(
                          fontSize: 11,
                          color: Colors.white.withValues(alpha: 0.4),
                        ),
                      ),
                    ),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }
}

//  WIDGETS INTERNOS

class _Panel extends StatelessWidget {
  final String name;
  final bool isLeft;
  final bool isMe;
  final double nameFade;
  final List<Color> colors;
  final Color accentColor;

  const _Panel({
    required this.name,
    required this.isLeft,
    required this.isMe,
    required this.nameFade,
    required this.colors,
    required this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
    return ClipPath(
      clipper: _PanelClipper(isLeft: isLeft),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: colors,
            begin: isLeft ? Alignment.centerRight : Alignment.centerLeft,
            end: isLeft ? Alignment.centerLeft : Alignment.centerRight,
          ),
        ),
        child: Opacity(
          opacity: nameFade,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: isLeft
                ? CrossAxisAlignment.start
                : CrossAxisAlignment.end,
            children: [
              Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: isLeft ? 20 : 0,
                ).copyWith(right: isLeft ? 0 : 20),
                child: Column(
                  crossAxisAlignment: isLeft
                      ? CrossAxisAlignment.start
                      : CrossAxisAlignment.end,
                  children: [
                    if (isMe)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 3,
                        ),
                        margin: const EdgeInsets.only(bottom: 6),
                        decoration: BoxDecoration(
                          color: accentColor.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(
                            color: accentColor.withValues(alpha: 0.5),
                          ),
                        ),
                        child: Text(
                          'TÚ',
                          style: GoogleFonts.rubikMonoOne(
                            fontSize: 10,
                            color: accentColor,
                            letterSpacing: 1.5,
                          ),
                        ),
                      ),
                    Text(
                      name.toUpperCase(),
                      maxLines: 2,
                      textAlign: isLeft ? TextAlign.left : TextAlign.right,
                      style: GoogleFonts.rubik(
                        fontSize: name.length > 10 ? 18 : 24,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                        letterSpacing: -0.5,
                        height: 1.1,
                        shadows: [
                          Shadow(
                            color: accentColor.withValues(alpha: 0.8),
                            blurRadius: 16,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      isLeft ? 'JUGADOR 1' : 'JUGADOR 2',
                      style: GoogleFonts.rubikMonoOne(
                        fontSize: 9,
                        color: accentColor.withValues(alpha: 0.7),
                        letterSpacing: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PanelClipper extends CustomClipper<Path> {
  final bool isLeft;
  const _PanelClipper({required this.isLeft});

  @override
  Path getClip(Size size) {
    const cut = 32.0; // anchura del corte diagonal en el centro
    final path = Path();
    if (isLeft) {
      path.lineTo(0, 0);
      path.lineTo(size.width - cut, 0);
      path.lineTo(size.width, size.height / 2);
      path.lineTo(size.width - cut, size.height);
      path.lineTo(0, size.height);
    } else {
      path.moveTo(cut, 0);
      path.lineTo(size.width, 0);
      path.lineTo(size.width, size.height);
      path.lineTo(cut, size.height);
      path.lineTo(0, size.height / 2);
    }
    path.close();
    return path;
  }

  @override
  bool shouldReclip(_PanelClipper old) => old.isLeft != isLeft;
}

class _VsText extends StatelessWidget {
  final double pulseGlow;
  const _VsText({required this.pulseGlow});

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        // Capa de resplandor exterior
        Text(
          'VS',
          style: GoogleFonts.rubik(
            fontSize: 86,
            fontWeight: FontWeight.w900,
            foreground: Paint()
              ..color = Colors.white.withValues(alpha: 0.25 * pulseGlow)
              ..maskFilter = MaskFilter.blur(BlurStyle.normal, 28 * pulseGlow),
          ),
        ),
        // Capa de color medio
        Text(
          'VS',
          style: GoogleFonts.rubik(
            fontSize: 86,
            fontWeight: FontWeight.w900,
            foreground: Paint()
              ..color = const Color(
                0xFFFFD700,
              ).withValues(alpha: 0.4 * pulseGlow)
              ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8),
          ),
        ),
        // Texto principal con gradiente
        ShaderMask(
          shaderCallback: (bounds) => const LinearGradient(
            colors: [
              Color(0xFF4A9EFF), // azul
              Color(0xFFFFFFFF), // blanco
              Color(0xFFFF4A6A), // rojo
            ],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ).createShader(bounds),
          child: Text(
            'VS',
            style: GoogleFonts.rubik(
              fontSize: 86,
              fontWeight: FontWeight.w900,
              color: Colors.white,
              letterSpacing: 4,
            ),
          ),
        ),
      ],
    );
  }
}

class _DoneButton extends StatelessWidget {
  final VoidCallback onTap;
  const _DoneButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          '¿Has terminado tu ronda?',
          style: GoogleFonts.rubik(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: Colors.white.withValues(alpha: 0.85),
          ),
        ),
        const SizedBox(height: 12),
        GestureDetector(
          onTap: onTap,
          child: Container(
            height: 54,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [
                  Color(0xFF29E8E0),
                  Color(0xFF4A6CF7),
                  Color(0xFF8A4BFF),
                ],
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: AppColors.cyan.withValues(alpha: 0.35),
                  blurRadius: 20,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Center(
              child: Text(
                'He terminado mi ronda  ✓',
                style: GoogleFonts.rubik(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

//  CUSTOM PAINTERS

class _GridPainter extends CustomPainter {
  final double opacity;
  const _GridPainter(this.opacity);

  @override
  void paint(Canvas canvas, Size size) {
    if (opacity <= 0) return;
    const spacing = 44.0;
    final paint = Paint()..strokeWidth = 0.6;

    for (double x = 0; x <= size.width; x += spacing) {
      final dist = (x - size.width / 2).abs() / (size.width / 2);
      paint.color = const Color(
        0xFF5B38CC,
      ).withValues(alpha: (1 - dist * 0.65) * 0.18 * opacity);
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    for (double y = 0; y <= size.height; y += spacing) {
      final dist = (y - size.height / 2).abs() / (size.height / 2);
      paint.color = const Color(
        0xFF5B38CC,
      ).withValues(alpha: (1 - dist * 0.65) * 0.14 * opacity);
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }

    // Resplandor central sutil
    canvas.drawCircle(
      Offset(size.width / 2, size.height / 2),
      100,
      Paint()
        ..color = const Color(0xFF8A4BFF).withValues(alpha: 0.06 * opacity)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 60),
    );
  }

  @override
  bool shouldRepaint(_GridPainter old) => old.opacity != opacity;
}

class _ImpactPainter extends CustomPainter {
  final double linesOpacity;
  final double sparksProgress;
  final double pulseGlow;
  final bool afterImpact;

  const _ImpactPainter({
    required this.linesOpacity,
    required this.sparksProgress,
    required this.pulseGlow,
    required this.afterImpact,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);

    // Aura central tras el impacto
    if (afterImpact) {
      canvas.drawCircle(
        center,
        40 + 20 * pulseGlow,
        Paint()
          ..color = Colors.white.withValues(alpha: 0.12 * pulseGlow)
          ..maskFilter = MaskFilter.blur(BlurStyle.normal, 30 * pulseGlow),
      );
      canvas.drawCircle(
        center,
        12 + 6 * pulseGlow,
        Paint()
          ..color = const Color(0xFFFFD700).withValues(alpha: 0.35 * pulseGlow),
      );
    }

    // Líneas de velocidad radiales
    if (linesOpacity > 0) {
      _drawSpeedLines(canvas, size, center);
    }

    // Chispas voladoras
    if (sparksProgress > 0) {
      _drawSparks(canvas, size, center);
    }
  }

  void _drawSpeedLines(Canvas canvas, Size size, Offset center) {
    final rand = math.Random(42);
    final paint = Paint()..strokeCap = StrokeCap.round;
    for (int i = 0; i < 90; i++) {
      final angle = rand.nextDouble() * math.pi * 2;
      final startDist = 25.0 + rand.nextDouble() * 55;
      final length = 50.0 + rand.nextDouble() * 220;
      final opacity = (0.15 + rand.nextDouble() * 0.5) * linesOpacity;
      // Azul a la izquierda, rojo a la derecha
      final isLeft = math.cos(angle) < 0;
      paint
        ..color = (isLeft ? const Color(0xFF4A9EFF) : const Color(0xFFFF4A6A))
            .withValues(alpha: opacity)
        ..strokeWidth = 0.4 + rand.nextDouble() * 1.6;
      canvas.drawLine(
        Offset(
          center.dx + math.cos(angle) * startDist,
          center.dy + math.sin(angle) * startDist,
        ),
        Offset(
          center.dx + math.cos(angle) * (startDist + length),
          center.dy + math.sin(angle) * (startDist + length),
        ),
        paint,
      );
    }
  }

  void _drawSparks(Canvas canvas, Size size, Offset center) {
    final rand = math.Random(99);
    final paint = Paint()..strokeCap = StrokeCap.round;
    for (int i = 0; i < 55; i++) {
      final angle = rand.nextDouble() * math.pi * 2;
      final speed = 90.0 + rand.nextDouble() * 320;
      final life = 0.35 + rand.nextDouble() * 0.65;
      final t = (sparksProgress / life).clamp(0.0, 1.0);
      if (t <= 0) continue;
      final dist = speed * sparksProgress;
      final fade = (1 - t).clamp(0.0, 1.0);

      Color sparkColor;
      if (i % 4 == 0) {
        sparkColor = const Color(0xFFFFD700); // dorado
      } else if (i % 4 == 1) {
        sparkColor = const Color(0xFF4A9EFF); // azul
      } else if (i % 4 == 2) {
        sparkColor = const Color(0xFFFF4A6A); // rojo
      } else {
        sparkColor = Colors.white;
      }

      paint
        ..color = sparkColor.withValues(alpha: fade * 0.92)
        ..strokeWidth = (2.2 - t * 1.8).clamp(0.2, 2.2);

      final pos = Offset(
        center.dx + math.cos(angle) * dist,
        center.dy + math.sin(angle) * dist,
      );
      final trailLen = (10 + rand.nextDouble() * 14) * (1 - t * 0.5);
      canvas.drawLine(
        Offset(
          pos.dx - math.cos(angle) * trailLen,
          pos.dy - math.sin(angle) * trailLen,
        ),
        pos,
        paint,
      );
    }

    // Arcos eléctricos (segmentos quebrados desde el centro)
    if (sparksProgress < 0.3) {
      final arcPaint = Paint()
        ..color = Colors.white.withValues(
          alpha: 0.6 * (1 - sparksProgress / 0.3),
        )
        ..strokeWidth = 1.2
        ..strokeCap = StrokeCap.round;
      final arcRand = math.Random(17);
      for (int i = 0; i < 6; i++) {
        final angle = arcRand.nextDouble() * math.pi * 2;
        final len = 60.0 + arcRand.nextDouble() * 80;
        final steps = 5;
        var prev = center;
        for (int s = 1; s <= steps; s++) {
          final frac = s / steps;
          final jitter = (arcRand.nextDouble() - 0.5) * 14;
          final next = Offset(
            center.dx +
                math.cos(angle) * len * frac +
                math.cos(angle + math.pi / 2) * jitter,
            center.dy +
                math.sin(angle) * len * frac +
                math.sin(angle + math.pi / 2) * jitter,
          );
          canvas.drawLine(prev, next, arcPaint);
          prev = next;
        }
      }
    }
  }

  @override
  bool shouldRepaint(_ImpactPainter old) =>
      old.linesOpacity != linesOpacity ||
      old.sparksProgress != sparksProgress ||
      old.pulseGlow != pulseGlow;
}
