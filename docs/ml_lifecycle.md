# FrostPuno - Ciclo de vida ML

> **Modelo actual:** no supervisado (K-Means). El paso de entrenamiento es
> `ml_pipeline.clustering.train_clusters` y el gate de calidad usa silhouette
> (`check_cluster_quality.py`). Ver `docs/clustering_model.md`.

## 1. Ingesta

- `ingest_locations.py` valida `data/external/inei_puno_districts.csv` y produce `data/processed/locations_puno.csv`.
- `ingest_weather_open_meteo.py` consulta Open-Meteo por distrito en paralelo y produce `data/raw/weather_open_meteo.csv`.

## 2. Features y etiquetas

- `build_features.py` une ubicaciones y clima.
- Calcula `mes`, `hora`, `temperatura_minima_diaria` y `horas_bajo_cero`.
- Genera `riesgo_helada` con la regla inicial:
  - alto: temperatura minima diaria <= 0 C o horas bajo cero >= 3;
  - medio: temperatura minima diaria > 0 C y <= 3 C;
  - bajo: temperatura minima diaria > 3 C.

## 3. Validacion

- `validate_dataset.py` revisa columnas, nulos criticos, clases esperadas y rangos climaticos basicos.

## 4. Entrenamiento

- `train_models.py` entrena:
  - LogisticRegression;
  - DecisionTreeClassifier;
  - RandomForestClassifier.
- Usa `train_test_split` con `random_state=42`.
- Compara modelos con `f1_macro` como metrica principal.

## 5. Registro

El mejor modelo se guarda en:

- `ml_pipeline/registry/frost_risk_model.joblib`
- `ml_pipeline/registry/model_metadata.json`

El metadata incluye version, fecha, features, target, metricas, tamano del dataset, fuentes y limitaciones.

## 6. Evaluacion

- `evaluate_model.py` genera:
  - `ml_pipeline/evaluation/evaluation_report.json`
  - `ml_pipeline/evaluation/confusion_matrix.csv`

## 7. Mejora continua

Flujo supervisado MVP:

1. recolectar predicciones y clima nuevo;
2. recolectar observaciones externas SENAMHI/campo o feedback de productores;
3. validar calidad de datos;
4. evaluar el modelo activo/candidato contra observaciones;
5. reentrenar por GitHub Actions o local controlado;
6. evaluar el modelo candidato;
7. ejecutar `model-quality-gate.yml`;
8. versionar artefactos y metadata;
9. promover manualmente solo si cumple calidad.

El sistema no se autoentrena directamente con cualquier dato nuevo. La mejora es supervisada para evitar contaminar el modelo con datos incorrectos o etiquetas no verificadas.

## 8. CI/CD ML

Los workflows principales son:

- `data-validation.yml`: valida ubicaciones, descarga clima demo, construye features y falla ante columnas faltantes, nulos criticos o rangos imposibles.
- `ml-training.yml`: ejecuta el pipeline completo con fechas demo configurables y guarda artefactos.
- `model-quality-gate.yml`: lee `model_metadata.json` y falla si `f1_macro` no supera el umbral `MIN_F1_MACRO`.

La ventana demo mantiene GitHub Actions liviano. Para produccion se ampliarian rango temporal, distritos y validacion SENAMHI.

## 9. Extension climatica SENAMHI/Open-Meteo

La evolucion movil introduce un contrato de proveedores climaticos desacoplado. SENAMHI queda como fuente oficial peruana prioritaria para validacion y enriquecimiento futuro, mientras Open-Meteo opera como fallback cuando no existe una API publica estable configurada para el MVP.

Nuevos features candidatos: temperatura minima oficial, humedad oficial, velocidad de viento, nubosidad, estacion cercana, distancia a estacion, altitud real, sensacion termica, presion atmosferica y radiacion.

Estos campos se documentan como contrato futuro. No se reentrena automaticamente el modelo hasta contar con dataset validado, etiquetas revisadas y comparacion contra la version activa.

## 10. Mejoras de validacion del modelo

La version `v0.2.0` introduce una evaluacion experimental mas realista sin cambiar el modelo activo en produccion.

### Data leakage identificado

En `v0.1.0`, las etiquetas `riesgo_helada` se generan con reglas basadas en:

- `temperatura_minima_diaria`;
- `horas_bajo_cero`.

Esas columnas tambien estaban dentro de las features de entrenamiento. Por eso `f1_macro = 1.0` debe interpretarse como una validacion optimista del pipeline, no como prueba de desempeno perfecto en campo.

### Dataset v2

Se crea un dataset nuevo:

- `data/processed/frost_training_dataset_v2.csv`

No se modifica `frost_training_dataset.csv`.

Features v2:

- `latitud`
- `longitud`
- `altitud_estimada`
- `temperature_2m`
- `relative_humidity_2m`
- `apparent_temperature`
- `dew_point_2m`
- `precipitation`
- `cloud_cover`
- `wind_speed_10m`
- `mes`
- `hora`

Columnas removidas como features:

- `temperatura_minima_diaria`
- `horas_bajo_cero`

La etiqueta `riesgo_helada` se mantiene para compatibilidad academica del MVP.

### Splits realistas

`train_models_v2.py` implementa dos estrategias reproducibles:

- `district`: separa distritos completos entre train y test. Es la estrategia preferida para `v0.2.0`.
- `time`: entrena con fechas iniciales y evalua contra fechas mas recientes.

Comando principal:

```powershell
python -m ml_pipeline.features.build_features_v2
python -m ml_pipeline.training.train_models_v2 --version v0.2.0 --split-strategy district --test-size 0.30
```

### Artefactos v0.2.0

- `ml_pipeline/registry/frost_risk_model_v0_2_0.joblib`
- `ml_pipeline/registry/model_metadata_v0_2_0.json`
- `ml_pipeline/evaluation/confusion_matrix_v0_2_0.csv`
- `ml_pipeline/evaluation/metrics_comparison_v0_2_0.json`

El backend sigue usando `ml_pipeline/registry/frost_risk_model.joblib`, por lo que FastAPI, Supabase y Flutter permanecen compatibles con produccion.

### Impacto en metricas

Las metricas bajan porque el modelo deja de ver variables derivadas de la etiqueta. Este resultado es esperado y deseable para una evaluacion honesta.

`v0.2.0` no debe considerarse automaticamente superior en precision. Su valor esta en mejorar el diseno experimental y mostrar limites reales: falsos positivos, falsos negativos y generalizacion a distritos no vistos.

## 11. Validacion con observaciones SENAMHI/campo

Se agrego un contrato incremental para validar contra observaciones externas:

- `data/validation/senamhi_frost_observations_sample.csv`
- `ml_pipeline/evaluation/evaluate_observed_events.py`
- `ml_pipeline/evaluation/senamhi_observation_evaluation_v0_2_0.json`

Comando:

```powershell
python -m ml_pipeline.evaluation.evaluate_observed_events
```

El archivo de muestra define el formato requerido para reemplazarlo por datos oficiales: fecha observada, distrito, coordenadas, variables climaticas actuales, etiqueta observada y fuente. Esta etapa ayuda a decidir si una version candidata debe reentrenarse, rechazarse o promoverse.

Metricas de muestra generadas para `v0.2.0`:

- accuracy: `0.6000`
- precision macro: `0.3889`
- recall macro: `0.5000`
- f1 macro: `0.4333`

Estas metricas no son definitivas porque el archivo es pequeno y demostrativo. Su valor es dejar el pipeline listo para evidencia oficial.
