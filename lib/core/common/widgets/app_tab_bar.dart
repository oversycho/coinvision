import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../localization/translations.dart';
import '../../theme/app_text_styles.dart';
import '../../../cubits/locale_cubit.dart';
import '../../../cubits/navigation_cubit.dart';

class AppTabBar extends StatelessWidget {
  final AppScreen current;
  final dynamic colors;
  final AppLang lang;
  const AppTabBar(
      {super.key,
      required this.current,
      required this.colors,
      required this.lang});

  static const _tabs = [
    (
      AppScreen.home,
      Icons.candlestick_chart_outlined,
      Icons.candlestick_chart,
      'market'
    ),
    (
      AppScreen.portfolio,
      Icons.pie_chart_outline,
      Icons.pie_chart,
      'portfolio'
    ),
    (AppScreen.deposit, Icons.add_circle_outline, Icons.add_circle, 'deposit'),
    (
      AppScreen.orderHistory,
      Icons.receipt_long_outlined,
      Icons.receipt_long,
      'orders'
    ),
    (AppScreen.settings, Icons.person_outline, Icons.person, 'settings'),
  ];

  @override
  Widget build(BuildContext context) {
    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 24, sigmaY: 24),
        child: Container(
          padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).padding.bottom, top: 8),
          decoration: BoxDecoration(
              color: colors.bg.withOpacity(0.85),
              border:
                  Border(top: BorderSide(color: colors.fg.withOpacity(0.06)))),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: _tabs.map((t) {
              final active = current == t.$1;
              return GestureDetector(
                onTap: () => context.read<NavigationCubit>().navigate(t.$1),
                behavior: HitTestBehavior.opaque,
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(vertical: 6, horizontal: 10),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(active ? t.$3 : t.$2,
                          size: 23,
                          color: active ? colors.buy : colors.mutedFg),
                      const SizedBox(height: 3),
                      Text(Tr.t(t.$4, lang),
                          style: AppFonts.display(
                              color: active ? colors.buy : colors.mutedFg,
                              size: 10,
                              weight:
                                  active ? FontWeight.w700 : FontWeight.w500)),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ),
    );
  }
}
