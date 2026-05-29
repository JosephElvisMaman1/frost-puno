create or replace function public.set_updated_at()
returns trigger
language plpgsql
set search_path = public
as $function$
begin
  new.updated_at = now();
  return new;
end;
$function$;

drop policy if exists "Service role manages weather records" on public.weather_records;
create policy "Service role manages weather records"
on public.weather_records
for all
to service_role
using (true)
with check (true);

drop policy if exists "Service role manages alerts" on public.alerts;
create policy "Service role manages alerts"
on public.alerts
for all
to service_role
using (true)
with check (true);

drop policy if exists "Service role manages training runs" on public.training_runs;
create policy "Service role manages training runs"
on public.training_runs
for all
to service_role
using (true)
with check (true);

drop policy if exists "Service role manages data source logs" on public.data_sources_log;
create policy "Service role manages data source logs"
on public.data_sources_log
for all
to service_role
using (true)
with check (true);

drop policy if exists "Service role manages prediction feedback" on public.prediction_feedback;
create policy "Service role manages prediction feedback"
on public.prediction_feedback
for all
to service_role
using (true)
with check (true);

drop policy if exists "Service role manages official frost observations" on public.official_frost_observations;
create policy "Service role manages official frost observations"
on public.official_frost_observations
for all
to service_role
using (true)
with check (true);
