import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../core/common/widgets/coin_icon.dart';
import '../core/localization/translations.dart';
import '../core/theme/app_text_styles.dart';
import '../core/theme/context_ext.dart';
import '../cubits/locale_cubit.dart';
import '../cubits/realized_pnl_cubit.dart';
import '../features/wallet/domain/repositories/wallet_repository.dart';

class RealizedPnlHistoryScreen extends StatelessWidget {
  const RealizedPnlHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final lang = context.lang;
    final isRtl = context.isRtl;

    return Directionality(
      textDirection: isRtl ? TextDirection.rtl : TextDirection.ltr,
      child: Scaffold(
        backgroundColor: colors.bg,
        body: SafeArea(
          child: BlocBuilder<RealizedPnlCubit, List<RealizedPnlEntity>>(
            builder: (context, entries) {
              final total = entries.fold<double>(0, (sum, e) => sum + e.pnl);
              return Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
                    child: Row(
                      children: [
                        GestureDetector(
                          onTap: () => Navigator.of(context).maybePop(),
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                                color: colors.muted,
                                borderRadius: BorderRadius.circular(12)),
                            child: Icon(
                                isRtl ? Icons.arrow_forward : Icons.arrow_back,
                                size: 18,
                                color: colors.chrome),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          isRtl
                              ? 'تاریخچه سود تحقق‌یافته'
                              : 'Realized P&L History',
                          style: AppFonts.display(
                              color: colors.fg,
                              size: 18,
                              weight: FontWeight.w800),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                          color: colors.muted,
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(color: colors.border)),
                      child: Column(
                        children: [
                          Text((isRtl ? 'مجموع' : 'Total').toUpperCase(),
                              style: AppFonts.display(
                                  color: colors.mutedFg,
                                  size: 10,
                                  letterSpacing: 0.2)),
                          const SizedBox(height: 4),
                          Text(
                            '${total >= 0 ? '+' : ''}${Tr.formatPrice(total, lang)} ${Tr.t('toman', lang)}',
                            style: AppFonts.display(
                                color: total >= 0 ? colors.gain : colors.loss,
                                size: 22,
                                weight: FontWeight.w900),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Expanded(
                    child: entries.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.receipt_long_outlined,
                                    size: 48, color: colors.border),
                                const SizedBox(height: 16),
                                Text(
                                    isRtl
                                        ? 'هنوز فروشی ثبت نشده'
                                        : 'No sells recorded yet',
                                    style: TextStyle(
                                        color: colors.mutedFg, fontSize: 13)),
                              ],
                            ),
                          )
                        : ListView.builder(
                            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                            itemCount: entries.length,
                            itemBuilder: (context, i) {
                              final e = entries[i];
                              final isProfit = e.pnl >= 0;
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 8),
                                child: Container(
                                  padding: const EdgeInsets.all(14),
                                  decoration: BoxDecoration(
                                      color: colors.card,
                                      borderRadius: BorderRadius.circular(16),
                                      border: Border.all(color: colors.border)),
                                  child: Row(
                                    children: [
                                      CoinIcon(id: e.coinSymbol, size: 36),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                                '${e.coinSymbol} — ${e.amount.toStringAsFixed(6)}',
                                                style: AppFonts.display(
                                                    color: colors.fg,
                                                    size: 13,
                                                    weight: FontWeight.w700)),
                                            const SizedBox(height: 2),
                                            Text(
                                              e.avgCost != null
                                                  ? '${isRtl ? 'خرید' : 'cost'}: ${Tr.formatPrice(e.avgCost!, lang)} → ${isRtl ? 'فروش' : 'sell'}: ${Tr.formatPrice(e.sellPrice, lang)}'
                                                  : (isRtl
                                                      ? 'بدون قیمت خرید مرجع'
                                                      : 'no cost basis on record'),
                                              style: TextStyle(
                                                  color: colors.mutedFg,
                                                  fontSize: 11),
                                            ),
                                            const SizedBox(height: 2),
                                            Text(
                                                Tr.formatTime(
                                                    e.recordedAt, lang),
                                                style: AppFonts.mono(
                                                    color: colors.mutedFg,
                                                    size: 10)),
                                          ],
                                        ),
                                      ),
                                      Text(
                                        '${isProfit ? '+' : ''}${Tr.formatPrice(e.pnl, lang)}',
                                        style: AppFonts.mono(
                                            color: isProfit
                                                ? colors.gain
                                                : colors.loss,
                                            size: 13,
                                            weight: FontWeight.w700),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
