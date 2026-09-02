import '../../domain/repositories/market_repository.dart';
import '../datasources/market_remote_data_source.dart';

class MarketRepositoryImpl implements MarketRepository {
  final MarketRemoteDataSource remote;
  MarketRepositoryImpl(this.remote);

  @override
  Stream<List<MarketPriceEntity>> watchPrices() => remote.watchPrices();

  @override
  Future<List<CandleEntity>> getCandles({required String coinSymbol, int intervalMinutes = 5, int limit = 60}) =>
      remote.getCandles(coinSymbol: coinSymbol, intervalMinutes: intervalMinutes, limit: limit);
}
