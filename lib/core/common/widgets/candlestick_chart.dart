import 'package:flutter/material.dart';
import '../../../data/mock_data.dart';
import '../../theme/context_ext.dart';

class CandlestickChart extends StatelessWidget {
  final List<Candle> candles;
  final double height;
  const CandlestickChart({super.key, required this.candles, this.height = 230});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return SizedBox(
      height: height,
      width: double.infinity,
      child: CustomPaint(
        painter: _CandlePainter(candles: candles, gainColor: colors.gain, lossColor: colors.loss),
      ),
    );
  }
}

class _CandlePainter extends CustomPainter {
  final List<Candle> candles;
  final Color gainColor;
  final Color lossColor;
  _CandlePainter({required this.candles, required this.gainColor, required this.lossColor});

  @override
  void paint(Canvas canvas, Size size) {
    if (candles.isEmpty) return;
    final highs = candles.map((c) => c.high);
    final lows = candles.map((c) => c.low);
    final maxV = highs.reduce((a, b) => a > b ? a : b);
    final minV = lows.reduce((a, b) => a < b ? a : b);
    final range = (maxV - minV) == 0 ? 1 : (maxV - minV);

    final slotWidth = size.width / candles.length;
    final bodyWidth = slotWidth * 0.6;

    double yFor(double v) => size.height - ((v - minV) / range) * size.height;

    for (int i = 0; i < candles.length; i++) {
      final c = candles[i];
      final cx = i * slotWidth + slotWidth / 2;
      final isUp = c.close >= c.open;
      final color = isUp ? gainColor : lossColor;

      final wickPaint = Paint()..color = color..strokeWidth = 1;
      canvas.drawLine(Offset(cx, yFor(c.high)), Offset(cx, yFor(c.low)), wickPaint);

      final bodyTop = yFor(isUp ? c.close : c.open);
      final bodyBottom = yFor(isUp ? c.open : c.close);
      final rect = Rect.fromLTRB(cx - bodyWidth / 2, bodyTop, cx + bodyWidth / 2, bodyBottom.clamp(bodyTop + 1, size.height));
      canvas.drawRect(rect, Paint()..color = color);
    }
  }

  @override
  bool shouldRepaint(covariant _CandlePainter oldDelegate) =>
      oldDelegate.candles != candles || oldDelegate.gainColor != gainColor || oldDelegate.lossColor != lossColor;
}
