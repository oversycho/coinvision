import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../theme/app_colors.dart';

class CoinIcon extends StatelessWidget {
  final String id;
  final double size;
  const CoinIcon({super.key, required this.id, this.size = 40});

  @override
  Widget build(BuildContext context) {
    final bg = AppColors.coinColorFor(id);
    final char = AppColors.coinCharFor(id);
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          center: const Alignment(-0.3, -0.5),
          radius: 1.3,
          colors: [Colors.white.withOpacity(0.28), bg],
          stops: const [0.0, 0.5],
        ),
      ),
      alignment: Alignment.center,
      child: Text(
        char,
        style: GoogleFonts.jetBrainsMono(
          color: Colors.white,
          fontSize: size * 0.42,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
