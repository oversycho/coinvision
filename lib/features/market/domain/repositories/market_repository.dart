class MarketPriceEntity {
  final String coinSymbol;
  final double priceToman;
  final double priceUsdt;
  final double change24h;
  final double? high24h;
  final double? low24h;
  final double? volumeUsd;
  final DateTime updatedAt;

  const MarketPriceEntity({
    required this.coinSymbol,
    required this.priceToman,
    required this.priceUsdt,
    required this.change24h,
    this.high24h,
    this.low24h,
    this.volumeUsd,
    required this.updatedAt,
  });

  factory MarketPriceEntity.fromMap(Map<String, dynamic> map) => MarketPriceEntity(
        coinSymbol: map['coin_symbol'] as String,
        priceToman: (map['price_toman'] as num?)?.toDouble() ?? 0,
        priceUsdt: (map['price_usdt'] as num?)?.toDouble() ?? 0,
        change24h: (map['change_24h'] as num?)?.toDouble() ?? 0,
        high24h: (map['high_24h'] as num?)?.toDouble(),
        low24h: (map['low_24h'] as num?)?.toDouble(),
        volumeUsd: (map['volume_usd'] as num?)?.toDouble(),
        updatedAt: DateTime.tryParse(map['updated_at'] as String? ?? '') ?? DateTime.now(),
      );
}

class CandleEntity {
  final DateTime bucketStart;
  final double open;
  final double high;
  final double low;
  final double close;
  final double volume;

  const CandleEntity({
    required this.bucketStart,
    required this.open,
    required this.high,
    required this.low,
    required this.close,
    required this.volume,
  });

  factory CandleEntity.fromMap(Map<String, dynamic> map) => CandleEntity(
        bucketStart: DateTime.tryParse(map['bucket_start'] as String? ?? '') ?? DateTime.now(),
        open: (map['open'] as num?)?.toDouble() ?? 0,
        high: (map['high'] as num?)?.toDouble() ?? 0,
        low: (map['low'] as num?)?.toDouble() ?? 0,
        close: (map['close'] as num?)?.toDouble() ?? 0,
        volume: (map['volume'] as num?)?.toDouble() ?? 0,
      );
}

abstract class MarketRepository {
  /// Realtime stream of every row in market_prices — updates automatically
  /// whenever the sync-prices Edge Function (cron, every 30s) writes new data.
  Stream<List<MarketPriceEntity>> watchPrices();

  /// Calls the `get_candles` Postgres function — real OHLC candles bucketed
  /// from the `price_history` raw-tick table.
  Future<List<CandleEntity>> getCandles({
    required String coinSymbol,
    int intervalMinutes = 5,
    int limit = 60,
  });
}
