# FrostPuno Supabase

This folder contains the MVP database structure for FrostPuno.

## Files

- `migrations/001_create_core_tables.sql`: core tables, constraints, indexes and update triggers.
- `migrations/002_add_feedback_and_observations.sql`: feedback de predicciones y observaciones oficiales para mejora supervisada.
- `migrations/20260529201250_apply_rls_policies.sql`: RLS, grants and MVP policies ready for `supabase db push`.
- `policies/rls_policies.sql`: Row Level Security, grants and MVP policies.
- `seed/seed_locations.sql`: small Puno seed for demo locations and model version `v0.1.0`.

## CLI setup

```powershell
npx supabase login
npx supabase link --project-ref <your-project-ref>
npx supabase db push
```

Then run `seed/seed_locations.sql` from the SQL Editor if demo seed data is needed.

## Manual setup with SQL Editor

1. Create a Supabase project from the Supabase Dashboard.
2. Open `SQL Editor`.
3. Run `migrations/001_create_core_tables.sql`.
4. Run `migrations/002_add_feedback_and_observations.sql`.
5. Run `migrations/20260529201250_apply_rls_policies.sql`.
6. Run `seed/seed_locations.sql`.
7. Go to `Project Settings > API`.
8. Copy the project URL.
9. Copy the `service_role` key only into the backend environment in Render.
10. Do not copy the `service_role` key into Flutter, Vercel or any browser bundle.

## Environment variables

Never place the service role key in Flutter, Flutter Web, Vercel public variables or any client-side code.

```env
SUPABASE_URL=https://your-project-ref.supabase.co
SUPABASE_SERVICE_ROLE_KEY=your-server-only-service-role-key
ENABLE_SUPABASE=true
```

For the first deployed demo, keep `ENABLE_SUPABASE=false` until the SQL files are executed and verified. Then switch it to `true` in Render and redeploy.

## Security model

- Public reference tables are readable by `anon` and `authenticated`:
  - `inei_locations`
  - `populated_centers`
  - `agricultural_context`
- `frost_predictions` is inserted by FastAPI using the service role key.
- Authenticated users may read only predictions whose `user_id` matches `auth.uid()`.
- In this MVP, prediction requests do not yet include authenticated user context, so backend inserts use `user_id = null`.
- `model_versions` exposes only active rows to public clients.
- `prediction_feedback` and `official_frost_observations` support supervised ML improvement; review grants/RLS before exposing them to clients.

## MVP limitations

- The seed location data is a documented MVP seed and must be replaced with official INEI exports before production.
- The service role key bypasses RLS and must remain server-side only.
- The free tier is appropriate for demos, but keep historical weather raw data outside Supabase or heavily summarized to avoid storage/database limits.
- Public reference tables are readable for demo purposes. Review grants, Data API exposure and RLS policies before using real producer or household data.
- Prediction rows inserted without authenticated users use `user_id = null`; per-user history requires a later authentication integration.
