import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../core/common/widgets/coin_icon.dart';
import '../core/common/widgets/gothic_logo.dart';
import '../core/common/widgets/sparkline_chart.dart';
import '../core/common/widgets/ui_primitives.dart';
import '../core/localization/translations.dart';
import '../core/theme/app_text_styles.dart';
import '../core/theme/context_ext.dart';
import '../cubits/locale_cubit.dart';
import '../cubits/market_cubit.dart';
import '../cubits/navigation_cubit.dart';
import '../cubits/theme_cubit.dart';
import '../data/mock_data.dart';

enum _Sort { defaultOrder, change, price }

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final searchCtrl = TextEditingController();
  _Sort sort = _Sort.defaultOrder;

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
          bottom: false,
          child: BlocBuilder<MarketCubit, List<Coin>>(
            builder: (context, coins) {
              var filtered = [...coins];
              final q = searchCtrl.text.toLowerCase();
              if (q.isNotEmpty) {
                filtered = filtered.where((c) => c.id.toLowerCase().contains(q) || c.name.toLowerCase().contains(q) || c.nameFa.contains(q)).toList();
              }
              if (sort == _Sort.change) filtered.sort((a, b) => b.change24h.compareTo(a.change24h));
              if (sort == _Sort.price) filtered.sort((a, b) => b.price.compareTo(a.price));
              final topGainer = [...coins]..sort((a, b) => b.change24h.compareTo(a.change24h));

              return Column(
                children: [
                  // Nav bar
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
                    child: Row(
                      children: [
                        const GothicLogo(size: 30),
                        const SizedBox(width: 10),
                        AppFonts.chromeText('COINVISION', size: 20, letterSpacing: 0.15),
                        const Spacer(),
                        Container(
                          padding: const EdgeInsets.all(7),
                          decoration: BoxDecoration(color: colors.muted, shape: BoxShape.circle),
                          child: Stack(
                            clipBehavior: Clip.none,
                            children: [
                              Icon(Icons.notifications_none_rounded, size: 18, color: colors.chrome),
                              Positioned(
                                top: -1,
                                right: -1,
                                child: Container(
                                  width: 8,
                                  height: 8,
                                  decoration: BoxDecoration(color: colors.buy, shape: BoxShape.circle, boxShadow: [BoxShadow(color: colors.buy, blurRadius: 6)]),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: ListView(
                      padding: const EdgeInsets.only(bottom: 16),
                      children: [
                        // Top gainer banner
                        Padding(
                          padding: const EdgeInsets.fromLTRB(16, 4, 16, 4),
                          child: GestureDetector(
                            onTap: () => context.read<NavigationCubit>().navigate(AppScreen.coinDetail, param: topGainer.first.id),
                            child: ChromeSurface(
                              isDark: context.watch<ThemeCubit>().state == AppThemeMode.dark,
                              radius: 20,
                              child: Row(
                                children: [
                                  CoinIcon(id: topGainer.first.id, size: 42),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(Tr.t('topGainers', lang).toUpperCase(),
                                            style: AppFonts.display(color: colors.mutedFg, size: 10, letterSpacing: 0.2)),
                                        const SizedBox(height: 2),
                                        Text(isRtl ? topGainer.first.nameFa : topGainer.first.name,
                                            style: AppFonts.display(color: colors.fg, size: 16)),
                                      ],
                                    ),
                                  ),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      Text('${Tr.formatPrice(topGainer.first.price, lang)} ${isRtl ? 'ت' : 'T'}',
                                          style: AppFonts.mono(color: colors.fg, size: 13, weight: FontWeight.w700)),
                                      const SizedBox(height: 4),
                                      _ChangeBadge(value: topGainer.first.change24h, lang: lang, colors: colors),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        // Search + sort
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Row(
                            children: [
                              Expanded(
                                child: SizedBox(
                                  height: 42,
                                  child: TextField(
                                    controller: searchCtrl,
                                    onChanged: (_) => setState(() {}),
                                    textDirection: isRtl ? TextDirection.rtl : TextDirection.ltr,
                                    style: TextStyle(color: colors.fg, fontSize: 13),
                                    decoration: InputDecoration(
                                      prefixIcon: Icon(Icons.search, size: 18, color: colors.mutedFg),
                                      hintText: Tr.t('search', lang),
                                      hintStyle: TextStyle(color: colors.mutedFg, fontSize: 13),
                                      filled: true,
                                      fillColor: colors.muted,
                                      contentPadding: EdgeInsets.zero,
                                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: colors.border)),
                                      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: colors.border)),
                                      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: colors.buy)),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              ...[
                                (_Sort.defaultOrder, isRtl ? 'همه' : 'All'),
                                (_Sort.change, isRtl ? 'تغییر' : '%'),
                                (_Sort.price, isRtl ? 'قیمت' : '\$'),
                              ].map((entry) {
                                final active = sort == entry.$1;
                                return Padding(
                                  padding: const EdgeInsets.only(left: 4),
                                  child: GestureDetector(
                                    onTap: () => setState(() => sort = entry.$1),
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 11),
                                      decoration: BoxDecoration(
                                        color: active ? colors.buy : colors.muted,
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: Text(entry.$2,
                                          style: AppFonts.display(color: active ? Colors.black : colors.mutedFg, size: 11, weight: FontWeight.w600)),
                                    ),
                                  ),
                                );
                              }),
                            ],
                          ),
                        ),
                        const SizedBox(height: 12),
                        if (filtered.isEmpty)
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 48),
                            child: Center(child: Text(isRtl ? 'ارزی یافت نشد' : 'No coins found', style: TextStyle(color: colors.mutedFg))),
                          )
                        else
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            child: Column(
                              children: filtered
                                  .map((coin) => Padding(
                                        padding: const EdgeInsets.only(bottom: 6),
                                        child: _CoinRow(coin: coin, lang: lang, isRtl: isRtl, colors: colors),
                                      ))
                                  .toList(),
                            ),
                          ),
                      ],
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

class _ChangeBadge extends StatelessWidget {
  final double value;
  final AppLang lang;
  final dynamic colors;
  const _ChangeBadge({required this.value, required this.lang, required this.colors});

  @override
  Widget build(BuildContext context) {
    final isPos = value >= 0;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(color: (isPos ? colors.gain : colors.loss).withOpacity(0.12), borderRadius: BorderRadius.circular(999)),
      child: Text(Tr.formatChange(value, lang), style: AppFonts.mono(color: isPos ? colors.gain : colors.loss, size: 11, weight: FontWeight.w700)),
    );
  }
}

class _CoinRow extends StatelessWidget {
  final Coin coin;
  final AppLang lang;
  final bool isRtl;
  final dynamic colors;
  const _CoinRow({required this.coin, required this.lang, required this.isRtl, required this.colors});

  @override
  Widget build(BuildContext context) {
    final isPos = coin.change24h >= 0;
    return GestureDetector(
      onTap: () => context.read<NavigationCubit>().navigate(AppScreen.coinDetail, param: coin.id),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(color: colors.card, borderRadius: BorderRadius.circular(18), border: Border.all(color: colors.border)),
        child: Row(
          children: [
            CoinIcon(id: coin.id, size: 40),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(coin.id, style: AppFonts.display(color: colors.fg, size: 14, weight: FontWeight.w700)),
                  Text(isRtl ? coin.nameFa : coin.name, style: TextStyle(color: colors.mutedFg, fontSize: 11), maxLines: 1, overflow: TextOverflow.ellipsis),
                ],
              ),
            ),
            SizedBox(width: 64, child: SparklineChart(data: coin.sparkline, positive: isPos)),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(Tr.formatPrice(coin.price, lang), style: AppFonts.mono(color: colors.fg, size: 13, weight: FontWeight.w600)),
                const SizedBox(height: 2),
                _ChangeBadge(value: coin.change24h, lang: lang, colors: colors),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
