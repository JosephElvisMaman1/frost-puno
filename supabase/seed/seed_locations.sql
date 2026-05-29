insert into public.inei_locations (
  ubigeo,
  department,
  province,
  district,
  latitude,
  longitude,
  estimated_altitude,
  total_population,
  rural_population,
  rural_percentage,
  source,
  metadata
) values
  ('210101', 'Puno', 'Puno', 'Puno', -15.840200, -70.021900, 3827, 128637, 21868, 16.99, 'INEI-compatible MVP seed', '{"note":"Replace with official INEI EstaDist/CPV 2017 export before production."}'::jsonb),
  ('210201', 'Puno', 'Azangaro', 'Azangaro', -14.908400, -70.196200, 3859, 28137, 15194, 54.00, 'INEI-compatible MVP seed', '{"note":"Replace with official INEI EstaDist/CPV 2017 export before production."}'::jsonb),
  ('210301', 'Puno', 'Carabaya', 'Macusani', -14.069700, -70.431100, 4315, 12240, 4651, 38.00, 'INEI-compatible MVP seed', '{"note":"Replace with official INEI EstaDist/CPV 2017 export before production."}'::jsonb),
  ('210401', 'Puno', 'Chucuito', 'Juli', -16.212200, -69.459600, 3869, 22310, 12717, 57.00, 'INEI-compatible MVP seed', '{"note":"Replace with official INEI EstaDist/CPV 2017 export before production."}'::jsonb),
  ('210501', 'Puno', 'El Collao', 'Ilave', -16.083300, -69.638900, 3850, 50239, 34163, 68.00, 'INEI-compatible MVP seed', '{"note":"Replace with official INEI EstaDist/CPV 2017 export before production."}'::jsonb),
  ('211101', 'Puno', 'San Roman', 'Juliaca', -15.499700, -70.133300, 3825, 276110, 22089, 8.00, 'INEI-compatible MVP seed', '{"note":"Replace with official INEI EstaDist/CPV 2017 export before production."}'::jsonb)
on conflict (ubigeo) do update set
  department = excluded.department,
  province = excluded.province,
  district = excluded.district,
  latitude = excluded.latitude,
  longitude = excluded.longitude,
  estimated_altitude = excluded.estimated_altitude,
  total_population = excluded.total_population,
  rural_population = excluded.rural_population,
  rural_percentage = excluded.rural_percentage,
  source = excluded.source,
  metadata = excluded.metadata;

insert into public.model_versions (
  version,
  model_name,
  algorithm,
  artifact_path,
  accuracy,
  precision_macro,
  recall_macro,
  f1_macro,
  dataset_size,
  status,
  deployed_at,
  metadata
) values (
  'v0.1.0',
  'RandomForestClassifier',
  'RandomForestClassifier',
  'ml_pipeline/registry/frost_risk_model.joblib',
  1.000000,
  1.000000,
  1.000000,
  1.000000,
  4368,
  'active',
  now(),
  '{"limitations":["Initial labels are rule-based.","Metrics are optimistic because label-derived features are included."],"sources":["Open-Meteo","INEI-compatible MVP seed"]}'::jsonb
)
on conflict (version) do update set
  model_name = excluded.model_name,
  algorithm = excluded.algorithm,
  artifact_path = excluded.artifact_path,
  accuracy = excluded.accuracy,
  precision_macro = excluded.precision_macro,
  recall_macro = excluded.recall_macro,
  f1_macro = excluded.f1_macro,
  dataset_size = excluded.dataset_size,
  status = excluded.status,
  deployed_at = excluded.deployed_at,
  metadata = excluded.metadata;

