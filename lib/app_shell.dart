import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'core/common/widgets/app_tab_bar.dart';
import 'core/theme/context_ext.dart';
import 'cubits/deposit_cubit.dart';
import 'cubits/market_cubit.dart';
import 'cubits/navigation_cubit.dart';
import 'cubits/orders_cubit.dart';
import 'cubits/wallet_cubit.dart';
import 'features/auth/presentation/bloc/auth_bloc.dart';
import 'features/auth/presentation/bloc/auth_state.dart';
import 'screens/auth_screen.dart';
import 'screens/coin_detail_screen.dart';
import 'screens/deposit_screen.dart';
import 'screens/home_screen.dart';
import 'screens/order_history_screen.dart';
import 'screens/portfolio_screen.dart';
import 'screens/settings_screen.dart';
import 'screens/splash_screen.dart';

const _tabScreens = {AppScreen.home, AppScreen.portfolio, AppScreen.deposit, AppScreen.orderHistory, AppScreen.settings};

class AppShell extends StatelessWidget {
  const AppShell({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final lang = context.lang;

    return BlocListener<AuthBloc, AuthState>(
      listener: (context, authState) {
        final navCubit = context.read<NavigationCubit>();
        if (authState is AuthAuthenticated) {
          final userId = authState.user.id;
          context.read<MarketCubit>().start();
          context.read<WalletCubit>().start(userId);
          context.read<OrdersCubit>().start(userId);
          context.read<DepositCubit>().start(userId);
          if (navCubit.state.screen == AppScreen.splash || navCubit.state.screen == AppScreen.auth) {
            navCubit.navigate(AppScreen.home);
          }
        } else if (authState is AuthUnauthenticated) {
          if (navCubit.state.screen != AppScreen.splash) {
            navCubit.navigate(AppScreen.auth);
          }
        }
      },
      child: BlocBuilder<NavigationCubit, NavState>(
        builder: (context, nav) {
          Widget body;
          switch (nav.screen) {
            case AppScreen.splash:
              body = const SplashScreen();
              break;
            case AppScreen.auth:
              body = const AuthScreen();
              break;
            case AppScreen.home:
              body = const HomeScreen();
              break;
            case AppScreen.coinDetail:
              body = const CoinDetailScreen();
              break;
            case AppScreen.portfolio:
              body = const PortfolioScreen();
              break;
            case AppScreen.deposit:
              body = const DepositScreen();
              break;
            case AppScreen.orderHistory:
              body = const OrderHistoryScreen();
              break;
            case AppScreen.settings:
              body = const SettingsScreen();
              break;
          }

          final showTabBar = _tabScreens.contains(nav.screen);

          return Scaffold(
            backgroundColor: colors.bg,
            body: AnimatedSwitcher(
              duration: const Duration(milliseconds: 220),
              child: KeyedSubtree(key: ValueKey(nav.screen), child: body),
            ),
            bottomNavigationBar: showTabBar ? AppTabBar(current: nav.screen, colors: colors, lang: lang) : null,
          );
        },
      ),
    );
  }
}
