alter table public.users_profile enable row level security;
alter table public.inei_locations enable row level security;
alter table public.populated_centers enable row level security;
alter table public.agricultural_context enable row level security;
alter table public.weather_records enable row level security;
alter table public.frost_predictions enable row level security;
alter table public.alerts enable row level security;
alter table public.model_versions enable row level security;
alter table public.training_runs enable row level security;
alter table public.data_sources_log enable row level security;
alter table public.prediction_feedback enable row level security;
alter table public.official_frost_observations enable row level security;

grant usage on schema public to anon, authenticated, service_role;

grant select on public.inei_locations to anon, authenticated;
grant select on public.populated_centers to anon, authenticated;
grant select on public.agricultural_context to anon, authenticated;
grant select on public.model_versions to anon, authenticated;
grant select on public.frost_predictions to authenticated;

grant select, insert, update, delete on public.users_profile to authenticated, service_role;
grant select, insert, update, delete on public.inei_locations to service_role;
grant select, insert, update, delete on public.populated_centers to service_role;
grant select, insert, update, delete on public.agricultural_context to service_role;
grant select, insert, update, delete on public.weather_records to service_role;
grant select, insert, update, delete on public.frost_predictions to service_role;
grant select, insert, update, delete on public.alerts to service_role;
grant select, insert, update, delete on public.model_versions to service_role;
grant select, insert, update, delete on public.training_runs to service_role;
grant select, insert, update, delete on public.data_sources_log to service_role;
grant select, insert, update, delete on public.prediction_feedback to service_role;
grant select, insert, update, delete on public.official_frost_observations to service_role;

drop policy if exists "Users can read own profile" on public.users_profile;
create policy "Users can read own profile"
on public.users_profile
for select
to authenticated
using ((select auth.uid()) = user_id);

drop policy if exists "Users can update own profile" on public.users_profile;
create policy "Users can update own profile"
on public.users_profile
for update
to authenticated
using ((select auth.uid()) = user_id)
with check ((select auth.uid()) = user_id);

drop policy if exists "Users can insert own profile" on public.users_profile;
create policy "Users can insert own profile"
on public.users_profile
for insert
to authenticated
with check ((select auth.uid()) = user_id);

drop policy if exists "Public can read INEI locations" on public.inei_locations;
create policy "Public can read INEI locations"
on public.inei_locations
for select
to anon, authenticated
using (true);

drop policy if exists "Public can read populated centers" on public.populated_centers;
create policy "Public can read populated centers"
on public.populated_centers
for select
to anon, authenticated
using (true);

drop policy if exists "Public can read agricultural context" on public.agricultural_context;
create policy "Public can read agricultural context"
on public.agricultural_context
for select
to anon, authenticated
using (true);

drop policy if exists "Users can read own frost predictions" on public.frost_predictions;
create policy "Users can read own frost predictions"
on public.frost_predictions
for select
to authenticated
using ((select auth.uid()) = user_id);

drop policy if exists "Public can read active model versions" on public.model_versions;
create policy "Public can read active model versions"
on public.model_versions
for select
to anon, authenticated
using (status = 'active');

-- No anon/authenticated insert policy is defined for frost_predictions in this MVP.
-- No anon/authenticated insert policy is defined for frost_predictions,
-- prediction_feedback or official_frost_observations in this MVP.
-- FastAPI/ML operators write with the server-side service role key, which bypasses RLS.
-- Never expose the service role key in Flutter, Flutter Web, Vercel client code, or logs.
