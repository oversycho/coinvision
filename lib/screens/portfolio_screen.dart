import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../core/common/widgets/coin_icon.dart';
import '../core/common/widgets/ui_primitives.dart';
import '../core/localization/translations.dart';
import '../core/theme/app_text_styles.dart';
import '../core/theme/context_ext.dart';
import '../cubits/locale_cubit.dart';
import '../cubits/market_cubit.dart';
import '../cubits/navigation_cubit.dart';
import '../cubits/theme_cubit.dart';
import '../cubits/wallet_cubit.dart';
import '../features/wallet/domain/repositories/wallet_repository.dart';

class PortfolioScreen extends StatefulWidget {
  const PortfolioScreen({super.key});
  @override
  State<PortfolioScreen> createState() => _PortfolioScreenState();
}

class _PortfolioScreenState extends State<PortfolioScreen> {
  bool showBalances = true;
  int rangeIndex = 1; // 7D, 1M, 3M, ALL
  final ranges = ['7D', '1M', '3M', 'ALL'];
  late Future<List<PortfolioSnapshotEntity>> _snapshotsFuture;

  @override
  void initState() {
    super.initState();
    _snapshotsFuture = context.read<WalletCubit>().loadSnapshots(limitDays: 90);
  }

  void _reload() {
    setState(() {
      _snapshotsFuture = context.read<WalletCubit>().loadSnapshots(limitDays: 90);
    });
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final lang = context.lang;
    final isRtl = context.isRtl;
    final coins = context.watch<MarketCubit>().state;
    final wallets = context.watch<WalletCubit>().state;

    double totalToman = 0;
    for (final w in wallets) {
      if (w.coinSymbol == 'TOMAN') {
        totalToman += w.balance + w.lockedBalance;
      } else {
        final coin = coins.firstWhere((c) => c.id == w.coinSymbol, orElse: () => coins.first);
        totalToman += (w.balance + w.lockedBalance) * coin.price;
      }
    }

    final holdingWallets = wallets.where((w) => w.coinSymbol != 'TOMAN' && (w.balance + w.lockedBalance) > 0).toList();

    return Directionality(
      textDirection: isRtl ? TextDirection.rtl : TextDirection.ltr,
      child: Container(
        color: colors.bg,
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(Tr.t('portfolio', lang), style: AppFonts.display(color: colors.fg, size: 24, weight: FontWeight.w900)),
                    GestureDetector(
                      onTap: () => setState(() => showBalances = !showBalances),
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(color: colors.muted, borderRadius: BorderRadius.circular(12)),
                        child: Icon(showBalances ? Icons.visibility_outlined : Icons.visibility_off_outlined, size: 16, color: colors.mutedFg),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.only(bottom: 16),
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: ChromeSurface(
                        isDark: context.watch<ThemeCubit>().state == AppThemeMode.dark,
                        radius: 24,
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(Tr.t('totalBalance', lang).toUpperCase(), style: AppFonts.display(color: colors.mutedFg, size: 10, letterSpacing: 0.2)),
                            const SizedBox(height: 4),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(showBalances ? Tr.formatPrice(totalToman, lang) : '••••••',
                                    style: AppFonts.display(color: colors.fg, size: 34, weight: FontWeight.w900)),
                                const SizedBox(width: 8),
                                Padding(
                                  padding: const EdgeInsets.only(bottom: 4),
                                  child: Text(Tr.t('toman', lang), style: TextStyle(color: colors.mutedFg, fontSize: 15)),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Container(
                        decoration: BoxDecoration(color: colors.muted, borderRadius: BorderRadius.circular(24), border: Border.all(color: colors.border)),
                        child: Column(
                          children: [
                            Padding(
                              padding: const EdgeInsets.fromLTRB(16, 14, 16, 4),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(Tr.t('performance', lang), style: TextStyle(color: colors.mutedFg, fontWeight: FontWeight.w600, fontSize: 13)),
                                  Row(
                                    children: List.generate(ranges.length, (i) {
                                      final active = i == rangeIndex;
                                      return GestureDetector(
                                        onTap: () => setState(() => rangeIndex = i),
                                        child: Container(
                                          margin: const EdgeInsets.only(left: 4),
                                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                          decoration: BoxDecoration(color: active ? colors.buy : Colors.transparent, borderRadius: BorderRadius.circular(8)),
                                          child: Text(ranges[i], style: AppFonts.mono(color: active ? Colors.black : colors.mutedFg, size: 11, weight: FontWeight.w700)),
                                        ),
                                      );
                                    }),
                                  ),
                                ],
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.fromLTRB(8, 0, 8, 12),
                              child: SizedBox(
                                height: 110,
                                child: FutureBuilder<List<PortfolioSnapshotEntity>>(
                                  future: _snapshotsFuture,
                                  builder: (context, snap) {
                                    if (snap.connectionState != ConnectionState.done) {
                                      return Center(child: CircularProgressIndicator(strokeWidth: 2, color: colors.buy));
                                    }
                                    final snapshots = snap.data ?? const [];
                                    final days = rangeIndex == 0 ? 7 : (rangeIndex == 2 ? 90 : 30);
                                    final cutoff = DateTime.now().subtract(Duration(days: days));
                                    final filtered = snapshots.where((s) => s.recordedAt.isAfter(cutoff)).map((s) => s.totalToman).toList();
                                    if (filtered.length < 2) {
                                      return Center(
                                        child: Text(
                                          isRtl ? 'داده کافی برای نمودار هنوز جمع نشده' : 'Not enough history yet',
                                          style: TextStyle(color: colors.mutedFg, fontSize: 11),
                                        ),
                                      );
                                    }
                                    return CustomPaint(painter: _PortfolioLinePainter(filtered, colors.buy), size: Size.infinite);
                                  },
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Text(Tr.t('holdings', lang).toUpperCase(),
                          style: AppFonts.display(color: colors.mutedFg, size: 13, weight: FontWeight.w700, letterSpacing: 0.15)),
                    ),
                    const SizedBox(height: 10),
                    if (holdingWallets.isEmpty)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 32),
                        child: Center(child: Text(isRtl ? 'هنوز دارایی‌ای ندارید' : 'No holdings yet', style: TextStyle(color: colors.mutedFg))),
                      )
                    else
                      ...holdingWallets.map((w) {
                        final coin = coins.firstWhere((c) => c.id == w.coinSymbol, orElse: () => coins.first);
                        final value = w.balance * coin.price;
                        final hasCost = w.avgBuyPrice != null && w.avgBuyPrice! > 0;
                        final pnl = hasCost ? (coin.price - w.avgBuyPrice!) / w.avgBuyPrice! * 100 : null;
                        return Padding(
                          padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                          child: GestureDetector(
                            onTap: () => context.read<NavigationCubit>().navigate(AppScreen.coinDetail, param: w.coinSymbol),
                            child: Container(
                              padding: const EdgeInsets.all(14),
                              decoration: BoxDecoration(color: colors.card, borderRadius: BorderRadius.circular(18), border: Border.all(color: colors.border)),
                              child: Row(
                                children: [
                                  CoinIcon(id: w.coinSymbol, size: 40),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(w.coinSymbol, style: AppFonts.display(color: colors.fg, size: 14, weight: FontWeight.w700)),
                                        const SizedBox(height: 2),
                                        Row(
                                          children: [
                                            Text(showBalances ? w.balance.toStringAsFixed(6) : '••••', style: TextStyle(color: colors.mutedFg, fontSize: 11)),
                                            if (w.lockedBalance > 0) ...[
                                              const SizedBox(width: 6),
                                              Text(isRtl ? 'قفل: ${w.lockedBalance}' : 'locked: ${w.lockedBalance}', style: TextStyle(color: colors.sell, fontSize: 11)),
                                            ],
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      Text(showBalances ? Tr.formatPrice(value, lang) : '••••', style: AppFonts.mono(color: colors.fg, size: 13, weight: FontWeight.w600)),
                                      if (pnl != null) ...[
                                        const SizedBox(height: 3),
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                                          decoration: BoxDecoration(color: (pnl >= 0 ? colors.gain : colors.loss).withOpacity(0.12), borderRadius: BorderRadius.circular(999)),
                                          child: Text(Tr.formatChange(pnl, lang), style: AppFonts.mono(color: pnl >= 0 ? colors.gain : colors.loss, size: 11, weight: FontWeight.w700)),
                                        ),
                                      ],
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      }),
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

class _PortfolioLinePainter extends CustomPainter {
  final List<double> data;
  final Color color;
  _PortfolioLinePainter(this.data, this.color);

  @override
  void paint(Canvas canvas, Size size) {
    if (data.length < 2) return;
    final minV = data.reduce((a, b) => a < b ? a : b);
    final maxV = data.reduce((a, b) => a > b ? a : b);
    final range = (maxV - minV) == 0 ? 1 : (maxV - minV);

    final path = Path();
    final points = <Offset>[];
    for (int i = 0; i < data.length; i++) {
      final x = i / (data.length - 1) * size.width;
      final y = size.height - 12 - ((data[i] - minV) / range) * (size.height - 24);
      points.add(Offset(x, y));
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }

    final fillPath = Path.from(path)
      ..lineTo(points.last.dx, size.height)
      ..lineTo(points.first.dx, size.height)
      ..close();

    canvas.drawPath(
      fillPath,
      Paint()
        ..shader = LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [
          color.withOpacity(0.25),
          color.withOpacity(0),
        ]).createShader(Rect.fromLTWH(0, 0, size.width, size.height)),
    );

    canvas.drawPath(path, Paint()..color = color..style = PaintingStyle.stroke..strokeWidth = 2..strokeCap = StrokeCap.round);
    canvas.drawCircle(points.last, 4, Paint()..color = color);
  }

  @override
  bool shouldRepaint(covariant _PortfolioLinePainter oldDelegate) => oldDelegate.data != data;
}
