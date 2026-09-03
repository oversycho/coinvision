import 'package:get_it/get_it.dart';
import 'core/supabase/supabase_config.dart';

import 'features/auth/data/datasources/auth_remote_data_source.dart';
import 'features/auth/data/repositories/auth_repository_impl.dart';
import 'features/auth/domain/repositories/auth_repository.dart';
import 'features/auth/domain/usecases/auth_usecases.dart';
import 'features/auth/presentation/bloc/auth_bloc.dart';

import 'features/market/data/datasources/market_remote_data_source.dart';
import 'features/market/data/repositories/market_repository_impl.dart';
import 'features/market/domain/repositories/market_repository.dart';

import 'features/wallet/data/datasources/wallet_remote_data_source.dart';
import 'features/wallet/data/repositories/wallet_repository_impl.dart';
import 'features/wallet/domain/repositories/wallet_repository.dart';

import 'features/orders/data/datasources/orders_remote_data_source.dart';
import 'features/orders/data/repositories/orders_repository_impl.dart';
import 'features/orders/domain/repositories/orders_repository.dart';

import 'features/deposit/data/datasources/deposit_remote_data_source.dart';
import 'features/deposit/data/repositories/deposit_repository_impl.dart';
import 'features/deposit/domain/repositories/deposit_repository.dart';

import 'features/kyc/data/datasources/kyc_remote_data_source.dart';
import 'features/kyc/data/repositories/kyc_repository_impl.dart';
import 'features/kyc/domain/repositories/kyc_repository.dart';

final sl = GetIt.instance;

Future<void> initDependencies() async {
  await SupabaseConfig.init();
  final client = SupabaseConfig.client;
  sl.registerLazySingleton(() => client);

  // Auth
  sl.registerLazySingleton<AuthRemoteDataSource>(() => AuthRemoteDataSourceImpl(sl()));
  sl.registerLazySingleton<AuthRepository>(() => AuthRepositoryImpl(sl()));
  sl.registerLazySingleton(() => SignInUseCase(sl()));
  sl.registerLazySingleton(() => SignUpUseCase(sl()));
  sl.registerLazySingleton(() => ResetPasswordUseCase(sl()));
  sl.registerLazySingleton(() => SignOutUseCase(sl()));
  sl.registerLazySingleton(() => AuthBloc(
        signInUseCase: sl(),
        signUpUseCase: sl(),
        resetPasswordUseCase: sl(),
        signOutUseCase: sl(),
        repository: sl(),
      ));

  // Market
  sl.registerLazySingleton<MarketRemoteDataSource>(() => MarketRemoteDataSourceImpl(sl()));
  sl.registerLazySingleton<MarketRepository>(() => MarketRepositoryImpl(sl()));

  // Wallet
  sl.registerLazySingleton<WalletRemoteDataSource>(() => WalletRemoteDataSourceImpl(sl()));
  sl.registerLazySingleton<WalletRepository>(() => WalletRepositoryImpl(sl()));

  // Orders
  sl.registerLazySingleton<OrdersRemoteDataSource>(() => OrdersRemoteDataSourceImpl(sl()));
  sl.registerLazySingleton<OrdersRepository>(() => OrdersRepositoryImpl(sl()));

  // Deposit
  sl.registerLazySingleton<DepositRemoteDataSource>(() => DepositRemoteDataSourceImpl(sl()));
  sl.registerLazySingleton<DepositRepository>(() => DepositRepositoryImpl(sl()));

  // KYC
  sl.registerLazySingleton<KycRemoteDataSource>(() => KycRemoteDataSourceImpl(sl()));
  sl.registerLazySingleton<KycRepository>(() => KycRepositoryImpl(sl()));
}
