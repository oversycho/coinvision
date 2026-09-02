import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

/// Font roles from index.css:
///  --font-display: Barlow Condensed  -> headers / big numbers / labels
///  --font-body:    Vazirmatn         -> body text (also required for Persian numerals)
///  --font-mono:    JetBrains Mono    -> all prices / amounts / codes
class AppFonts {
  static TextStyle display({
    required Color color,
    double size = 16,
    FontWeight weight = FontWeight.w700,
    double letterSpacing = 0.05,
  }) =>
      GoogleFonts.barlowCondensed(
        color: color,
        fontSize: size,
        fontWeight: weight,
        letterSpacing: size * letterSpacing,
      );

  static TextStyle body({
    required Color color,
    double size = 14,
    FontWeight weight = FontWeight.w400,
  }) =>
      GoogleFonts.vazirmatn(color: color, fontSize: size, fontWeight: weight);

  static TextStyle mono({
    required Color color,
    double size = 13,
    FontWeight weight = FontWeight.w600,
  }) =>
      GoogleFonts.jetBrainsMono(color: color, fontSize: size, fontWeight: weight);

  /// The chrome metallic gradient headline text (used for "COINVISION" wordmark).
  static Widget chromeText(String text, {double size = 32, FontWeight weight = FontWeight.w900, double letterSpacing = 0.2}) {
    return ShaderMask(
      shaderCallback: (bounds) => LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: AppColors.chromeGradientDark,
        stops: const [0.0, 0.3, 0.55, 0.8, 1.0],
      ).createShader(bounds),
      child: Text(
        text,
        style: GoogleFonts.barlowCondensed(
          color: Colors.white,
          fontSize: size,
          fontWeight: weight,
          letterSpacing: size * letterSpacing,
        ),
      ),
    );
  }
}
