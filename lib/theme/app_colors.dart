import 'package:flutter/material.dart';

class AppColors {
  static const Color bg = Color(0xFF1A1823);
  static const Color bgDeep = Color(0xFF141220);
  static const Color text = Color(0xFFF2EEFF);

  static Color get surface => const Color(0xFF3C3A4B).withValues(alpha: 0.78);
  static Color get surfaceHi => const Color(0xFF4B495C).withValues(alpha: 0.85);
  static Color get stroke => Colors.white.withValues(alpha: 0.10);
  static Color get strokeHi => Colors.white.withValues(alpha: 0.16);
  static Color get textDim => const Color(0xFFF2EEFF).withValues(alpha: 0.65);
  static Color get textMute => const Color(0xFFF2EEFF).withValues(alpha: 0.38);

  static const Color cyan = Color(0xFF29E8E0);
  static const Color blue = Color(0xFF4A6CF7);
  static const Color violet = Color(0xFF8A4BFF);
  static const Color magenta = Color(0xFFE04AE0);
  static const Color pink = Color(0xFFFF5CA8);
  static const Color orange = Color(0xFFFF8A42);
  static const Color yellow = Color(0xFFF7D048);

  static const List<Color> clienteGradient = [
    Color(0xFF29E8E0),
    Color(0xFF4A6CF7),
    Color(0xFF8A4BFF),
  ];
  static const List<Color> organizadorGradient = [
    Color(0xFF8A4BFF),
    Color(0xFFE04AE0),
    Color(0xFFFF8A42),
  ];

  static Map<String, List<Color>> gameBadgePalettes = {
    'MTG': [const Color(0xFFF7D048), const Color(0xFFFF8A42)],
    'POK': [const Color(0xFF29E8E0), const Color(0xFF4A6CF7)],
    'YGO': [const Color(0xFF8A4BFF), const Color(0xFFE04AE0)],
    'LOR': [const Color(0xFFFF5CA8), const Color(0xFFFF8A42)],
    'ONE': [const Color(0xFFE04AE0), const Color(0xFF8A4BFF)],
    'DBS': [const Color(0xFFFF8A42), const Color(0xFFF7D048)],
  };
}
