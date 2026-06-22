-- ============================================================
-- NoaPro Caller — proper region tagging
-- Replaces fragile file-name matching with a real region column.
-- Values: 'leeds' | 'kent' | 'both' | null (no region).
-- Run once in Supabase → SQL Editor → New query → paste → Run.
-- ============================================================
alter table public.leads add column if not exists region text;

-- Backfill the existing batches (per your mapping):
update public.leads set region = 'both'  where source_file ilike '%Construction Outreach%';      -- 1,015 → both
update public.leads set region = 'kent'  where source_file ilike '%— LEADS%'
                                            or source_file ilike 'OS-%';                          -- 124 + 979 → Kent
update public.leads set region = 'leeds' where source_file ilike '%— leeds' and region is null;   -- stragglers → Leeds

create index if not exists leads_region_idx on public.leads(region);

-- Connected-leads view needs the region too (the region filter reads it there).
-- Dropped + recreated (CREATE OR REPLACE can't insert a column mid-list).
drop view if exists public.contacted_leads;
create view public.contacted_leads
with (security_invoker = true) as
select
  l.id, l.business, l.phone, l.email, l.category, l.area, l.source_file, l.status, l.region,
  count(cl.*)::int                                          as attempts,
  max(cl.created_at)                                        as last_contact,
  (array_agg(cl.caller_id order by cl.created_at desc))[1]  as last_caller_id,
  (array_agg(cl.outcome   order by cl.created_at desc))[1]  as last_outcome
from public.leads l
join public.call_log cl on cl.lead_id = l.id
group by l.id;

grant select on public.contacted_leads to authenticated;
