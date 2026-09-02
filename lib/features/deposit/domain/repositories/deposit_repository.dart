enum DepositStatusEntity { pending, confirming, completed }

class DepositEntity {
  final String id;
  final String coinSymbol;
  final String network;
  final double amount;
  final DepositStatusEntity status;
  final int confirmations;
  final int requiredConfirmations;
  final DateTime createdAt;

  const DepositEntity({
    required this.id,
    required this.coinSymbol,
    required this.network,
    required this.amount,
    required this.status,
    required this.confirmations,
    required this.requiredConfirmations,
    required this.createdAt,
  });

  factory DepositEntity.fromMap(Map<String, dynamic> map) => DepositEntity(
        id: map['id'] as String,
        coinSymbol: map['coin_symbol'] as String,
        network: map['network'] as String,
        amount: (map['amount'] as num?)?.toDouble() ?? 0,
        status: switch (map['status'] as String) {
          'pending' => DepositStatusEntity.pending,
          'confirming' => DepositStatusEntity.confirming,
          _ => DepositStatusEntity.completed,
        },
        confirmations: map['confirmations'] as int? ?? 0,
        requiredConfirmations: map['required_confirmations'] as int? ?? 3,
        createdAt: DateTime.tryParse(map['created_at'] as String? ?? '') ?? DateTime.now(),
      );
}

abstract class DepositRepository {
  /// Calls `get_or_create_deposit_address` — returns a fake but stable
  /// address for this user/coin/network combination.
  Future<String> getOrCreateAddress({required String userId, required String coinSymbol, required String network});

  /// Inserts a row into `deposits`; the process-deposits cron function
  /// then advances it through pending → confirming → completed automatically.
  Future<void> submitDeposit({
    required String userId,
    required String coinSymbol,
    required String network,
    required double amount,
  });

  Stream<List<DepositEntity>> watchDeposits(String userId);
}
