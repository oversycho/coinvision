import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'app_shell.dart';
import 'core/theme/app_theme.dart';
import 'cubits/deposit_cubit.dart';
import 'cubits/kyc_cubit.dart';
import 'cubits/locale_cubit.dart';
import 'cubits/market_cubit.dart';
import 'cubits/navigation_cubit.dart';
import 'cubits/orders_cubit.dart';
import 'cubits/theme_cubit.dart';
import 'cubits/wallet_cubit.dart';
import 'features/auth/presentation/bloc/auth_bloc.dart';
import 'features/auth/presentation/bloc/auth_event.dart';
import 'features/deposit/domain/repositories/deposit_repository.dart';
import 'features/kyc/domain/repositories/kyc_repository.dart';
import 'features/market/domain/repositories/market_repository.dart';
import 'features/orders/domain/repositories/orders_repository.dart';
import 'features/wallet/domain/repositories/wallet_repository.dart';
import 'injection_container.dart';

class CoinVisionApp extends StatelessWidget {
  const CoinVisionApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => ThemeCubit()),
        BlocProvider(create: (_) => LocaleCubit()),
        BlocProvider(create: (_) => NavigationCubit()),
        BlocProvider(create: (_) => sl<AuthBloc>()..add(AuthCheckRequested())),
        BlocProvider(create: (_) => MarketCubit(sl<MarketRepository>())),
        BlocProvider(create: (_) => WalletCubit(sl<WalletRepository>())),
        BlocProvider(create: (_) => OrdersCubit(sl<OrdersRepository>())),
        BlocProvider(create: (_) => DepositCubit(sl<DepositRepository>())),
        BlocProvider(create: (_) => KycCubit(sl<KycRepository>())),
      ],
      child: BlocBuilder<ThemeCubit, AppThemeMode>(
        builder: (context, themeMode) {
          final colors = context.read<ThemeCubit>().colors;
          return BlocBuilder<LocaleCubit, AppLang>(
            builder: (context, lang) {
              return MaterialApp(
                debugShowCheckedModeBanner: false,
                title: 'CoinVision',
                theme: AppTheme.build(colors),
                locale: Locale(lang == AppLang.fa ? 'fa' : 'en'),
                supportedLocales: const [Locale('en'), Locale('fa')],
                localizationsDelegates: const [
                  GlobalMaterialLocalizations.delegate,
                  GlobalWidgetsLocalizations.delegate,
                  GlobalCupertinoLocalizations.delegate,
                ],
                builder: (context, child) => Directionality(
                  textDirection: lang == AppLang.fa ? TextDirection.rtl : TextDirection.ltr,
                  child: child!,
                ),
                home: const AppShell(),
              );
            },
          );
        },
      ),
    );
  }
}
