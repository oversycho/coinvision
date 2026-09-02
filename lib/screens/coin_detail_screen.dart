import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../core/common/widgets/app_bottom_sheet.dart';
import '../core/common/widgets/candlestick_chart.dart';
import '../core/common/widgets/coin_icon.dart';
import '../core/common/widgets/ui_primitives.dart';
import '../core/localization/translations.dart';
import '../core/theme/app_text_styles.dart';
import '../core/theme/context_ext.dart';
import '../cubits/locale_cubit.dart';
import '../cubits/market_cubit.dart';
import '../cubits/navigation_cubit.dart';
import '../cubits/orders_cubit.dart';
import '../cubits/wallet_cubit.dart';
import '../data/mock_data.dart';
import '../features/orders/domain/repositories/orders_repository.dart';

class CoinDetailScreen extends StatefulWidget {
  const CoinDetailScreen({super.key});
  @override
  State<CoinDetailScreen> createState() => _CoinDetailScreenState();
}

class _CoinDetailScreenState extends State<CoinDetailScreen> {
  int tabIndex = 0; // 0 = chart, 1 = book
  String? _loadedFor;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final lang = context.lang;
    final isRtl = context.isRtl;
    final nav = context.watch<NavigationCubit>().state;
    final coins = context.watch<MarketCubit>().state;
    final coin = coins.firstWhere((c) => c.id == nav.param, orElse: () => coins.first);
    final isPos = coin.change24h >= 0;

    if (_loadedFor != coin.id) {
      _loadedFor = coin.id;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) context.read<MarketCubit>().loadCandles(coin.id);
      });
    }
    final orderBook = generateOrderBook(coin.price, coin.id.codeUnitAt(0));

    return Directionality(
      textDirection: isRtl ? TextDirection.rtl : TextDirection.ltr,
      child: Container(
        color: colors.bg,
        child: SafeArea(
          child: Stack(
            children: [
              Column(
                children: [
                  // nav bar
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                    child: Row(
                      children: [
                        GestureDetector(
                          onTap: () => context.read<NavigationCubit>().goBack(),
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(color: colors.muted, borderRadius: BorderRadius.circular(12)),
                            child: Icon(isRtl ? Icons.arrow_forward : Icons.arrow_back, size: 18, color: colors.chrome),
                          ),
                        ),
                        const SizedBox(width: 12),
                        CoinIcon(id: coin.id, size: 36),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('${coin.id}/تومان', style: AppFonts.display(color: colors.fg, size: 16, weight: FontWeight.w700)),
                              Text(isRtl ? coin.nameFa : coin.name, style: TextStyle(color: colors.mutedFg, fontSize: 11)),
                            ],
                          ),
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(Tr.formatPrice(coin.price, lang), style: AppFonts.mono(color: colors.fg, size: 13, weight: FontWeight.w600)),
                            const SizedBox(height: 2),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(color: (isPos ? colors.gain : colors.loss).withOpacity(0.12), borderRadius: BorderRadius.circular(999)),
                              child: Text(Tr.formatChange(coin.change24h, lang), style: AppFonts.mono(color: isPos ? colors.gain : colors.loss, size: 11, weight: FontWeight.w700)),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: SegmentedControl(
                      labels: [isRtl ? 'نمودار' : 'Chart', Tr.t('orderBook', lang)],
                      selectedIndex: tabIndex,
                      colors: colors,
                      onChanged: (i) => setState(() => tabIndex = i),
                    ),
                  ),
                  Expanded(
                    child: ListView(
                      padding: const EdgeInsets.only(bottom: 96),
                      children: [
                        const SizedBox(height: 8),
                        if (tabIndex == 0) ...[
                          CandlestickChart(candles: coin.candles),
                          Container(
                            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                            decoration: BoxDecoration(color: colors.muted, borderRadius: BorderRadius.circular(16), border: Border.all(color: colors.border)),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                _StatItem(label: Tr.t('high24h', lang), value: Tr.formatPrice(coin.high24h, lang), color: colors.gain, labelColor: colors.mutedFg),
                                _StatItem(label: Tr.t('low24h', lang), value: Tr.formatPrice(coin.low24h, lang), color: colors.loss, labelColor: colors.mutedFg),
                                _StatItem(label: Tr.t('volume', lang), value: isRtl ? coin.volumeFa : coin.volumeEn, color: colors.chrome, labelColor: colors.mutedFg),
                              ],
                            ),
                          ),
                        ] else
                          _OrderBookView(coin: coin, book: orderBook, lang: lang, isRtl: isRtl, colors: colors),
                      ],
                    ),
                  ),
                ],
              ),
              // fixed buy/sell bar
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: Container(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
                  decoration: BoxDecoration(color: colors.bg.withOpacity(0.9), border: Border(top: BorderSide(color: colors.border))),
                  child: Row(
                    children: [
                      Expanded(
                        child: GradientActionButton.buy(
                          label: '${Tr.t('buy', lang)} ${coin.id}',
                          onTap: () => _openOrderSheet(context, coin, OrderSide.buy, colors, lang, isRtl),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: GradientActionButton.sell(
                          label: '${Tr.t('sell', lang)} ${coin.id}',
                          onTap: () => _openOrderSheet(context, coin, OrderSide.sell, colors, lang, isRtl),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _openOrderSheet(BuildContext context, Coin coin, OrderSide side, colors, AppLang lang, bool isRtl) {
    showAppBottomSheet(
      context: context,
      colors: colors,
      title: '${side == OrderSide.buy ? Tr.t('buy', lang) : Tr.t('sell', lang)} ${coin.id}',
      child: _OrderForm(coin: coin, side: side, colors: colors, lang: lang, isRtl: isRtl),
    );
  }
}

class _StatItem extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  final Color labelColor;
  const _StatItem({required this.label, required this.value, required this.color, required this.labelColor});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label.toUpperCase(), style: AppFonts.display(color: labelColor, size: 9, letterSpacing: 0.15)),
        const SizedBox(height: 2),
        Text(value, style: AppFonts.mono(color: color, size: 12, weight: FontWeight.w700)),
      ],
    );
  }
}

class _OrderBookView extends StatelessWidget {
  final Coin coin;
  final OrderBook book;
  final AppLang lang;
  final bool isRtl;
  final dynamic colors;
  const _OrderBookView({required this.coin, required this.book, required this.lang, required this.isRtl, required this.colors});

  @override
  Widget build(BuildContext context) {
    final maxAmt = [...book.asks, ...book.bids].map((r) => r.amount).reduce((a, b) => a > b ? a : b);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(Tr.t('bids', lang).toUpperCase(), style: AppFonts.display(color: colors.gain, size: 10, weight: FontWeight.w700)),
                const SizedBox(height: 6),
                ...book.bids.take(10).map((row) => _BookRow(row: row, maxAmt: maxAmt, positive: true, lang: lang, colors: colors)),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(Tr.t('asks', lang).toUpperCase(), style: AppFonts.display(color: colors.loss, size: 10, weight: FontWeight.w700)),
                const SizedBox(height: 6),
                ...book.asks.take(10).map((row) => _BookRow(row: row, maxAmt: maxAmt, positive: false, lang: lang, colors: colors)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _BookRow extends StatelessWidget {
  final OrderBookRow row;
  final double maxAmt;
  final bool positive;
  final AppLang lang;
  final dynamic colors;
  const _BookRow({required this.row, required this.maxAmt, required this.positive, required this.lang, required this.colors});

  @override
  Widget build(BuildContext context) {
    final color = positive ? colors.gain : colors.loss;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Stack(
        children: [
          FractionallySizedBox(
            widthFactor: (row.amount / maxAmt).clamp(0.0, 1.0) * 0.6,
            child: Container(height: 20, color: color.withOpacity(0.06)),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(Tr.formatPrice(row.price, lang), style: AppFonts.mono(color: color, size: 11)),
              Text(row.amount.toStringAsFixed(4), style: AppFonts.mono(color: colors.mutedFg, size: 11)),
            ],
          ),
        ],
      ),
    );
  }
}

class _OrderForm extends StatefulWidget {
  final Coin coin;
  final OrderSide side;
  final dynamic colors;
  final AppLang lang;
  final bool isRtl;
  const _OrderForm({required this.coin, required this.side, required this.colors, required this.lang, required this.isRtl});

  @override
  State<_OrderForm> createState() => _OrderFormState();
}

class _OrderFormState extends State<_OrderForm> {
  int typeIndex = 0; // 0 = market, 1 = limit
  final amountCtrl = TextEditingController();
  final priceCtrl = TextEditingController();
  bool placed = false;
  bool submitting = false;
  String? error;

  @override
  Widget build(BuildContext context) {
    final colors = widget.colors;
    final lang = widget.lang;
    final isRtl = widget.isRtl;
    final coin = widget.coin;
    final wallets = context.watch<WalletCubit>().state;

    double walletBalance(String symbol) {
      for (final w in wallets) {
        if (w.coinSymbol == symbol) return w.balance;
      }
      return 0;
    }

    double walletLocked(String symbol) {
      for (final w in wallets) {
        if (w.coinSymbol == symbol) return w.lockedBalance;
      }
      return 0;
    }

    final tomanBalance = walletBalance('TOMAN');
    final coinBalance = walletBalance(coin.id);
    final coinLocked = walletLocked(coin.id);
    final amount = double.tryParse(amountCtrl.text) ?? 0;
    final totalToman = amount * coin.price;
    final available = widget.side == OrderSide.buy ? '${tomanBalance.toStringAsFixed(0)} T' : '${(coinBalance - coinLocked).toStringAsFixed(6)} ${coin.id}';

    void applyPct(int p) {
      double val;
      if (widget.side == OrderSide.buy) {
        val = (tomanBalance * p / 100) / coin.price;
      } else {
        val = (coinBalance - coinLocked) * p / 100;
      }
      amountCtrl.text = val.toStringAsFixed(6);
      setState(() {});
    }

    Future<void> submit() async {
      if (amount <= 0) return;
      setState(() {
        submitting = true;
        error = null;
      });
      try {
        await context.read<OrdersCubit>().place(
              coinSymbol: coin.id,
              side: widget.side == OrderSide.buy ? OrderSideEntity.buy : OrderSideEntity.sell,
              type: typeIndex == 0 ? OrderTypeEntity.market : OrderTypeEntity.limit,
              price: typeIndex == 1 ? (double.tryParse(priceCtrl.text) ?? coin.price) : null,
              amount: amount,
            );
        if (!mounted) return;
        setState(() {
          placed = true;
          submitting = false;
        });
        Future.delayed(const Duration(milliseconds: 1200), () {
          if (mounted) Navigator.of(context).maybePop();
        });
      } catch (e) {
        if (!mounted) return;
        setState(() {
          submitting = false;
          error = e.toString().replaceFirst('Exception: ', '');
        });
      }
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
      child: Directionality(
        textDirection: isRtl ? TextDirection.rtl : TextDirection.ltr,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(Tr.t('available', lang), style: TextStyle(color: colors.mutedFg, fontSize: 12)),
                Text(available, style: AppFonts.mono(color: colors.fg, size: 12, weight: FontWeight.w600)),
              ],
            ),
            const SizedBox(height: 16),
            SegmentedControl(
              labels: [Tr.t('market_order', lang), Tr.t('limit_order', lang)],
              selectedIndex: typeIndex,
              colors: colors,
              onChanged: (i) => setState(() => typeIndex = i),
            ),
            if (typeIndex == 1) ...[
              const SizedBox(height: 16),
              AppTextField(label: '${Tr.t('price', lang)} (تومان)', placeholder: coin.price.toStringAsFixed(0), controller: priceCtrl, colors: colors, keyboardType: TextInputType.number),
            ],
            const SizedBox(height: 16),
            AppTextField(label: '${Tr.t('amount', lang)} (${coin.id})', placeholder: '0.00000', controller: amountCtrl, colors: colors, keyboardType: TextInputType.number),
            const SizedBox(height: 12),
            Row(
              children: [25, 50, 75, 100]
                  .map((p) => Expanded(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 3),
                          child: ChromeButton(label: '$p%', colors: colors, onTap: () => applyPct(p)),
                        ),
                      ))
                  .toList(),
            ),
            if (totalToman > 0) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(color: colors.muted, borderRadius: BorderRadius.circular(14), border: Border.all(color: colors.border)),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(Tr.t('total', lang), style: TextStyle(color: colors.mutedFg, fontSize: 12)),
                    Text('${totalToman.toStringAsFixed(0)} T', style: AppFonts.mono(color: colors.fg, size: 13, weight: FontWeight.w600)),
                  ],
                ),
              ),
            ],
            if (error != null) ...[
              const SizedBox(height: 12),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(color: colors.loss.withOpacity(0.1), borderRadius: BorderRadius.circular(12), border: Border.all(color: colors.loss.withOpacity(0.25))),
                child: Text(error!, textAlign: TextAlign.center, style: TextStyle(color: colors.loss, fontSize: 12, fontWeight: FontWeight.w600)),
              ),
            ],
            const SizedBox(height: 20),
            widget.side == OrderSide.buy
                ? GradientActionButton.buy(
                    label: placed ? (isRtl ? 'سفارش ثبت شد!' : 'Order Placed!') : '${Tr.t('buy', lang)} ${coin.id}',
                    loading: submitting,
                    onTap: (placed || submitting) ? null : submit,
                  )
                : GradientActionButton.sell(
                    label: placed ? (isRtl ? 'سفارش ثبت شد!' : 'Order Placed!') : '${Tr.t('sell', lang)} ${coin.id}',
                    loading: submitting,
                    onTap: (placed || submitting) ? null : submit,
                  ),
          ],
        ),
      ),
    );
  }
}
