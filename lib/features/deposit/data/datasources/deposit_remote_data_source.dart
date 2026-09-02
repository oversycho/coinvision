import 'package:supabase_flutter/supabase_flutter.dart';
import '../../domain/repositories/deposit_repository.dart';

abstract class DepositRemoteDataSource {
  Future<String> getOrCreateAddress({required String userId, required String coinSymbol, required String network});
  Future<void> submitDeposit({required String userId, required String coinSymbol, required String network, required double amount});
  Stream<List<DepositEntity>> watchDeposits(String userId);
}

class DepositRemoteDataSourceImpl implements DepositRemoteDataSource {
  final SupabaseClient client;
  DepositRemoteDataSourceImpl(this.client);

  @override
  Future<String> getOrCreateAddress({required String userId, required String coinSymbol, required String network}) async {
    final result = await client.rpc('get_or_create_deposit_address', params: {
      'p_user_id': userId,
      'p_coin_symbol': coinSymbol,
      'p_network': network,
    });
    return result as String;
  }

  @override
  Future<void> submitDeposit({required String userId, required String coinSymbol, required String network, required double amount}) async {
    await client.from('deposits').insert({
      'user_id': userId,
      'coin_symbol': coinSymbol,
      'network': network,
      'amount': amount,
    });
  }

  @override
  Stream<List<DepositEntity>> watchDeposits(String userId) {
    return client
        .from('deposits')
        .stream(primaryKey: ['id'])
        .eq('user_id', userId)
        .order('created_at')
        .map((rows) => rows.map(DepositEntity.fromMap).toList().reversed.toList());
  }
}
