enum OrderSideEntity { buy, sell }

enum OrderTypeEntity { market, limit }

enum OrderStatusEntity { open, partiallyFilled, filled, cancelled }

class OrderEntity {
  final String id;
  final String coinSymbol;
  final OrderSideEntity side;
  final OrderTypeEntity type;
  final OrderStatusEntity status;
  final double amount;
  final double? price;
  final double filledAmount;
  final DateTime createdAt;

  const OrderEntity({
    required this.id,
    required this.coinSymbol,
    required this.side,
    required this.type,
    required this.status,
    required this.amount,
    required this.price,
    required this.filledAmount,
    required this.createdAt,
  });

  factory OrderEntity.fromMap(Map<String, dynamic> map) => OrderEntity(
        id: map['id'] as String,
        coinSymbol: map['coin_symbol'] as String,
        side: (map['side'] as String) == 'buy' ? OrderSideEntity.buy : OrderSideEntity.sell,
        type: (map['order_type'] as String) == 'market' ? OrderTypeEntity.market : OrderTypeEntity.limit,
        status: switch (map['status'] as String) {
          'open' => OrderStatusEntity.open,
          'partially_filled' => OrderStatusEntity.partiallyFilled,
          'filled' => OrderStatusEntity.filled,
          _ => OrderStatusEntity.cancelled,
        },
        amount: (map['amount'] as num?)?.toDouble() ?? 0,
        price: (map['price'] as num?)?.toDouble(),
        filledAmount: (map['filled_amount'] as num?)?.toDouble() ?? 0,
        createdAt: DateTime.tryParse(map['created_at'] as String? ?? '') ?? DateTime.now(),
      );
}

abstract class OrdersRepository {
  Stream<List<OrderEntity>> watchOrders(String userId);

  /// Calls the `place_order` Postgres function (handles balance locking +
  /// triggers the matching engine automatically).
  Future<String> placeOrder({
    required String userId,
    required String coinSymbol,
    required OrderSideEntity side,
    required OrderTypeEntity type,
    double? price,
    required double amount,
  });

  /// Calls the `cancel_order` Postgres function (refunds locked balance).
  Future<void> cancelOrder({required String orderId, required String userId});
}
