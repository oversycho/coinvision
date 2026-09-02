import { createClient } from 'npm:@supabase/supabase-js@2'

const COIN_IDS: Record<string, string> = {
  bitcoin: 'BTC',
  ethereum: 'ETH',
  tether: 'USDT',
  tron: 'TRX',
}

Deno.serve(async () => {
  const supabase = createClient(
    Deno.env.get('SUPABASE_URL')!,
    Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')!
  )

  try {
    const ids = Object.keys(COIN_IDS).join(',')
    // /coins/markets gives current_price, high_24h, low_24h, total_volume,
    // and 24h % change all in one call (unlike /simple/price).
    const res = await fetch(
      `https://api.coingecko.com/api/v3/coins/markets?vs_currency=usd&ids=${ids}`
    )
    const data = await res.json() as any[]

    const usdToTomanRate = 95000 // update periodically, or wire to a live FX source later

    for (const row of data) {
      const symbol = COIN_IDS[row.id as string]
      if (!symbol) continue

      const priceUsdt = row.current_price
      const priceToman = priceUsdt * usdToTomanRate
      const change24h = row.price_change_percentage_24h ?? 0
      const high24h = (row.high_24h ?? priceUsdt) * usdToTomanRate
      const low24h = (row.low_24h ?? priceUsdt) * usdToTomanRate
      const volumeUsd = row.total_volume ?? 0

      await supabase.from('market_prices').upsert({
        coin_symbol: symbol,
        price_toman: priceToman,
        price_usdt: priceUsdt,
        change_24h: change24h,
        high_24h: high24h,
        low_24h: low24h,
        volume_usd: volumeUsd,
        updated_at: new Date().toISOString(),
      })

      // Raw tick for candle aggregation (see get_candles() in Postgres).
      await supabase.from('price_history').insert({
        coin_symbol: symbol,
        price_toman: priceToman,
        price_usdt: priceUsdt,
      })
    }
  } catch (e) {
    console.error('error fetching prices:', e)
  }

  return new Response('ok')
})
