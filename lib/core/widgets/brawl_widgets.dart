import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:brawl_tcg/core/theme/app_colors.dart';

// ─── BrawlBackground ──────────────────────────────────────────────────────────
// Dark scaffold background with corner circle decorations and Memphis shapes.
class BrawlBackground extends StatelessWidget {
  final Widget child;
  final int seed;

  const BrawlBackground({super.key, required this.child, this.seed = 3});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.bg,
      child: Stack(
        children: [
          // Top-left thick ring (violet)
          Positioned(
            top: -90,
            left: -90,
            child: Container(
              width: 220,
              height: 220,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Color(0xFF6B42D9),
              ),
            ),
          ),
          Positioned(
            top: -50,
            left: -50,
            child: Container(
              width: 140,
              height: 140,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.bg,
              ),
            ),
          ),
          // Top-right quarter circle
          Positioned(
            top: -120,
            right: -90,
            child: Container(
              width: 240,
              height: 240,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Color(0xFF8A4BFF),
              ),
            ),
          ),
          // Mid-right cyan dot
          Positioned(
            top: MediaQuery.of(context).size.height * 0.38,
            right: -30,
            child: Container(
              width: 60,
              height: 60,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.cyan,
              ),
            ),
          ),
          // Bottom-left big circle (magenta)
          Positioned(
            bottom: -140,
            left: -110,
            child: Container(
              width: 320,
              height: 320,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Color(0xFFC04AE0),
              ),
            ),
          ),
          // Bottom-right accent
          Positioned(
            bottom: -50,
            right: -50,
            child: Container(
              width: 140,
              height: 140,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Color(0xFFFF6A9B),
              ),
            ),
          ),
          // Memphis scattered shapes
          IgnorePointer(
            child: CustomPaint(
              painter: _MemphisPainter(seed: seed),
              size: Size.infinite,
            ),
          ),
          child,
        ],
      ),
    );
  }
}

class _MemphisPainter extends CustomPainter {
  final int seed;
  _MemphisPainter({required this.seed});

  @override
  void paint(Canvas canvas, Size size) {
    int s = seed * 9301 + 49297;
    double r() {
      s = (s * 9301 + 49297) % 233280;
      return s / 233280;
    }

    const shapes = ['x', 'o', 'plus', 'tri', 'dot'];
    const accentColor = Color(0xFF8A4BFF);
    const baseColor = Color(0x2EFFFFFF);

    for (int i = 0; i < 18; i++) {
      final shape = shapes[(r() * shapes.length).floor()];
      final left = r() * size.width * 0.95;
      final top = r() * size.height * 0.95;
      final sz = 8.0 + r() * 14;
      final rot = (r() - 0.5) * 80 * math.pi / 180;
      final isAccent = r() > 0.7;
      final color = isAccent ? accentColor : baseColor;
      final opacity = isAccent ? 0.9 : 0.45;

      canvas.save();
      canvas.translate(left, top);
      canvas.rotate(rot);

      final paint = Paint()
        ..color = color.withValues(alpha: opacity)
        ..strokeWidth = 1.3
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round;

      switch (shape) {
        case 'x':
          canvas.drawLine(Offset(-sz / 2, -sz / 2), Offset(sz / 2, sz / 2), paint);
          canvas.drawLine(Offset(sz / 2, -sz / 2), Offset(-sz / 2, sz / 2), paint);
        case 'o':
          canvas.drawCircle(Offset.zero, sz / 2, paint);
        case 'plus':
          canvas.drawLine(Offset(0, -sz / 2), Offset(0, sz / 2), paint);
          canvas.drawLine(Offset(-sz / 2, 0), Offset(sz / 2, 0), paint);
        case 'tri':
          final path = Path()
            ..moveTo(0, -sz / 2)
            ..lineTo(sz / 2, sz / 2)
            ..lineTo(-sz / 2, sz / 2)
            ..close();
          canvas.drawPath(path, paint);
        case 'dot':
          canvas.drawCircle(Offset.zero, sz * 0.15, paint..style = PaintingStyle.fill);
      }

      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(_MemphisPainter old) => old.seed != seed;
}

// ─── BrawlCard ────────────────────────────────────────────────────────────────
class BrawlCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final double radius;
  final Color? tint;
  final Color? border;
  final BoxDecoration? decoration;
  final VoidCallback? onTap;

  const BrawlCard({
    super.key,
    required this.child,
    this.padding,
    this.radius = 22,
    this.tint,
    this.border,
    this.decoration,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: padding ?? const EdgeInsets.all(16),
        decoration: decoration ??
            BoxDecoration(
              color: tint ?? AppColors.surface,
              borderRadius: BorderRadius.circular(radius),
              border: Border.all(color: border ?? AppColors.stroke),
            ),
        child: child,
      ),
    );
  }
}

// ─── GameBadge ────────────────────────────────────────────────────────────────
class GameBadge extends StatelessWidget {
  final String game;
  final double size;

  const GameBadge({super.key, required this.game, this.size = 40});

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.gameBadgePalettes[game] ??
        AppColors.gameBadgePalettes['MTG']!;
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: colors,
        ),
        boxShadow: [
          BoxShadow(
            color: colors[0].withValues(alpha: 0.33),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Center(
        child: Text(
          game,
          style: GoogleFonts.rubik(
            fontSize: size * 0.34,
            fontWeight: FontWeight.w800,
            color: Colors.white,
            letterSpacing: -0.5,
          ),
        ),
      ),
    );
  }
}

// ─── GradBtn ──────────────────────────────────────────────────────────────────
enum GradBtnSize { sm, md, lg }

class GradBtn extends StatelessWidget {
  final Widget child;
  final List<Color> gradient;
  final GradBtnSize size;
  final VoidCallback? onTap;
  final double? width;

  const GradBtn({
    super.key,
    required this.child,
    this.gradient = AppColors.clienteGradient,
    this.size = GradBtnSize.md,
    this.onTap,
    this.width,
  });

  @override
  Widget build(BuildContext context) {
    final double h;
    final double px;
    final double fs;
    switch (size) {
      case GradBtnSize.sm:
        h = 36; px = 14; fs = 13;
      case GradBtnSize.md:
        h = 48; px = 20; fs = 15;
      case GradBtnSize.lg:
        h = 56; px = 24; fs = 16;
    }
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: h,
        width: width,
        padding: EdgeInsets.symmetric(horizontal: px),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: const Alignment(-1, -0.5),
            end: const Alignment(1, 0.5),
            colors: gradient,
          ),
          borderRadius: BorderRadius.circular(999),
          boxShadow: const [
            BoxShadow(
              color: Color(0x4D4A6CF7),
              blurRadius: 24,
              offset: Offset(0, 8),
            ),
          ],
        ),
        child: DefaultTextStyle(
          style: GoogleFonts.rubik(
            fontSize: fs,
            fontWeight: FontWeight.w600,
            color: Colors.white,
            letterSpacing: -0.01,
          ),
          child: Center(child: child),
        ),
      ),
    );
  }
}

// ─── BrawlTag ─────────────────────────────────────────────────────────────────
class BrawlTag extends StatelessWidget {
  final String label;
  final Color color;

  const BrawlTag({super.key, required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.13),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Text(
        label,
        style: GoogleFonts.rubik(
          fontSize: 10.5,
          fontWeight: FontWeight.w600,
          color: color,
          letterSpacing: 0.3,
        ),
      ),
    );
  }
}

// ─── GradText ─────────────────────────────────────────────────────────────────
class GradText extends StatelessWidget {
  final String text;
  final List<Color> gradient;
  final TextStyle? style;

  const GradText({
    super.key,
    required this.text,
    this.gradient = AppColors.clienteGradient,
    this.style,
  });

  @override
  Widget build(BuildContext context) {
    return ShaderMask(
      shaderCallback: (bounds) => LinearGradient(
        colors: gradient,
        begin: const Alignment(-1, -0.5),
        end: const Alignment(1, 0.5),
      ).createShader(bounds),
      blendMode: BlendMode.srcIn,
      child: Text(text, style: style),
    );
  }
}

// ─── BrawlTabBar ──────────────────────────────────────────────────────────────
class BrawlTabBarItem {
  final String icon;
  final String label;
  const BrawlTabBarItem({required this.icon, required this.label});
}

class BrawlTabBar extends StatefulWidget {
  final int active;
  final List<BrawlTabBarItem> tabs;
  final List<Color> accent;
  final ValueChanged<int>? onTap;

  const BrawlTabBar({
    super.key,
    required this.active,
    required this.tabs,
    this.accent = AppColors.clienteGradient,
    this.onTap,
  });

  @override
  State<BrawlTabBar> createState() => _BrawlTabBarState();
}

class _BrawlTabBarState extends State<BrawlTabBar> {
  int _prevActive = 0;

  @override
  void initState() {
    super.initState();
    _prevActive = widget.active;
  }

  @override
  void didUpdateWidget(BrawlTabBar old) {
    super.didUpdateWidget(old);
    if (old.active != widget.active) {
      _prevActive = old.active;
    }
  }

  @override
  Widget build(BuildContext context) {
    const double barH = 64;
    const double bubbleSize = 44;
    const double notchR = 26.0;
    const double fillet = 8.0;
    const double barR = 32.0;
    final double barW = MediaQuery.of(context).size.width - 32;
    final int n = widget.tabs.length;
    final double slotW = barW / n;

    final double fromCx = slotW * _prevActive + slotW / 2;
    final double toCx = slotW * widget.active + slotW / 2;

    return SizedBox(
      height: barH + 18 + 24,
      child: TweenAnimationBuilder<double>(
        tween: Tween<double>(begin: fromCx, end: toCx),
        duration: const Duration(milliseconds: 320),
        curve: Curves.easeOutCubic,
        builder: (context, cx, _) {
          return Stack(
            children: [
              Positioned(
                bottom: 24,
                left: 16,
                right: 16,
                child: SizedBox(
                  height: barH + 18,
                  child: CustomPaint(
                    painter: _NotchBarPainter(
                      cx: cx,
                      barW: barW,
                      barH: barH,
                      notchR: notchR,
                      fillet: fillet,
                      barR: barR,
                    ),
                  ),
                ),
              ),
              Positioned(
                bottom: 24,
                left: 16,
                right: 16,
                child: SizedBox(
                  height: barH + 18,
                  child: Stack(
                    children: List.generate(widget.tabs.length, (i) {
                      final isActive = i == widget.active;
                      final tcx = slotW * i + slotW / 2;
                      if (isActive) {
                        return Positioned(
                          left: tcx - bubbleSize / 2,
                          bottom: barH - 28,
                          child: GestureDetector(
                            onTap: () => widget.onTap?.call(i),
                            child: Container(
                              width: bubbleSize,
                              height: bubbleSize,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.white,
                                boxShadow: const [
                                  BoxShadow(
                                    color: Color(0x80000000),
                                    blurRadius: 16,
                                    offset: Offset(0, 6),
                                  ),
                                ],
                              ),
                              child: Center(
                                child: Text(
                                  widget.tabs[i].icon,
                                  style: const TextStyle(fontSize: 20, color: Colors.black),
                                ),
                              ),
                            ),
                          ),
                        );
                      }
                      return Positioned(
                        left: tcx - 24,
                        bottom: 12,
                        child: GestureDetector(
                          onTap: () => widget.onTap?.call(i),
                          child: SizedBox(
                            width: 48,
                            height: 48,
                            child: Center(
                              child: Text(
                                widget.tabs[i].icon,
                                style: TextStyle(
                                  fontSize: 20,
                                  color: Colors.white.withValues(alpha: 0.75),
                                ),
                              ),
                            ),
                          ),
                        ),
                      );
                    }),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _NotchBarPainter extends CustomPainter {
  final double cx, barW, barH, notchR, fillet, barR;
  _NotchBarPainter({
    required this.cx,
    required this.barW,
    required this.barH,
    required this.notchR,
    required this.fillet,
    required this.barR,
  });

  @override
  void paint(Canvas canvas, Size size) {
    const double offsetY = 18;
    final path = Path();
    path.moveTo(barR, offsetY);
    path.lineTo(cx - notchR - fillet, offsetY);
    path.arcToPoint(
      Offset(cx - notchR, offsetY + fillet),
      radius: Radius.circular(fillet),
      clockwise: true,
    );
    path.arcToPoint(
      Offset(cx + notchR, offsetY + fillet),
      radius: Radius.circular(notchR),
      clockwise: false,
    );
    path.arcToPoint(
      Offset(cx + notchR + fillet, offsetY),
      radius: Radius.circular(fillet),
      clockwise: true,
    );
    path.lineTo(barW - barR, offsetY);
    path.arcToPoint(Offset(barW, offsetY + barR), radius: Radius.circular(barR));
    path.lineTo(barW, offsetY + barH - barR);
    path.arcToPoint(Offset(barW - barR, offsetY + barH), radius: Radius.circular(barR));
    path.lineTo(barR, offsetY + barH);
    path.arcToPoint(Offset(0, offsetY + barH - barR), radius: Radius.circular(barR));
    path.lineTo(0, offsetY + barR);
    path.arcToPoint(Offset(barR, offsetY), radius: Radius.circular(barR));
    path.close();

    canvas.drawShadow(path, Colors.black, 10, false);
    canvas.drawPath(
      path,
      Paint()..color = Colors.black,
    );
    canvas.drawPath(
      path,
      Paint()
        ..color = Colors.white.withValues(alpha: 0.06)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1,
    );
  }

  @override
  bool shouldRepaint(_NotchBarPainter old) => old.cx != cx;
}

// ─── SectionLabel ─────────────────────────────────────────────────────────────
class SectionLabel extends StatelessWidget {
  final String text;
  final EdgeInsetsGeometry? margin;

  const SectionLabel(this.text, {super.key, this.margin});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: margin ?? const EdgeInsets.only(left: 4, bottom: 10, top: 18),
      child: Text(
        text.toUpperCase(),
        style: GoogleFonts.rubik(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: AppColors.textMute,
          letterSpacing: 0.8,
        ),
      ),
    );
  }
}

// ─── BackBtn ──────────────────────────────────────────────────────────────────
class BackBtn extends StatelessWidget {
  final VoidCallback? onTap;
  const BackBtn({super.key, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap ?? () => Navigator.maybePop(context),
      child: Container(
        width: 38,
        height: 38,
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.stroke),
        ),
        child: Center(
          child: Text(
            '‹',
            style: TextStyle(fontSize: 18, color: AppColors.text),
          ),
        ),
      ),
    );
  }
}

// ─── BrawlNavBarSpacer ────────────────────────────────────────────────────────
// Bottom spacer that reserves room for the mobile tab bar on mobile, and
// collapses to a small padding on desktop (≥1024px) where there is no tab bar.
class BrawlNavBarSpacer extends StatelessWidget {
  const BrawlNavBarSpacer({super.key});

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width >= 1024;
    return SizedBox(height: isDesktop ? 16 : 106);
  }
}

// ─── BrawlDesktopShell ────────────────────────────────────────────────────────
// Desktop layout: Drawer navigation + full-width content area.
class BrawlDesktopShell extends StatelessWidget {
  final int tab;
  final List<BrawlTabBarItem> tabs;
  final List<Widget> screens;
  final List<Color> accent;
  final String roleLabel;
  final ValueChanged<int> onTabChange;

  const BrawlDesktopShell({
    super.key,
    required this.tab,
    required this.tabs,
    required this.screens,
    required this.accent,
    required this.roleLabel,
    required this.onTabChange,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      drawer: _BrawlDrawer(
        tabs: tabs,
        accent: accent,
        active: tab,
        roleLabel: roleLabel,
        onTap: onTabChange,
      ),
      body: Builder(
        builder: (ctx) => Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Left strip: reserved for the hamburger button, never overlaps content.
            SizedBox(
              width: 64,
              child: SafeArea(
                child: Align(
                  alignment: Alignment.topCenter,
                  child: Padding(
                    padding: const EdgeInsets.only(top: 12),
                    child: _HamburgerBtn(
                      onTap: () => Scaffold.of(ctx).openDrawer(),
                    ),
                  ),
                ),
              ),
            ),
            // Main content: fills all remaining width.
            Expanded(
              child: IndexedStack(index: tab, children: screens),
            ),
          ],
        ),
      ),
    );
  }
}

class _BrawlDrawer extends StatelessWidget {
  final int active;
  final List<BrawlTabBarItem> tabs;
  final List<Color> accent;
  final String roleLabel;
  final ValueChanged<int>? onTap;

  const _BrawlDrawer({
    required this.active,
    required this.tabs,
    required this.accent,
    required this.roleLabel,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Drawer(
      width: 240,
      backgroundColor: AppColors.bgDeep,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topRight: Radius.circular(20),
          bottomRight: Radius.circular(20),
        ),
      ),
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Brand header
            Padding(
              padding: const EdgeInsets.fromLTRB(22, 28, 22, 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ShaderMask(
                    shaderCallback: (bounds) => LinearGradient(
                      colors: accent,
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                    ).createShader(bounds),
                    blendMode: BlendMode.srcIn,
                    child: Text(
                      'BRAWL',
                      style: GoogleFonts.rubik(
                        fontSize: 26,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    roleLabel.toUpperCase(),
                    style: GoogleFonts.rubik(
                      fontSize: 9.5,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textMute,
                      letterSpacing: 2.0,
                    ),
                  ),
                ],
              ),
            ),
            // Nav items
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: List.generate(tabs.length, (i) {
                    final isActive = i == active;
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 4),
                      child: GestureDetector(
                        onTap: () {
                          onTap?.call(i);
                          Navigator.of(context).pop();
                        },
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 180),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 13),
                          decoration: BoxDecoration(
                            gradient: isActive
                                ? LinearGradient(
                                    colors: [
                                      accent.first.withValues(alpha: 0.22),
                                      accent.last.withValues(alpha: 0.10),
                                    ],
                                    begin: Alignment.centerLeft,
                                    end: Alignment.centerRight,
                                  )
                                : null,
                            borderRadius: BorderRadius.circular(14),
                            border: isActive
                                ? Border.all(
                                    color: accent.first.withValues(alpha: 0.28))
                                : null,
                          ),
                          child: Row(
                            children: [
                              Text(
                                tabs[i].icon,
                                style: TextStyle(
                                  fontSize: 18,
                                  color: isActive
                                      ? accent.last
                                      : AppColors.textMute,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  tabs[i].label,
                                  style: GoogleFonts.rubik(
                                    fontSize: 14,
                                    fontWeight: isActive
                                        ? FontWeight.w600
                                        : FontWeight.w500,
                                    color: isActive
                                        ? AppColors.text
                                        : AppColors.textMute,
                                  ),
                                ),
                              ),
                              ShaderMask(
                                shaderCallback: (b) =>
                                    LinearGradient(colors: accent)
                                        .createShader(b),
                                blendMode: BlendMode.srcIn,
                                child: AnimatedOpacity(
                                  opacity: isActive ? 1.0 : 0.0,
                                  duration: const Duration(milliseconds: 180),
                                  child: Container(
                                    width: 5,
                                    height: 5,
                                    decoration: const BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  }),
                ),
              ),
            ),
            // Version footer
            Padding(
              padding: const EdgeInsets.fromLTRB(22, 0, 22, 24),
              child: Text(
                'Brawl TCG · v1.4.2',
                style: GoogleFonts.rubik(
                    fontSize: 10, color: AppColors.textMute),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HamburgerBtn extends StatelessWidget {
  final VoidCallback onTap;
  const _HamburgerBtn({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: const Color(0xCC100A19),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.stroke),
        ),
        child: const Icon(Icons.menu, size: 18, color: Colors.white),
      ),
    );
  }
}
