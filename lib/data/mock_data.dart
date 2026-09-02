import 'dart:math';

class SeededRand {
  int _s;
  SeededRand(int seed) : _s = seed;
  double next() {
    _s = (_s * 9301 + 49297) % 233280;
    return _s / 233280;
  }
}

List<double> generateSparkline(double base, double vol, int seed, {int points = 30}) {
  final rand = SeededRand(seed);
  final data = [base];
  for (int i = 1; i < points; i++) {
    final change = (rand.next() - 0.48) * vol;
    data.add(max(0, data[i - 1] * (1 + change)));
  }
  return data;
}

class Candle {
  final double open, high, low, close, volume;
  final int index;
  Candle(this.open, this.high, this.low, this.close, this.volume, this.index);
}

List<Candle> generateCandles(double base, double vol, int seed, {int count = 60}) {
  final rand = SeededRand(seed);
  final candles = <Candle>[];
  double price = base * 0.92;
  for (int i = 0; i < count; i++) {
    final open = price;
    final change = (rand.next() - 0.47) * vol;
    final close = open * (1 + change);
    final high = max(open, close) * (1 + rand.next() * vol * 0.4);
    final low = min(open, close) * (1 - rand.next() * vol * 0.4);
    final volume = base * (0.3 + rand.next() * 1.4);
    candles.add(Candle(open, high, low, close, volume, i));
    price = close;
  }
  return candles;
}

List<double> generatePortfolioChart(int seed, {int days = 30}) {
  final rand = SeededRand(seed);
  const base = 42000000000.0;
  final data = [base];
  for (int i = 1; i < days; i++) {
    const trend = 180000000.0;
    final noise = (rand.next() - 0.45) * 2500000000.0;
    data.add(max(base * 0.8, data[i - 1] + trend + noise));
  }
  return data;
}

class Coin {
  final String id;
  final String name;
  final String nameFa;
  double price;
  double change24h;
  String volumeEn;
  String volumeFa;
  double high24h;
  double low24h;
  final List<double> sparkline;
  List<Candle> candles;

  Coin({
    required this.id,
    required this.name,
    required this.nameFa,
    required this.price,
    required this.change24h,
    required this.volumeEn,
    required this.volumeFa,
    required this.high24h,
    required this.low24h,
    required this.sparkline,
    required this.candles,
  });
}

final List<Coin> kCoins = [
  Coin(
    id: 'BTC', name: 'Bitcoin', nameFa: 'بیت‌کوین',
    price: 3780500000, change24h: 2.45,
    volumeEn: '1.24B', volumeFa: '۱.۲۴ میلیارد',
    high24h: 3852000000, low24h: 3680000000,
    sparkline: generateSparkline(3780500000, 0.018, 1),
    candles: generateCandles(3780500000, 0.018, 2),
  ),
  Coin(
    id: 'ETH', name: 'Ethereum', nameFa: 'اتریوم',
    price: 183200000, change24h: -1.23,
    volumeEn: '892M', volumeFa: '۸۹۲ میلیون',
    high24h: 187500000, low24h: 179800000,
    sparkline: generateSparkline(183200000, 0.022, 3),
    candles: generateCandles(183200000, 0.022, 4),
  ),
  Coin(
    id: 'USDT', name: 'Tether', nameFa: 'تتر',
    price: 63500, change24h: 0.02,
    volumeEn: '3.4B', volumeFa: '۳.۴ میلیارد',
    high24h: 63700, low24h: 63300,
    sparkline: generateSparkline(63500, 0.003, 5),
    candles: generateCandles(63500, 0.003, 6),
  ),
  Coin(
    id: 'TRX', name: 'TRON', nameFa: 'ترون',
    price: 7920, change24h: 5.67,
    volumeEn: '241M', volumeFa: '۲۴۱ میلیون',
    high24h: 8150, low24h: 7390,
    sparkline: generateSparkline(7920, 0.028, 7),
    candles: generateCandles(7920, 0.028, 8),
  ),
];

class Holding {
  final String coinId;
  final double balance;
  final double locked;
  final double avgBuyPrice;
  Holding(this.coinId, this.balance, this.locked, this.avgBuyPrice);
}

class Portfolio {
  static const totalToman = 48756400000.0;
  static const change24h = 3.28;
  static final holdings = [
    Holding('BTC', 0.0852, 0.01, 3450000000),
    Holding('ETH', 2.41, 0.5, 170000000),
    Holding('USDT', 12500, 2000, 61000),
    Holding('TRX', 45000, 5000, 7200),
  ];
  static final chart = generatePortfolioChart(42);
}

enum OrderSide { buy, sell }

enum OrderType { market, limit }

enum OrderStatus { open, partiallyFilled, filled, cancelled }

class Order {
  final String id;
  final String coinId;
  final OrderSide side;
  final OrderType type;
  OrderStatus status;
  final double amount;
  final double price;
  final double filled;
  final DateTime timestamp;

  Order({
    required this.id,
    required this.coinId,
    required this.side,
    required this.type,
    required this.status,
    required this.amount,
    required this.price,
    required this.filled,
    required this.timestamp,
  });
}

final List<Order> kOrders = [
  Order(
      id: 'ORD-8821', coinId: 'BTC', side: OrderSide.buy, type: OrderType.limit,
      status: OrderStatus.open, amount: 0.01, price: 3700000000, filled: 0,
      timestamp: DateTime.now().subtract(const Duration(hours: 1))),
  Order(
      id: 'ORD-8820', coinId: 'ETH', side: OrderSide.buy, type: OrderType.limit,
      status: OrderStatus.partiallyFilled, amount: 1.0, price: 178000000, filled: 0.3,
      timestamp: DateTime.now().subtract(const Duration(hours: 2))),
  Order(
      id: 'ORD-8819', coinId: 'ETH', side: OrderSide.sell, type: OrderType.market,
      status: OrderStatus.filled, amount: 0.5, price: 182500000, filled: 0.5,
      timestamp: DateTime.now().subtract(const Duration(days: 1))),
  Order(
      id: 'ORD-8818', coinId: 'USDT', side: OrderSide.buy, type: OrderType.limit,
      status: OrderStatus.partiallyFilled, amount: 5000, price: 63200, filled: 2500,
      timestamp: DateTime.now().subtract(const Duration(days: 2))),
  Order(
      id: 'ORD-8817', coinId: 'TRX', side: OrderSide.buy, type: OrderType.market,
      status: OrderStatus.filled, amount: 10000, price: 7800, filled: 10000,
      timestamp: DateTime.now().subtract(const Duration(days: 3))),
  Order(
      id: 'ORD-8816', coinId: 'BTC', side: OrderSide.sell, type: OrderType.limit,
      status: OrderStatus.cancelled, amount: 0.005, price: 3900000000, filled: 0,
      timestamp: DateTime.now().subtract(const Duration(days: 4))),
];

final Map<String, Map<String, String>> kDepositAddresses = {
  'BTC': {'BTC': '1BvBMSEYstWetqTFn5Au4m4GFg7xJaNVN2'},
  'ETH': {
    'ERC20': '0x742d35Cc6634C0532925a3b844Bc454e4438f44e',
    'BEP20': '0x742d35Cc6634C0532925a3b844Bc454e4438f44e',
  },
  'USDT': {
    'TRC20': 'TQn9Y2khEsLJW1ChVWFMSMeRDow5KcbLSE',
    'ERC20': '0x742d35Cc6634C0532925a3b844Bc454e4438f44e',
    'BEP20': '0xA91ea5E3Fc0c2a3b844Bc454e4438f44eDc4e43f',
  },
  'TRX': {'TRC20': 'TQn9Y2khEsLJW1ChVWFMSMeRDow5KcbLSE'},
};

final Map<String, List<String>> kCoinNetworks = {
  'BTC': ['BTC'],
  'ETH': ['ERC20', 'BEP20'],
  'USDT': ['TRC20', 'ERC20', 'BEP20'],
  'TRX': ['TRC20'],
};

class OrderBookRow {
  final double price;
  final double amount;
  OrderBookRow(this.price, this.amount);
}

class OrderBook {
  final List<OrderBookRow> asks;
  final List<OrderBookRow> bids;
  OrderBook(this.asks, this.bids);
}

OrderBook generateOrderBook(double basePrice, int seed) {
  final rand = SeededRand(seed);
  final asks = List.generate(12, (i) {
    final price = basePrice * (1 + (i + 1) * 0.0008 + rand.next() * 0.0003);
    final amount = 0.001 + rand.next() * 0.05;
    return OrderBookRow(price, amount);
  });
  final bids = List.generate(12, (i) {
    final price = basePrice * (1 - (i + 1) * 0.0008 - rand.next() * 0.0003);
    final amount = 0.001 + rand.next() * 0.05;
    return OrderBookRow(price, amount);
  });
  return OrderBook(asks, bids);
}
