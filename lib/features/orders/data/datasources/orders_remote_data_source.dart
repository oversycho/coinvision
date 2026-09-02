import 'package:supabase_flutter/supabase_flutter.dart';
import '../../domain/repositories/orders_repository.dart';

abstract class OrdersRemoteDataSource {
  Stream<List<OrderEntity>> watchOrders(String userId);
  Future<String> placeOrder({
    required String userId,
    required String coinSymbol,
    required OrderSideEntity side,
    required OrderTypeEntity type,
    double? price,
    required double amount,
  });
  Future<void> cancelOrder({required String orderId, required String userId});
}

class OrdersRemoteDataSourceImpl implements OrdersRemoteDataSource {
  final SupabaseClient client;
  OrdersRemoteDataSourceImpl(this.client);

  @override
  Stream<List<OrderEntity>> watchOrders(String userId) {
    return client
        .from('orders')
        .stream(primaryKey: ['id'])
        .eq('user_id', userId)
        .order('created_at')
        .map((rows) => rows.map(OrderEntity.fromMap).toList().reversed.toList());
  }

  @override
  Future<String> placeOrder({
    required String userId,
    required String coinSymbol,
    required OrderSideEntity side,
    required OrderTypeEntity type,
    double? price,
    required double amount,
  }) async {
    final result = await client.rpc('place_order', params: {
      'p_user_id': userId,
      'p_coin_symbol': coinSymbol,
      'p_side': side == OrderSideEntity.buy ? 'buy' : 'sell',
      'p_order_type': type == OrderTypeEntity.market ? 'market' : 'limit',
      'p_price': price,
      'p_amount': amount,
    });
    return result as String;
  }

  @override
  Future<void> cancelOrder({required String orderId, required String userId}) async {
    await client.rpc('cancel_order', params: {'p_order_id': orderId, 'p_user_id': userId});
  }
}
