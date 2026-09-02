import 'package:supabase_flutter/supabase_flutter.dart';
import '../../domain/repositories/market_repository.dart';

abstract class MarketRemoteDataSource {
  Stream<List<MarketPriceEntity>> watchPrices();
  Future<List<CandleEntity>> getCandles({required String coinSymbol, int intervalMinutes = 5, int limit = 60});
}

class MarketRemoteDataSourceImpl implements MarketRemoteDataSource {
  final SupabaseClient client;
  MarketRemoteDataSourceImpl(this.client);

  @override
  Stream<List<MarketPriceEntity>> watchPrices() {
    return client.from('market_prices').stream(primaryKey: ['coin_symbol']).map(
          (rows) => rows.map(MarketPriceEntity.fromMap).toList(),
        );
  }

  @override
  Future<List<CandleEntity>> getCandles({required String coinSymbol, int intervalMinutes = 5, int limit = 60}) async {
    final result = await client.rpc('get_candles', params: {
      'p_coin_symbol': coinSymbol,
      'p_interval_minutes': intervalMinutes,
      'p_limit': limit,
    });
    final rows = (result as List).cast<Map<String, dynamic>>();
    return rows.map(CandleEntity.fromMap).toList();
  }
}
