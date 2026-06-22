-- ============================================================
-- NoaPro Caller — all-time per-caller totals (for the Admin panel)
-- Run once in Supabase → SQL Editor → New query → paste → Run.
-- ============================================================

-- A lightweight view: one row per caller with their lifetime call + sign-up counts.
-- security_invoker = true means it respects the caller's own RLS on call_log
-- (authenticated users can already read the log for the dashboard).
create or replace view public.caller_stats
with (security_invoker = true) as
select
  caller_id,
  count(*)::int                                         as calls,
  count(*) filter (where outcome = 'Signed up')::int    as signups
from public.call_log
group by caller_id;

grant select on public.caller_stats to authenticated;
