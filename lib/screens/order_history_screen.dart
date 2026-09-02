import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../core/common/widgets/coin_icon.dart';
import '../core/common/widgets/status_badge.dart';
import '../core/common/widgets/ui_primitives.dart';
import '../core/localization/translations.dart';
import '../core/theme/app_text_styles.dart';
import '../core/theme/context_ext.dart';
import '../cubits/locale_cubit.dart';
import '../cubits/orders_cubit.dart';
import '../features/orders/domain/repositories/orders_repository.dart';

class OrderHistoryScreen extends StatefulWidget {
  const OrderHistoryScreen({super.key});
  @override
  State<OrderHistoryScreen> createState() => _OrderHistoryScreenState();
}

class _OrderHistoryScreenState extends State<OrderHistoryScreen> {
  int tab = 0; // 0 open, 1 history, 2 trades
  String? cancellingId;

  Future<void> _cancel(String orderId) async {
    setState(() => cancellingId = orderId);
    try {
      await context.read<OrdersCubit>().cancel(orderId);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString().replaceFirst('Exception: ', ''))));
      }
    } finally {
      if (mounted) setState(() => cancellingId = null);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final lang = context.lang;
    final isRtl = context.isRtl;

    return Directionality(
      textDirection: isRtl ? TextDirection.rtl : TextDirection.ltr,
      child: Container(
        color: colors.bg,
        child: SafeArea(
          child: BlocBuilder<OrdersCubit, List<OrderEntity>>(
            builder: (context, orders) {
              final openOrders = orders.where((o) => o.status == OrderStatusEntity.open || o.status == OrderStatusEntity.partiallyFilled).toList();
              final historyOrders = orders.where((o) => o.status == OrderStatusEntity.filled || o.status == OrderStatusEntity.cancelled).toList();
              final tradeOrders = orders.where((o) => o.status == OrderStatusEntity.filled).toList();
              final list = tab == 0 ? openOrders : (tab == 1 ? historyOrders : tradeOrders);

              return Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 8, 20, 8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(Tr.t('orders', lang), style: AppFonts.display(color: colors.fg, size: 24, weight: FontWeight.w900)),
                            if (openOrders.isNotEmpty)
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                decoration: BoxDecoration(color: colors.buy.withOpacity(0.15), borderRadius: BorderRadius.circular(999)),
                                child: Text('${openOrders.length}', style: AppFonts.mono(color: colors.buy, size: 12, weight: FontWeight.w700)),
                              ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        SegmentedControl(
                          labels: [Tr.t('openOrders', lang), Tr.t('orderHistory', lang), Tr.t('tradeHistory', lang)],
                          selectedIndex: tab,
                          colors: colors,
                          onChanged: (i) => setState(() => tab = i),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: list.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.receipt_long_outlined, size: 48, color: colors.border),
                                const SizedBox(height: 16),
                                Text(isRtl ? 'سفارشی وجود ندارد' : 'No orders found', style: TextStyle(color: colors.mutedFg, fontSize: 13)),
                              ],
                            ),
                          )
                        : ListView(
                            padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                            children: list
                                .map((o) => Padding(
                                      padding: const EdgeInsets.only(bottom: 8),
                                      child: _OrderCard(
                                        order: o,
                                        lang: lang,
                                        isRtl: isRtl,
                                        colors: colors,
                                        cancelling: cancellingId == o.id,
                                        onCancel: tab == 0 ? () => _cancel(o.id) : null,
                                      ),
                                    ))
                                .toList(),
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

class _OrderCard extends StatelessWidget {
  final OrderEntity order;
  final AppLang lang;
  final bool isRtl;
  final dynamic colors;
  final bool cancelling;
  final VoidCallback? onCancel;
  const _OrderCard({required this.order, required this.lang, required this.isRtl, required this.colors, this.cancelling = false, this.onCancel});

  @override
  Widget build(BuildContext context) {
    final isBuy = order.side == OrderSideEntity.buy;
    final filledPct = order.amount > 0 ? (order.filledAmount / order.amount * 100) : 0.0;
    final showProgress = (order.status == OrderStatusEntity.open || order.status == OrderStatusEntity.partiallyFilled) && order.filledAmount > 0;
    final priceLabel = order.price != null ? Tr.formatPrice(order.price!, lang) : (isRtl ? 'بازار' : 'Market');

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: colors.card, borderRadius: BorderRadius.circular(18), border: Border.all(color: colors.border)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CoinIcon(id: order.coinSymbol, size: 32),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('${order.coinSymbol}/تومان', style: AppFonts.display(color: colors.fg, size: 14, weight: FontWeight.w700)),
                    const SizedBox(height: 3),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                          decoration: BoxDecoration(color: (isBuy ? colors.buy : colors.sell).withOpacity(0.12), borderRadius: BorderRadius.circular(999)),
                          child: Text(isBuy ? Tr.t('buy', lang) : Tr.t('sell', lang), style: TextStyle(color: isBuy ? colors.buy : colors.sell, fontSize: 10, fontWeight: FontWeight.w700)),
                        ),
                        const SizedBox(width: 6),
                        Text(order.type == OrderTypeEntity.limit ? Tr.t('type_limit', lang) : Tr.t('type_market', lang), style: TextStyle(color: colors.mutedFg, fontSize: 10)),
                      ],
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  StatusBadge(status: order.status, lang: lang),
                  const SizedBox(height: 3),
                  Text(order.id.substring(0, 8), style: AppFonts.mono(color: colors.mutedFg, size: 9)),
                ],
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(child: _DetailCol(label: Tr.t('price_col', lang), value: priceLabel, colors: colors)),
              Expanded(child: _DetailCol(label: Tr.t('amount', lang), value: '${order.amount}', colors: colors)),
              Expanded(child: _DetailCol(label: Tr.t('filled_label', lang), value: '${order.filledAmount}/${order.amount}', colors: colors)),
            ],
          ),
          if (showProgress) ...[
            const SizedBox(height: 10),
            ClipRRect(
              borderRadius: BorderRadius.circular(999),
              child: LinearProgressIndicator(value: (filledPct / 100).clamp(0.0, 1.0), backgroundColor: colors.border, color: colors.buy, minHeight: 5),
            ),
            const SizedBox(height: 4),
            Text('${filledPct.toStringAsFixed(0)}% ${isRtl ? 'انجام‌شده' : 'filled'}', style: TextStyle(color: colors.mutedFg, fontSize: 10)),
          ],
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(Tr.formatTime(order.createdAt, lang), style: AppFonts.mono(color: colors.mutedFg, size: 10)),
              if (onCancel != null)
                GestureDetector(
                  onTap: cancelling ? null : onCancel,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(color: colors.loss.withOpacity(0.1), borderRadius: BorderRadius.circular(10), border: Border.all(color: colors.loss.withOpacity(0.2))),
                    child: cancelling
                        ? SizedBox(width: 12, height: 12, child: CircularProgressIndicator(strokeWidth: 1.5, color: colors.loss))
                        : Text(Tr.t('cancelOrder', lang), style: TextStyle(color: colors.loss, fontSize: 11, fontWeight: FontWeight.w700)),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _DetailCol extends StatelessWidget {
  final String label;
  final String value;
  final dynamic colors;
  const _DetailCol({required this.label, required this.value, required this.colors});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label.toUpperCase(), style: TextStyle(color: colors.mutedFg, fontSize: 9, fontWeight: FontWeight.w600)),
        const SizedBox(height: 2),
        Text(value, style: AppFonts.mono(color: colors.fg, size: 11, weight: FontWeight.w600)),
      ],
    );
  }
}
