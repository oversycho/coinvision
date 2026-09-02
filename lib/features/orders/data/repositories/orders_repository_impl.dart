import 'package:postgrest/postgrest.dart';
import '../../domain/repositories/orders_repository.dart';
import '../datasources/orders_remote_data_source.dart';

class OrdersRepositoryImpl implements OrdersRepository {
  final OrdersRemoteDataSource remote;
  OrdersRepositoryImpl(this.remote);

  @override
  Stream<List<OrderEntity>> watchOrders(String userId) => remote.watchOrders(userId);

  @override
  Future<String> placeOrder({
    required String userId,
    required String coinSymbol,
    required OrderSideEntity side,
    required OrderTypeEntity type,
    double? price,
    required double amount,
  }) async {
    try {
      return await remote.placeOrder(
        userId: userId,
        coinSymbol: coinSymbol,
        side: side,
        type: type,
        price: price,
        amount: amount,
      );
    } on PostgrestException catch (e) {
      // place_order raises a plain Postgres exception (e.g. "موجودی کافی نیست")
      throw Exception(e.message);
    }
  }

  @override
  Future<void> cancelOrder({required String orderId, required String userId}) async {
    try {
      await remote.cancelOrder(orderId: orderId, userId: userId);
    } on PostgrestException catch (e) {
      throw Exception(e.message);
    }
  }
}
