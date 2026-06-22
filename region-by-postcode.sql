-- ============================================================
-- NoaPro Caller — region by postcode area
-- Rule: Yorkshire postcode areas → Leeds; everything else
-- (London/South postcodes + Kent town names) → Kent.
-- Yorkshire & Humber areas: BD DN HD HG HU HX LS S WF YO
-- (matched as the area letters immediately followed by a digit,
--  so e.g. "S61" = Sheffield → Leeds, but "SE1"/"SW6" = London → Kent).
-- Run once in Supabase → SQL Editor → New query → paste → Run.
-- ============================================================
update public.leads
set region = case
  when area ~* '^(BD|DN|HD|HG|HU|HX|LS|S|WF|YO)[0-9]' then 'leeds'
  else 'kent'
end;
