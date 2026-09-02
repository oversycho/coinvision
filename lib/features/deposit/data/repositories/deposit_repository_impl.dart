import '../../domain/repositories/deposit_repository.dart';
import '../datasources/deposit_remote_data_source.dart';

class DepositRepositoryImpl implements DepositRepository {
  final DepositRemoteDataSource remote;
  DepositRepositoryImpl(this.remote);

  @override
  Future<String> getOrCreateAddress({required String userId, required String coinSymbol, required String network}) =>
      remote.getOrCreateAddress(userId: userId, coinSymbol: coinSymbol, network: network);

  @override
  Future<void> submitDeposit({required String userId, required String coinSymbol, required String network, required double amount}) =>
      remote.submitDeposit(userId: userId, coinSymbol: coinSymbol, network: network, amount: amount);

  @override
  Stream<List<DepositEntity>> watchDeposits(String userId) => remote.watchDeposits(userId);
}
