class WalletEntity {
  final String coinSymbol;
  final double balance;
  final double lockedBalance;
  final double? avgBuyPrice;

  const WalletEntity({
    required this.coinSymbol,
    required this.balance,
    required this.lockedBalance,
    this.avgBuyPrice,
  });

  factory WalletEntity.fromMap(Map<String, dynamic> map) => WalletEntity(
        coinSymbol: map['coin_symbol'] as String,
        balance: (map['balance'] as num?)?.toDouble() ?? 0,
        lockedBalance: (map['locked_balance'] as num?)?.toDouble() ?? 0,
        avgBuyPrice: (map['avg_buy_price'] as num?)?.toDouble(),
      );
}

class PortfolioSnapshotEntity {
  final double totalToman;
  final DateTime recordedAt;
  const PortfolioSnapshotEntity({required this.totalToman, required this.recordedAt});

  factory PortfolioSnapshotEntity.fromMap(Map<String, dynamic> map) => PortfolioSnapshotEntity(
        totalToman: (map['total_toman'] as num?)?.toDouble() ?? 0,
        recordedAt: DateTime.tryParse(map['recorded_at'] as String? ?? '') ?? DateTime.now(),
      );
}

abstract class WalletRepository {
  /// Realtime stream of the current user's wallets — updates automatically
  /// after deposits complete or trades settle.
  Stream<List<WalletEntity>> watchWallets(String userId);

  /// Historical total-portfolio-value snapshots (written every 15 min by
  /// the `snapshot_portfolios` cron function) — powers the real performance chart.
  Future<List<PortfolioSnapshotEntity>> getSnapshots(String userId, {int limitDays = 30});
}
