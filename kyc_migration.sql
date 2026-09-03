-- ============================================================
-- CoinVision — KYC Migration
-- Run in Supabase SQL Editor.
-- ============================================================

create table if not exists kyc_submissions (
  id uuid primary key default gen_random_uuid(),
  user_id uuid references profiles(id) not null,
  full_name text not null,
  national_id text not null,
  status text not null default 'pending', -- pending -> approved | rejected
  submitted_at timestamptz not null default now(),
  reviewed_at timestamptz
);
create index if not exists idx_kyc_user on kyc_submissions (user_id, submitted_at desc);

alter table kyc_submissions enable row level security;
create policy "user manages own kyc" on kyc_submissions
  for all using (auth.uid() = user_id);

alter publication supabase_realtime add table kyc_submissions;

-- Simulated review: auto-approve any pending submission after ~20 seconds,
-- exactly like the deposit confirmation flow.
create or replace function process_kyc_submissions()
returns void as $$
begin
  update kyc_submissions
  set status = 'approved', reviewed_at = now()
  where status = 'pending' and submitted_at < now() - interval '20 seconds';
end;
$$ language plpgsql security definer;

select cron.schedule(
  'process-kyc-job',
  '10 seconds',
  $$ select process_kyc_submissions(); $$
);
