-- ============================================================
-- NoaPro Caller — duplicate lead holding area
-- On import, leads that already exist (matched by phone or business
-- name) are NOT added to the queue — they land here for review.
-- Run once in Supabase → SQL Editor → New query → paste → Run.
-- ============================================================
create table if not exists public.duplicate_leads (
  id              bigint generated always as identity primary key,
  business        text not null,
  phone           text,
  email           text,
  category        text,
  area            text,
  source_file     text,
  reason          text,                                   -- why it was treated as a duplicate
  matched_lead_id uuid references public.leads(id)    on delete set null,
  imported_by     uuid references public.profiles(id) on delete set null,
  created_at      timestamptz not null default now()
);
create index if not exists duplicate_leads_created_idx on public.duplicate_leads(created_at);

alter table public.duplicate_leads enable row level security;
drop policy if exists "auth all duplicate_leads" on public.duplicate_leads;
create policy "auth all duplicate_leads" on public.duplicate_leads for all to authenticated using (true) with check (true);

do $$ begin
  alter publication supabase_realtime add table public.duplicate_leads;
exception when duplicate_object then null; end $$;
