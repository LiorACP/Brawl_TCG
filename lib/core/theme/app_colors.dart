import 'package:flutter/material.dart';

class AppColors {
  static String _theme = 'dark';
  static void setTheme(String t) => _theme = t;
  static bool get _isDark => _theme == 'dark';

  static Color get bg =>
      _isDark ? const Color(0xFF1A1823) : const Color(0xFFF4F3FF);
  static Color get bgDeep =>
      _isDark ? const Color(0xFF141220) : const Color(0xFFEBEAFB);
  static Color get text =>
      _isDark ? const Color(0xFFF2EEFF) : const Color(0xFF1A1823);

  static Color get surface => _isDark
      ? const Color(0xFF3C3A4B).withValues(alpha: 0.78)
      : Colors.white.withValues(alpha: 0.92);
  static Color get surfaceHi => _isDark
      ? const Color(0xFF4B495C).withValues(alpha: 0.85)
      : const Color(0xFFEEEDFF).withValues(alpha: 0.9);
  static Color get stroke => _isDark
      ? Colors.white.withValues(alpha: 0.10)
      : Colors.black.withValues(alpha: 0.08);
  static Color get strokeHi => _isDark
      ? Colors.white.withValues(alpha: 0.16)
      : Colors.black.withValues(alpha: 0.14);
  static Color get textDim => _isDark
      ? const Color(0xFFF2EEFF).withValues(alpha: 0.65)
      : const Color(0xFF1A1823).withValues(alpha: 0.70);
  static Color get textMute => _isDark
      ? const Color(0xFFF2EEFF).withValues(alpha: 0.38)
      : const Color(0xFF1A1823).withValues(alpha: 0.40);

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
    'LRC': [const Color(0xFF29E8E0), const Color(0xFFFF5CA8)],
    'FAB': [const Color(0xFFFF5CA8), const Color(0xFF8A4BFF)],
    'ONE': [const Color(0xFFE04AE0), const Color(0xFF8A4BFF)],
    'DBS': [const Color(0xFFFF8A42), const Color(0xFFF7D048)],
  };
}
