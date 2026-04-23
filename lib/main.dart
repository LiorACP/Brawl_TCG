import 'package:brawl_tcg/shell/cliente_shell.dart';
import 'package:brawl_tcg/shell/org_shell.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Brawl TCG',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        textTheme: GoogleFonts.rubikTextTheme(),
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF8A4BFF)),
        snackBarTheme: const SnackBarThemeData(
          behavior: SnackBarBehavior.floating,
        ),
      ),
      builder: (context, child) => _BrawlResponsive(child: child!),
      home: ClienteShell(),
    );
  }
}

// Applies letterboxing (black bars) for small or landscape mobile screens.
// Desktop screens (≥ 700 px) are passed through unchanged; the shells handle
// desktop layout internally via BrawlDesktopShell.
class _BrawlResponsive extends StatelessWidget {
  final Widget child;
  const _BrawlResponsive({required this.child});

  // Target design viewport (standard iPhone proportions).
  static const double _targetW = 390;
  static const double _targetH = 844;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (_, constraints) {
        final sw = constraints.maxWidth;
        final sh = constraints.maxHeight;

        // Desktop/tablet: shells manage their own layout.
        if (sw >= 1024) return child;

        // Standard portrait mobile: render as designed.
        if (sw >= 360 && sh >= 640 && sw <= sh) return child;

        // Small or landscape screen: letterbox with black bars so the UI
        // scales to fit without overflow.
        return ColoredBox(
          color: Colors.black,
          child: SizedBox.expand(
            child: FittedBox(
              fit: BoxFit.contain,
              child: SizedBox(
                width: _targetW,
                height: _targetH,
                child: MediaQuery(
                  data: MediaQuery.of(context).copyWith(
                    size: const Size(_targetW, _targetH),
                    padding: EdgeInsets.zero,
                    viewPadding: EdgeInsets.zero,
                    viewInsets: EdgeInsets.zero,
                  ),
                  child: child,
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
