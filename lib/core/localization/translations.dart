import 'dart:math';
import '../../cubits/locale_cubit.dart';

class Tr {
  static const Map<String, Map<String, String>> _t = {
    'appName': {'en': 'COINVISION', 'fa': 'کوین ویژن'},
    'appTagline': {'en': 'Paper Trading Exchange', 'fa': 'صرافی شبیه‌سازی‌شده'},
    'login': {'en': 'Sign In', 'fa': 'ورود'},
    'signup': {'en': 'Sign Up', 'fa': 'ثبت‌نام'},
    'forgotPw': {'en': 'Forgot Password', 'fa': 'فراموشی رمز'},
    'email': {'en': 'Email address', 'fa': 'آدرس ایمیل'},
    'password': {'en': 'Password', 'fa': 'رمز عبور'},
    'confirmPw': {'en': 'Confirm Password', 'fa': 'تکرار رمز'},
    'fullName': {'en': 'Full Name', 'fa': 'نام کامل'},
    'signInBtn': {'en': 'Sign In', 'fa': 'ورود به حساب'},
    'signUpBtn': {'en': 'Create Account', 'fa': 'ایجاد حساب'},
    'sendReset': {'en': 'Send Reset Link', 'fa': 'ارسال لینک بازیابی'},
    'demoNote': {'en': 'Demo: any email + password works', 'fa': 'دمو: هر ایمیل و رمزی کار می‌کند'},
    'market': {'en': 'Markets', 'fa': 'بازار'},
    'portfolio': {'en': 'Portfolio', 'fa': 'پرتفولیو'},
    'orders': {'en': 'Orders', 'fa': 'سفارشات'},
    'settings': {'en': 'Settings', 'fa': 'تنظیمات'},
    'deposit': {'en': 'Deposit', 'fa': 'واریز'},
    'search': {'en': 'Search coins…', 'fa': 'جستجوی ارز…'},
    'topGainers': {'en': 'Top Gainers', 'fa': 'بیشترین رشد'},
    'volume': {'en': 'Volume', 'fa': 'حجم'},
    'change': {'en': 'Change', 'fa': 'تغییر'},
    'buy': {'en': 'Buy', 'fa': 'خرید'},
    'sell': {'en': 'Sell', 'fa': 'فروش'},
    'orderBook': {'en': 'Order Book', 'fa': 'دفتر سفارشات'},
    'market_order': {'en': 'Market', 'fa': 'بازار'},
    'limit_order': {'en': 'Limit', 'fa': 'محدود'},
    'amount': {'en': 'Amount', 'fa': 'مقدار'},
    'price': {'en': 'Price', 'fa': 'قیمت'},
    'total': {'en': 'Total', 'fa': 'مجموع'},
    'available': {'en': 'Available', 'fa': 'موجودی'},
    'placeOrder': {'en': 'Place Order', 'fa': 'ثبت سفارش'},
    'high24h': {'en': '24h High', 'fa': 'بیشترین ۲۴ ساعت'},
    'low24h': {'en': '24h Low', 'fa': 'کمترین ۲۴ ساعت'},
    'asks': {'en': 'Asks', 'fa': 'فروش'},
    'bids': {'en': 'Bids', 'fa': 'خرید'},
    'price_col': {'en': 'Price (T)', 'fa': 'قیمت (ت)'},
    'totalBalance': {'en': 'Total Balance', 'fa': 'موجودی کل'},
    'toman': {'en': 'Toman', 'fa': 'تومان'},
    'performance': {'en': 'Performance', 'fa': 'عملکرد'},
    'holdings': {'en': 'Holdings', 'fa': 'دارایی‌ها'},
    'selectCoin': {'en': 'Select Coin', 'fa': 'انتخاب ارز'},
    'selectNetwork': {'en': 'Select Network', 'fa': 'انتخاب شبکه'},
    'depositAddr': {'en': 'Deposit Address', 'fa': 'آدرس واریز'},
    'copyAddr': {'en': 'Copy Address', 'fa': 'کپی آدرس'},
    'copied': {'en': 'Copied!', 'fa': 'کپی شد!'},
    'pending': {'en': 'Pending', 'fa': 'در انتظار'},
    'confirming': {'en': 'Confirming', 'fa': 'در حال تأیید'},
    'completed': {'en': 'Completed', 'fa': 'تکمیل‌شده'},
    'depositNote': {
      'en': 'Only send to this address on selected network. Sending on the wrong network will result in permanent loss.',
      'fa': 'فقط از شبکه انتخاب‌شده واریز کنید. ارسال از شبکه اشتباه منجر به از دست دادن دائمی دارایی می‌شود.'
    },
    'openOrders': {'en': 'Open', 'fa': 'باز'},
    'orderHistory': {'en': 'History', 'fa': 'تاریخچه'},
    'tradeHistory': {'en': 'Trades', 'fa': 'معاملات'},
    'cancelOrder': {'en': 'Cancel', 'fa': 'لغو'},
    'status_open': {'en': 'Open', 'fa': 'باز'},
    'status_partially_filled': {'en': 'Partial', 'fa': 'جزئی'},
    'status_filled': {'en': 'Filled', 'fa': 'انجام‌شده'},
    'status_cancelled': {'en': 'Cancelled', 'fa': 'لغو‌شده'},
    'filled_label': {'en': 'Filled', 'fa': 'انجام‌شده'},
    'type_market': {'en': 'Market', 'fa': 'بازار'},
    'type_limit': {'en': 'Limit', 'fa': 'محدود'},
    'account': {'en': 'Account', 'fa': 'حساب کاربری'},
    'security': {'en': 'Security', 'fa': 'امنیت'},
    'notifications': {'en': 'Notifications', 'fa': 'اعلان‌ها'},
    'appearance': {'en': 'Appearance', 'fa': 'ظاهر'},
    'darkMode': {'en': 'Dark Mode', 'fa': 'حالت تاریک'},
    'language': {'en': 'Language', 'fa': 'زبان'},
    'logout': {'en': 'Sign Out', 'fa': 'خروج از حساب'},
    'version': {'en': 'Version 1.0.0 (Demo)', 'fa': 'نسخه ۱.۰.۰ (دمو)'},
    'changePassword': {'en': 'Change Password', 'fa': 'تغییر رمز'},
    'twoFactor': {'en': 'Two-Factor Auth', 'fa': 'احراز هویت دو مرحله‌ای'},
    'kyc': {'en': 'Verify Identity (KYC)', 'fa': 'احراز هویت (KYC)'},
    'notifTrades': {'en': 'Trade Alerts', 'fa': 'هشدار معاملات'},
    'notifPrices': {'en': 'Price Alerts', 'fa': 'هشدار قیمت'},
    'notifNews': {'en': 'News & Updates', 'fa': 'اخبار و به‌روزرسانی‌ها'},
    'about': {'en': 'About CoinVision', 'fa': 'درباره کوین ویژن'},
    'support': {'en': 'Support', 'fa': 'پشتیبانی'},
  };

  static String t(String key, AppLang lang) {
    final entry = _t[key];
    if (entry == null) return key;
    return entry[lang == AppLang.fa ? 'fa' : 'en'] ?? entry['en'] ?? key;
  }

  static const _persianDigits = ['۰', '۱', '۲', '۳', '۴', '۵', '۶', '۷', '۸', '۹'];

  static String toPersianNum(String s) {
    final buffer = StringBuffer();
    for (final ch in s.split('')) {
      final d = int.tryParse(ch);
      buffer.write(d != null ? _persianDigits[d] : ch);
    }
    return buffer.toString();
  }

  static String _thousands(String intPart) {
    final buf = StringBuffer();
    for (int i = 0; i < intPart.length; i++) {
      if (i != 0 && (intPart.length - i) % 3 == 0) buf.write(',');
      buf.write(intPart[i]);
    }
    return buf.toString();
  }

  static String formatPrice(double n, AppLang lang, {bool compact = true}) {
    if (compact) {
      if (n >= 1e12) return _suffixed(n / 1e12, lang, en: 'T', fa: ' هزار میلیارد');
      if (n >= 1e9) return _suffixed(n / 1e9, lang, en: 'B', fa: ' میلیارد');
      if (n >= 1e6) return _suffixed(n / 1e6, lang, en: 'M', fa: ' میلیون');
      if (n >= 1e3) return _suffixed(n / 1e3, lang, en: 'K', fa: ' هزار', decimals: 1);
    }
    final decimals = n < 100 ? 2 : 0;
    final fixed = n.toStringAsFixed(decimals);
    final parts = fixed.split('.');
    final withCommas = _thousands(parts[0]) + (parts.length > 1 ? '.${parts[1]}' : '');
    return lang == AppLang.fa ? toPersianNum(withCommas) : withCommas;
  }

  static String _suffixed(double v, AppLang lang, {required String en, required String fa, int decimals = 2}) {
    final s = v.toStringAsFixed(decimals);
    return lang == AppLang.fa ? '${toPersianNum(s)}$fa' : '$s$en';
  }

  static String formatChange(double n, AppLang lang) {
    final abs = n.abs().toStringAsFixed(2);
    final sign = n >= 0 ? '+' : '−';
    return lang == AppLang.fa ? '$sign${toPersianNum(abs)}٪' : '$sign$abs%';
  }

  static String formatTime(DateTime d, AppLang lang) {
    final h = d.hour.toString().padLeft(2, '0');
    final m = d.minute.toString().padLeft(2, '0');
    return lang == AppLang.fa ? '${toPersianNum(h)}:${toPersianNum(m)}' : '$h:$m';
  }
}

extension RandSeeded on Random {
  static Random seeded(int seed) => Random(seed);
}
