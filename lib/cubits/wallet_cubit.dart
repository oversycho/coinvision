import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../features/wallet/domain/repositories/wallet_repository.dart';

class WalletCubit extends Cubit<List<WalletEntity>> {
  final WalletRepository repository;
  StreamSubscription<List<WalletEntity>>? _sub;
  String? _userId;

  WalletCubit(this.repository) : super(const []);

  void start(String userId) {
    _userId = userId;
    _sub?.cancel();
    _sub = repository.watchWallets(userId).listen((
      wallets,
    ) => emit(wallets), onError: (e) {
      // Realtime hiccup (e.g. RealtimeSubscribeException on first connect) --
      // log and keep the last known state instead of crashing the app.
      // ignore: avoid_print
      print('stream error in lib/cubits/wallet_cubit.dart: $e');
    });
  }

  /// Real historical portfolio value, from the `portfolio_snapshots` table
  /// (written every 15 min by the `snapshot_portfolios` cron function).
  Future<List<PortfolioSnapshotEntity>> loadSnapshots({int limitDays = 30}) {
    if (_userId == null) return Future.value(const []);
    return repository.getSnapshots(_userId!, limitDays: limitDays);
  }

  @override
  Future<void> close() {
    _sub?.cancel();
    return super.close();
  }
}
