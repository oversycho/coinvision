import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

class AppTheme {
  static ThemeData build(AppColors c) {
    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: c.bg,
      fontFamily: GoogleFonts.vazirmatn().fontFamily,
      colorScheme: ColorScheme(
        brightness: c == AppColors.dark ? Brightness.dark : Brightness.light,
        primary: c.buy,
        onPrimary: Colors.black,
        secondary: c.chrome,
        onSecondary: Colors.black,
        error: c.loss,
        onError: Colors.white,
        surface: c.card,
        onSurface: c.fg,
      ),
      splashFactory: NoSplash.splashFactory,
      highlightColor: Colors.transparent,
      dividerColor: c.border,
    );
  }
}
