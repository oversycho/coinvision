-- ============================================================
-- CoinVision — Completion Migration
-- Run this entire block in Supabase SQL Editor (top to bottom).
-- ============================================================

-- 1) Real volume / 24h high-low on market_prices
alter table market_prices
  add column if not exists volume_usd numeric(24,2),
  add column if not exists high_24h numeric(24,8),
  add column if not exists low_24h numeric(24,8);

-- 2) Price history — raw ticks written by sync-prices every 30s.
create table if not exists price_history (
  id uuid primary key default gen_random_uuid(),
  coin_symbol text references coins(symbol) not null,
  price_toman numeric(24,2) not null,
  price_usdt numeric(24,8) not null,
  recorded_at timestamptz not null default now()
);
create index if not exists idx_price_history_coin_time on price_history (coin_symbol, recorded_at desc);

alter table price_history enable row level security;
create policy "anyone reads price history" on price_history for select using (true);

-- 3) Candle aggregation function — buckets price_history into OHLC.
-- p_interval_minutes: bucket size (e.g. 5, 60, 1440); p_limit: how many buckets back.
create or replace function get_candles(
  p_coin_symbol text,
  p_interval_minutes int default 5,
  p_limit int default 60
)
returns table (
  bucket_start timestamptz,
  open numeric,
  high numeric,
  low numeric,
  close numeric,
  volume numeric
) as $$
  with bucketed as (
    select
      to_timestamp(floor(extract(epoch from recorded_at) / (p_interval_minutes * 60)) * (p_interval_minutes * 60)) as bucket_start,
      price_toman,
      recorded_at
    from price_history
    where coin_symbol = p_coin_symbol
      and recorded_at > now() - (p_interval_minutes * p_limit || ' minutes')::interval
  )
  select
    bucket_start,
    (array_agg(price_toman order by recorded_at asc))[1] as open,
    max(price_toman) as high,
    min(price_toman) as low,
    (array_agg(price_toman order by recorded_at desc))[1] as close,
    count(*)::numeric as volume
  from bucketed
  group by bucket_start
  order by bucket_start asc
  limit p_limit;
$$ language sql stable;

-- 4) avg_buy_price on wallets, for portfolio P&L.
alter table wallets add column if not exists avg_buy_price numeric(24,8);

-- Update match_order to maintain a running weighted-average cost basis
-- on the buyer's wallet each time a trade settles.
create or replace function match_order(p_order_id uuid)
returns void as $$
declare
  o orders%rowtype;
  match_o orders%rowtype;
  v_trade_amount numeric;
  v_trade_price numeric;
  v_fee_rate numeric := 0.002;
  v_fee numeric;
  v_buy_order_id uuid;
  v_sell_order_id uuid;
  v_buyer_id uuid;
  v_old_balance numeric;
  v_old_avg numeric;
  v_net_received numeric;
begin
  select * into o from orders where id = p_order_id and status in ('open','partially_filled');
  if not found then return; end if;

  loop
    exit when o.filled_amount >= o.amount;

    if o.side = 'buy' then
      select * into match_o from orders
      where coin_symbol = o.coin_symbol and side = 'sell'
        and status in ('open','partially_filled') and id != o.id
        and (o.order_type = 'market' or price <= o.price)
      order by price asc, created_at asc limit 1;
    else
      select * into match_o from orders
      where coin_symbol = o.coin_symbol and side = 'buy'
        and status in ('open','partially_filled') and id != o.id
        and (o.order_type = 'market' or price >= o.price)
      order by price desc, created_at asc limit 1;
    end if;

    exit when not found;

    v_trade_price := match_o.price;
    v_trade_amount := least(o.amount - o.filled_amount, match_o.amount - match_o.filled_amount);
    v_fee := v_trade_amount * v_trade_price * v_fee_rate;

    if o.side = 'buy' then
      v_buy_order_id := o.id;
      v_sell_order_id := match_o.id;
    else
      v_buy_order_id := match_o.id;
      v_sell_order_id := o.id;
    end if;

    insert into trades (buy_order_id, sell_order_id, coin_symbol, price, amount, fee)
    values (v_buy_order_id, v_sell_order_id, o.coin_symbol, v_trade_price, v_trade_amount, v_fee);

    update orders set filled_amount = filled_amount + v_trade_amount,
      status = case when filled_amount + v_trade_amount >= amount then 'filled' else 'partially_filled' end
      where id = o.id;
    update orders set filled_amount = filled_amount + v_trade_amount,
      status = case when filled_amount + v_trade_amount >= amount then 'filled' else 'partially_filled' end
      where id = match_o.id;

    v_buyer_id := (select user_id from orders where id = v_buy_order_id);
    v_net_received := v_trade_amount - (v_trade_amount * v_fee_rate);

    update wallets set locked_balance = locked_balance - (v_trade_amount * v_trade_price)
      where user_id = v_buyer_id and coin_symbol = 'TOMAN';

    select balance, avg_buy_price into v_old_balance, v_old_avg
      from wallets where user_id = v_buyer_id and coin_symbol = o.coin_symbol;

    if v_old_balance is null then
      insert into wallets (user_id, coin_symbol, balance, avg_buy_price)
        values (v_buyer_id, o.coin_symbol, v_net_received, v_trade_price);
    else
      update wallets
        set balance = balance + v_net_received,
            avg_buy_price = case
              when (coalesce(balance,0) + v_net_received) = 0 then null
              else ((coalesce(balance,0) * coalesce(v_old_avg, v_trade_price)) + (v_net_received * v_trade_price))
                   / (coalesce(balance,0) + v_net_received)
            end
        where user_id = v_buyer_id and coin_symbol = o.coin_symbol;
    end if;

    update wallets set locked_balance = locked_balance - v_trade_amount
      where user_id = (select user_id from orders where id = v_sell_order_id) and coin_symbol = o.coin_symbol;
    insert into wallets (user_id, coin_symbol, balance)
      values ((select user_id from orders where id = v_sell_order_id), 'TOMAN', (v_trade_amount * v_trade_price) - v_fee)
      on conflict (user_id, coin_symbol) do update set balance = wallets.balance + (v_trade_amount * v_trade_price) - v_fee;

    select * into o from orders where id = o.id;
  end loop;
end;
$$ language plpgsql security definer;

-- 5) Portfolio value snapshots — for the real performance chart.
create table if not exists portfolio_snapshots (
  id uuid primary key default gen_random_uuid(),
  user_id uuid references profiles(id) not null,
  total_toman numeric(24,2) not null,
  recorded_at timestamptz not null default now()
);
create index if not exists idx_portfolio_snapshots_user_time on portfolio_snapshots (user_id, recorded_at desc);

alter table portfolio_snapshots enable row level security;
create policy "user reads own snapshots" on portfolio_snapshots
  for select using (auth.uid() = user_id);

create or replace function snapshot_portfolios()
returns void as $$
begin
  insert into portfolio_snapshots (user_id, total_toman)
  select
    w.user_id,
    sum(
      case when w.coin_symbol = 'TOMAN'
        then w.balance + w.locked_balance
        else (w.balance + w.locked_balance) * coalesce(mp.price_toman, 0)
      end
    ) as total_toman
  from wallets w
  left join market_prices mp on mp.coin_symbol = w.coin_symbol
  group by w.user_id;
end;
$$ language plpgsql security definer;

-- Snapshot every 15 minutes (coarser than the 30s price sync, to keep the table small).
select cron.schedule(
  'snapshot-portfolios-job',
  '15 minutes',
  $$ select snapshot_portfolios(); $$
);
