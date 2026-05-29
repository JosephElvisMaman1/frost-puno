create table if not exists public.prediction_feedback (
  id uuid primary key default gen_random_uuid(),
  prediction_id uuid references public.frost_predictions(id) on delete set null,
  district text not null,
  latitude numeric(9,6) check (latitude between -18.5 and -13.0),
  longitude numeric(9,6) check (longitude between -71.5 and -68.0),
  observed_risk_level text check (observed_risk_level in ('bajo', 'medio', 'alto')),
  user_observed_frost boolean,
  crop_damage_observed boolean,
  notes text,
  source text not null default 'app_feedback',
  metadata jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now()
);

create table if not exists public.official_frost_observations (
  id uuid primary key default gen_random_uuid(),
  observed_at timestamptz not null,
  district text not null,
  latitude numeric(9,6) not null check (latitude between -18.5 and -13.0),
  longitude numeric(9,6) not null check (longitude between -71.5 and -68.0),
  altitude numeric(8,2) check (altitude between 0 and 7000),
  temperature_2m numeric(6,2),
  relative_humidity_2m numeric(5,2) check (relative_humidity_2m between 0 and 100),
  apparent_temperature numeric(6,2),
  dew_point_2m numeric(6,2),
  precipitation numeric(8,2) check (precipitation is null or precipitation >= 0),
  cloud_cover numeric(5,2) check (cloud_cover between 0 and 100),
  wind_speed_10m numeric(7,2) check (wind_speed_10m is null or wind_speed_10m >= 0),
  observed_risk_level text not null check (observed_risk_level in ('bajo', 'medio', 'alto')),
  source_name text not null default 'SENAMHI',
  source_url text,
  metadata jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now()
);

create index if not exists idx_prediction_feedback_created_at on public.prediction_feedback(created_at desc);
create index if not exists idx_official_frost_observations_district_time
  on public.official_frost_observations(district, observed_at desc);
