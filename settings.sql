-- ============================================================
-- NoaPro Caller — admin-editable team targets
-- Run once in Supabase → SQL Editor → New query → paste → Run.
-- ============================================================

-- Single-row settings table. Default: 10 calls/day, 5 sign-ups/day per caller.
create table if not exists public.app_settings (
  id                  int primary key default 1,
  daily_call_target   int not null default 10,
  daily_signup_target int not null default 5,
  updated_at          timestamptz default now(),
  constraint app_settings_single_row check (id = 1)
);

-- Seed the single row if it isn't there yet.
insert into public.app_settings (id) values (1) on conflict (id) do nothing;

-- Row-Level Security: everyone signed in can READ, only admins can CHANGE.
alter table public.app_settings enable row level security;

drop policy if exists "read settings" on public.app_settings;
create policy "read settings" on public.app_settings for select to authenticated using (true);

drop policy if exists "admin update settings" on public.app_settings;
create policy "admin update settings" on public.app_settings for update to authenticated
  using   (exists (select 1 from public.profiles p where p.id = auth.uid() and p.is_admin))
  with check (exists (select 1 from public.profiles p where p.id = auth.uid() and p.is_admin));

-- Live-sync changes to everyone's screen.
do $$ begin
  alter publication supabase_realtime add table public.app_settings;
exception when duplicate_object then null; end $$;
