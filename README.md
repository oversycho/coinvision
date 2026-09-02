# CoinVision — Flutter (کامل، وصل به Supabase واقعی)

پیاده‌سازی دقیق طراحی Figma با Flutter + BLoC، به‌طور کامل به بک‌اند واقعی Supabase وصل شده — بدون داده Mock در مسیر اصلی (auth، قیمت، کیف پول، سفارش، دیپازیت).

## قبل از اجرا — این یکی اجباریه

فایل `lib/core/supabase/supabase_config.dart` را باز کن و مقدار `anonKey` را با کلید **anon/public** پروژه‌ات (نه service_role!) از Supabase Dashboard → Project Settings → API جایگزین کن:

```dart
static const String anonKey = 'PASTE_YOUR_ANON_PUBLIC_KEY_HERE';
```

`projectUrl` از قبل با آدرس پروژه‌ی CoinVision پر شده.

### تکمیل بک‌اند (برای چارت واقعی، حجم/High-Low واقعی، پرتفولیو و سود/زیان)

دو فایل کنار این zip بهت دادم که باید یک‌بار اجرا/دیپلوی کنی:

1. **`coinvision_completion_migration.sql`** — کامل تو SQL Editor پروژه‌ی Supabase اجرا کن. جدول `price_history`، تابع `get_candles`، ستون `avg_buy_price` روی `wallets`، جدول `portfolio_snapshots` و Cron مربوطه رو می‌سازه.
2. **`sync-prices-updated.ts`** — محتوای Edge Function `sync-prices` رو با این جایگزین کن و Deploy بزن (از CoinGecko حجم/High-Low واقعی می‌گیره و هر تیک رو تو `price_history` ثبت می‌کنه).

بدون این دو تا، اپ همچنان کار می‌کنه ولی چارت کندل‌استیک و نمودار عملکرد پرتفولیو به‌جای داده واقعی، مقدار placeholder نشون می‌دن.

## اجرا

```bash
flutter pub get
flutter run
```

## ساختار

```
lib/
├── core/                  رنگ، فونت، ترجمه، Supabase client، کامپوننت‌های مشترک
├── cubits/                 ThemeCubit, LocaleCubit, NavigationCubit,
│                            MarketCubit, WalletCubit, OrdersCubit, DepositCubit
│                            (همه به‌جز Theme/Locale/Navigation واقعاً به Supabase وصل‌ن)
├── features/
│   ├── auth/               domain/data/presentation کامل — AuthBloc واقعی
│   ├── market/              Repository برای جدول market_prices (Realtime)
│   ├── wallet/               Repository برای جدول wallets (Realtime)
│   ├── orders/                Repository + RPC برای place_order / cancel_order
│   └── deposit/                Repository + RPC برای get_or_create_deposit_address
├── data/mock_data.dart      فقط متادیتای ثابت کوین‌ها (اسم، آیکون) + تولیدکننده نمودار نمایشی
├── screens/                 ۸ صفحه، همه به داده واقعی وصل
├── injection_container.dart  همه‌چیز با get_it به هم وصل می‌شه
└── app.dart / main.dart
```

## چطور هر صفحه به بک‌اند وصله

| صفحه | منبع داده |
|---|---|
| Auth | `AuthBloc` ← Supabase Auth (signUp/signInWithPassword/resetPasswordForEmail) |
| Home/Market | `MarketCubit` ← Realtime stream روی `market_prices` |
| Coin Detail / فرم سفارش | ثبت سفارش با `OrdersCubit.place()` → تابع `place_order` (قفل موجودی + Matching Engine خودکار)؛ چارت کندل با `MarketCubit.loadCandles()` → `get_candles` |
| Portfolio | `WalletCubit` ← Realtime stream روی `wallets` (فیلتر شده با user_id) |
| Deposit | `DepositCubit` ← RPC `get_or_create_deposit_address` + insert روی `deposits`، وضعیت از Realtime |
| Order History | `OrdersCubit` ← Realtime stream روی `orders`؛ لغو با `cancel_order` |
| Settings | `AuthBloc` برای نام/ایمیل کاربر و خروج |

## محدودیت‌های شناخته‌شده (بعد از اجرای Migration، همه این‌ها واقعی می‌شن)

اگه فایل SQL و Edge Function بالا رو اجرا/دیپلوی کنی، این‌ها دیگه محدودیت نیستن:

1. ✅ **چارت کندل‌استیک** واقعی می‌شه (از `get_candles` روی `price_history`)
2. ✅ **حجم معاملات و High/Low ۲۴ ساعته** واقعی می‌شه (از CoinGecko `/coins/markets`)
3. ✅ **نمودار عملکرد پرتفولیو** واقعی می‌شه (از `portfolio_snapshots`، هر ۱۵ دقیقه)
4. ✅ **سود/زیان (P&L)** واقعی می‌شه (میانگین قیمت خرید در `wallets.avg_buy_price`، به‌روزرسانی خودکار در `match_order`)

تنها چیزی که باقی می‌مونه: بلافاصله بعد از دیپلوی، تا چند دقیقه/ساعت اول (تا price_history و portfolio_snapshots داده کافی جمع کنن) این نمودارها ممکنه خالی یا کم‌داده باشن — طبیعیه، چون تازه شروع به جمع‌آوری تاریخچه کردن.

## پکیج‌های کلیدی
`flutter_bloc`, `get_it`, `dartz`, `supabase_flutter`, `postgrest`, `qr_flutter`, `google_fonts`
