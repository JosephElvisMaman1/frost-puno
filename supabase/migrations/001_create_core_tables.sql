create extension if not exists pgcrypto;

create or replace function public.set_updated_at()
returns trigger
language plpgsql
as $$
begin
  new.updated_at = now();
  return new;
end;
$$;

create table if not exists public.users_profile (
  id uuid primary key default gen_random_uuid(),
  user_id uuid unique references auth.users(id) on delete cascade,
  full_name text,
  role text not null default 'producer' check (role in ('producer', 'student', 'admin', 'researcher')),
  department text not null default 'Puno',
  province text,
  district text,
  community text,
  source text not null default 'app',
  metadata jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table if not exists public.inei_locations (
  id uuid primary key default gen_random_uuid(),
  ubigeo text not null unique check (ubigeo ~ '^[0-9]{6}$'),
  department text not null,
  province text not null,
  district text not null,
  latitude numeric(9,6) not null check (latitude between -18.5 and -13.0),
  longitude numeric(9,6) not null check (longitude between -71.5 and -68.0),
  estimated_altitude numeric(8,2) check (estimated_altitude between 0 and 7000),
  total_population integer check (total_population >= 0),
  rural_population integer check (rural_population >= 0),
  rural_percentage numeric(5,2) check (rural_percentage between 0 and 100),
  source text not null default 'INEI',
  metadata jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  constraint rural_population_lte_total check (
    total_population is null
    or rural_population is null
    or rural_population <= total_population
  )
);

create table if not exists public.populated_centers (
  id uuid primary key default gen_random_uuid(),
  location_id uuid references public.inei_locations(id) on delete set null,
  ubigeo text references public.inei_locations(ubigeo) on update cascade on delete set null,
  name text not null,
  category text,
  latitude numeric(9,6) check (latitude between -18.5 and -13.0),
  longitude numeric(9,6) check (longitude between -71.5 and -68.0),
  altitude numeric(8,2) check (altitude between 0 and 7000),
  population integer check (population >= 0),
  source text not null default 'INEI Sistema de Centros Poblados',
  metadata jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table if not exists public.agricultural_context (
  id uuid primary key default gen_random_uuid(),
  location_id uuid references public.inei_locations(id) on delete cascade,
  ubigeo text references public.inei_locations(ubigeo) on update cascade on delete cascade,
  crop text not null,
  agricultural_activity boolean not null default true,
  cultivated_area_ha numeric(12,2) check (cultivated_area_ha is null or cultivated_area_ha >= 0),
  production_tons numeric(12,2) check (production_tons is null or production_tons >= 0),
  yield_ton_ha numeric(12,4) check (yield_ton_ha is null or yield_ton_ha >= 0),
  reference_year integer check (reference_year between 1900 and 2100),
  source text not null default 'INEI/MIDAGRI-SIEA',
  metadata jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table if not exists public.weather_records (
  id uuid primary key default gen_random_uuid(),
  location_id uuid references public.inei_locations(id) on delete set null,
  ubigeo text references public.inei_locations(ubigeo) on update cascade on delete set null,
  observed_at timestamptz not null,
  latitude numeric(9,6) not null check (latitude between -18.5 and -13.0),
  longitude numeric(9,6) not null check (longitude between -71.5 and -68.0),
  temperature_2m numeric(6,2),
  relative_humidity_2m numeric(5,2) check (relative_humidity_2m between 0 and 100),
  apparent_temperature numeric(6,2),
  dew_point_2m numeric(6,2),
  precipitation numeric(8,2) check (precipitation is null or precipitation >= 0),
  cloud_cover numeric(5,2) check (cloud_cover between 0 and 100),
  wind_speed_10m numeric(7,2) check (wind_speed_10m is null or wind_speed_10m >= 0),
  source text not null default 'Open-Meteo',
  metadata jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now()
);

create table if not exists public.model_versions (
  id uuid primary key default gen_random_uuid(),
  version text not null unique,
  model_name text not null,
  algorithm text not null,
  artifact_path text not null,
  accuracy numeric(8,6) check (accuracy between 0 and 1),
  precision_macro numeric(8,6) check (precision_macro between 0 and 1),
  recall_macro numeric(8,6) check (recall_macro between 0 and 1),
  f1_macro numeric(8,6) check (f1_macro between 0 and 1),
  dataset_size integer not null check (dataset_size >= 0),
  status text not null default 'candidate' check (status in ('candidate', 'active', 'rejected', 'archived')),
  source text not null default 'ml_pipeline',
  metadata jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now(),
  deployed_at timestamptz
);

create table if not exists public.training_runs (
  id uuid primary key default gen_random_uuid(),
  model_version_id uuid references public.model_versions(id) on delete set null,
  run_name text,
  dataset_path text,
  dataset_hash text,
  git_commit text,
  accuracy numeric(8,6) check (accuracy between 0 and 1),
  precision_macro numeric(8,6) check (precision_macro between 0 and 1),
  recall_macro numeric(8,6) check (recall_macro between 0 and 1),
  f1_macro numeric(8,6) check (f1_macro between 0 and 1),
  status text not null default 'completed' check (status in ('started', 'completed', 'failed', 'promoted', 'rejected')),
  source text not null default 'github_actions_or_local',
  metadata jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table if not exists public.frost_predictions (
  id uuid primary key default gen_random_uuid(),
  user_id uuid references auth.users(id) on delete set null,
  location_id uuid references public.inei_locations(id) on delete set null,
  model_version_id uuid references public.model_versions(id) on delete set null,
  district text not null,
  province text not null,
  populated_center text,
  latitude numeric(9,6) not null check (latitude between -18.5 and -13.0),
  longitude numeric(9,6) not null check (longitude between -71.5 and -68.0),
  altitude numeric(8,2) check (altitude between 0 and 7000),
  input_payload jsonb not null,
  risk_level text not null check (risk_level in ('bajo', 'medio', 'alto')),
  confidence numeric(6,5) not null check (confidence between 0 and 1),
  chuno_conditions text not null check (chuno_conditions in ('favorables', 'posibles', 'no_favorables')),
  recommendation text not null,
  model_version text not null,
  data_sources jsonb not null default '[]'::jsonb,
  source text not null default 'backend_fastapi',
  metadata jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now()
);

create table if not exists public.alerts (
  id uuid primary key default gen_random_uuid(),
  location_id uuid references public.inei_locations(id) on delete set null,
  prediction_id uuid references public.frost_predictions(id) on delete set null,
  title text not null,
  message text not null,
  risk_level text not null check (risk_level in ('bajo', 'medio', 'alto')),
  channel text not null default 'app' check (channel in ('app', 'email', 'push', 'sms', 'whatsapp')),
  status text not null default 'draft' check (status in ('draft', 'sent', 'cancelled', 'failed')),
  starts_at timestamptz,
  ends_at timestamptz,
  source text not null default 'backend_fastapi',
  metadata jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table if not exists public.data_sources_log (
  id uuid primary key default gen_random_uuid(),
  source_name text not null,
  source_type text not null check (source_type in ('INEI', 'SENAMHI', 'Open-Meteo', 'MIDAGRI-SIEA', 'manual', 'other')),
  resource_url text,
  file_path text,
  rows_processed integer check (rows_processed is null or rows_processed >= 0),
  status text not null default 'completed' check (status in ('started', 'completed', 'failed')),
  checksum text,
  error_message text,
  source text not null default 'pipeline',
  metadata jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now()
);

create index if not exists idx_inei_locations_ubigeo on public.inei_locations(ubigeo);
create index if not exists idx_populated_centers_ubigeo on public.populated_centers(ubigeo);
create index if not exists idx_agricultural_context_ubigeo_crop on public.agricultural_context(ubigeo, crop);
create index if not exists idx_weather_records_ubigeo_observed_at on public.weather_records(ubigeo, observed_at desc);
create index if not exists idx_frost_predictions_created_at on public.frost_predictions(created_at desc);
create index if not exists idx_frost_predictions_user_id on public.frost_predictions(user_id);
create index if not exists idx_model_versions_status on public.model_versions(status);

drop trigger if exists set_users_profile_updated_at on public.users_profile;
create trigger set_users_profile_updated_at
before update on public.users_profile
for each row execute function public.set_updated_at();

drop trigger if exists set_inei_locations_updated_at on public.inei_locations;
create trigger set_inei_locations_updated_at
before update on public.inei_locations
for each row execute function public.set_updated_at();

drop trigger if exists set_populated_centers_updated_at on public.populated_centers;
create trigger set_populated_centers_updated_at
before update on public.populated_centers
for each row execute function public.set_updated_at();

drop trigger if exists set_agricultural_context_updated_at on public.agricultural_context;
create trigger set_agricultural_context_updated_at
before update on public.agricultural_context
for each row execute function public.set_updated_at();

drop trigger if exists set_training_runs_updated_at on public.training_runs;
create trigger set_training_runs_updated_at
before update on public.training_runs
for each row execute function public.set_updated_at();

drop trigger if exists set_alerts_updated_at on public.alerts;
create trigger set_alerts_updated_at
before update on public.alerts
for each row execute function public.set_updated_at();

