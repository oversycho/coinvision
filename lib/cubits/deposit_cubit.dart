import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../features/deposit/domain/repositories/deposit_repository.dart';

class DepositCubit extends Cubit<List<DepositEntity>> {
  final DepositRepository repository;
  StreamSubscription<List<DepositEntity>>? _sub;
  String? _userId;

  DepositCubit(this.repository) : super(const []);

  void start(String userId) {
    _userId = userId;
    _sub?.cancel();
    _sub = repository.watchDeposits(userId).listen((deposits) => emit(deposits));
  }

  Future<String> getAddress({required String coinSymbol, required String network}) {
    if (_userId == null) throw Exception('user not set');
    return repository.getOrCreateAddress(userId: _userId!, coinSymbol: coinSymbol, network: network);
  }

  Future<void> submit({required String coinSymbol, required String network, required double amount}) {
    if (_userId == null) throw Exception('user not set');
    return repository.submitDeposit(userId: _userId!, coinSymbol: coinSymbol, network: network, amount: amount);
  }

  @override
  Future<void> close() {
    _sub?.cancel();
    return super.close();
  }
}
