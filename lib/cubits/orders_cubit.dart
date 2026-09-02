import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../features/orders/domain/repositories/orders_repository.dart';

class OrdersCubit extends Cubit<List<OrderEntity>> {
  final OrdersRepository repository;
  StreamSubscription<List<OrderEntity>>? _sub;
  String? _userId;

  OrdersCubit(this.repository) : super(const []);

  void start(String userId) {
    _userId = userId;
    _sub?.cancel();
    _sub = repository.watchOrders(userId).listen((orders) => emit(orders));
  }

  Future<void> place({
    required String coinSymbol,
    required OrderSideEntity side,
    required OrderTypeEntity type,
    double? price,
    required double amount,
  }) async {
    if (_userId == null) throw Exception('user not set');
    await repository.placeOrder(
      userId: _userId!,
      coinSymbol: coinSymbol,
      side: side,
      type: type,
      price: price,
      amount: amount,
    );
  }

  Future<void> cancel(String orderId) async {
    if (_userId == null) throw Exception('user not set');
    await repository.cancelOrder(orderId: orderId, userId: _userId!);
  }

  @override
  Future<void> close() {
    _sub?.cancel();
    return super.close();
  }
}
