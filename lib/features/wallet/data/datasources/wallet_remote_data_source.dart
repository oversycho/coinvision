import 'package:supabase_flutter/supabase_flutter.dart';
import '../../domain/repositories/wallet_repository.dart';

abstract class WalletRemoteDataSource {
  Stream<List<WalletEntity>> watchWallets(String userId);
  Future<List<PortfolioSnapshotEntity>> getSnapshots(String userId, {int limitDays = 30});
}

class WalletRemoteDataSourceImpl implements WalletRemoteDataSource {
  final SupabaseClient client;
  WalletRemoteDataSourceImpl(this.client);

  @override
  Stream<List<WalletEntity>> watchWallets(String userId) {
    return client
        .from('wallets')
        .stream(primaryKey: ['id'])
        .eq('user_id', userId)
        .map((rows) => rows.map(WalletEntity.fromMap).toList());
  }

  @override
  Future<List<PortfolioSnapshotEntity>> getSnapshots(String userId, {int limitDays = 30}) async {
    final since = DateTime.now().subtract(Duration(days: limitDays)).toIso8601String();
    final rows = await client
        .from('portfolio_snapshots')
        .select()
        .eq('user_id', userId)
        .gte('recorded_at', since)
        .order('recorded_at', ascending: true);
    return (rows as List).cast<Map<String, dynamic>>().map(PortfolioSnapshotEntity.fromMap).toList();
  }
}
