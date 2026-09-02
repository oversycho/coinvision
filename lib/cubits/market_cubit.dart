import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../data/mock_data.dart';
import '../features/market/domain/repositories/market_repository.dart';

/// Real, Supabase-backed market cubit. Coin *identity* metadata (name/nameFa)
/// has no backend table -- so it's seeded from the static list -- but price,
/// change_24h, high/low, volume, and the rolling sparkline are all patched in
/// live from the realtime `market_prices` stream. Candles are fetched on
/// demand (see getCandles) from the real `get_candles` Postgres function.
class MarketCubit extends Cubit<List<Coin>> {
  final MarketRepository repository;
  StreamSubscription<List<MarketPriceEntity>>? _sub;

  MarketCubit(this.repository) : super(List.of(kCoins));

  void start() {
    _sub?.cancel();
    _sub = repository.watchPrices().listen((prices) {
      for (final coin in state) {
        MarketPriceEntity? match;
        for (final p in prices) {
          if (p.coinSymbol == coin.id) {
            match = p;
            break;
          }
        }
        if (match == null) continue;
        coin.price = match.priceToman;
        coin.change24h = match.change24h;
        if (match.high24h != null) coin.high24h = match.high24h!;
        if (match.low24h != null) coin.low24h = match.low24h!;
        if (match.volumeUsd != null) {
          final v = match.volumeUsd!;
          final compact = v >= 1e9 ? '${(v / 1e9).toStringAsFixed(2)}B' : '${(v / 1e6).toStringAsFixed(0)}M';
          coin.volumeEn = compact;
          coin.volumeFa = compact;
        }
        coin.sparkline
          ..removeAt(0)
          ..add(match.priceToman);
      }
      emit(List.of(state));
    });
  }

  /// Fetches real OHLC candles from `get_candles` and patches them onto the
  /// matching coin so CandlestickChart renders real history.
  Future<void> loadCandles(String coinId, {int intervalMinutes = 5, int limit = 60}) async {
    try {
      final candles = await repository.getCandles(coinSymbol: coinId, intervalMinutes: intervalMinutes, limit: limit);
      if (candles.isEmpty) return;
      for (final coin in state) {
        if (coin.id != coinId) continue;
        coin.candles = List.generate(
          candles.length,
          (i) => Candle(candles[i].open, candles[i].high, candles[i].low, candles[i].close, candles[i].volume, i),
        );
      }
      emit(List.of(state));
    } catch (_) {
      // price_history may not have enough ticks yet (fresh deployment) --
      // the deterministic mock candles already seeded in `state` stay as a
      // reasonable placeholder until enough real ticks accumulate.
    }
  }

  @override
  Future<void> close() {
    _sub?.cancel();
    return super.close();
  }
}
