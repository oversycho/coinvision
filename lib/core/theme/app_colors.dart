import 'package:flutter/material.dart';

/// Mirrors the CSS custom properties in index.css exactly (dark = default, light = alt).
class AppColors {
  final Color bg;
  final Color fg;
  final Color card;
  final Color cardFg;
  final Color border;
  final Color muted;
  final Color mutedFg;
  final Color chrome;
  final Color buy;
  final Color sell;
  final Color gain;
  final Color loss;
  final Color overlay;

  const AppColors({
    required this.bg,
    required this.fg,
    required this.card,
    required this.cardFg,
    required this.border,
    required this.muted,
    required this.mutedFg,
    required this.chrome,
    required this.buy,
    required this.sell,
    required this.gain,
    required this.loss,
    required this.overlay,
  });

  static const dark = AppColors(
    bg: Color(0xFF08080D),
    fg: Color(0xFFECEDF5),
    card: Color(0xFF0F0F17),
    cardFg: Color(0xFFE2E3EE),
    border: Color(0xFF1C1C28),
    muted: Color(0xFF13131E),
    mutedFg: Color(0xFF70718A),
    chrome: Color(0xFFC2C5D6),
    buy: Color(0xFF00CCFF),
    sell: Color(0xFFF5A623),
    gain: Color(0xFF00D884),
    loss: Color(0xFFFF3D5E),
    overlay: Color(0xD9080813),
  );

  static const light = AppColors(
    bg: Color(0xFFF0F0F8),
    fg: Color(0xFF0C0C1A),
    card: Color(0xFFFFFFFF),
    cardFg: Color(0xFF0C0C1A),
    border: Color(0xFFDCDCEC),
    muted: Color(0xFFE8E8F4),
    mutedFg: Color(0xFF5C5C7A),
    chrome: Color(0xFF282840),
    buy: Color(0xFF0088CC),
    sell: Color(0xFFD97706),
    gain: Color(0xFF009955),
    loss: Color(0xFFDD1F44),
    overlay: Color(0xE0F0F0F8),
  );

  // Chrome gradient (used for logo strokes + chrome-text)
  static const chromeGradientDark = [
    Color(0xFF8A8D9E),
    Color(0xFFCACDD8),
    Color(0xFFECEEF8),
    Color(0xFFA0A3B4),
    Color(0xFF7A7E90),
  ];

  static const List<Color> coinColors = [
    Color(0xFFF7931A), // BTC
    Color(0xFF627EEA), // ETH
    Color(0xFF26A17B), // USDT
    Color(0xFFEF0027), // TRX
  ];

  static Color coinColorFor(String id) {
    switch (id) {
      case 'BTC':
        return const Color(0xFFF7931A);
      case 'ETH':
        return const Color(0xFF627EEA);
      case 'USDT':
        return const Color(0xFF26A17B);
      case 'TRX':
        return const Color(0xFFEF0027);
      default:
        return const Color(0xFF555555);
    }
  }

  static String coinCharFor(String id) {
    switch (id) {
      case 'BTC':
        return '₿';
      case 'ETH':
        return 'Ξ';
      case 'USDT':
        return '₮';
      case 'TRX':
        return 'T';
      default:
        return id.isNotEmpty ? id[0] : '?';
    }
  }
}
