import '../../domain/repositories/wallet_repository.dart';
import '../datasources/wallet_remote_data_source.dart';

class WalletRepositoryImpl implements WalletRepository {
  final WalletRemoteDataSource remote;
  WalletRepositoryImpl(this.remote);

  @override
  Stream<List<WalletEntity>> watchWallets(String userId) => remote.watchWallets(userId);

  @override
  Future<List<PortfolioSnapshotEntity>> getSnapshots(String userId, {int limitDays = 30}) =>
      remote.getSnapshots(userId, limitDays: limitDays);
}
