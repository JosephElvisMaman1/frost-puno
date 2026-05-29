# FrostPuno - Ciclo de vida ML

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

Flujo automatizado MVP:

1. recolectar predicciones y clima nuevo;
2. validar calidad de datos;
3. reentrenar por GitHub Actions;
4. evaluar el modelo candidato;
5. ejecutar `model-quality-gate.yml`;
6. versionar artefactos y metadata;
7. promover manualmente solo si cumple calidad.

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
