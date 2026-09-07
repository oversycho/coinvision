import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../features/wallet/domain/repositories/wallet_repository.dart';

class RealizedPnlCubit extends Cubit<List<RealizedPnlEntity>> {
  final WalletRepository repository;
  StreamSubscription<List<RealizedPnlEntity>>? _sub;

  RealizedPnlCubit(this.repository) : super(const []);

  void start(String userId) {
    _sub?.cancel();
    _sub = repository.watchRealizedPnl(userId).listen((entries) => emit(entries), onError: (e) {
      // ignore: avoid_print
      print('RealizedPnlCubit stream error: $e');
    });
  }

  double get total => state.fold(0.0, (sum, e) => sum + e.pnl);

  @override
  Future<void> close() {
    _sub?.cancel();
    return super.close();
  }
}
