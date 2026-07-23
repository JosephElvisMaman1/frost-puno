# Modelo no supervisado — K-Means (FrostPuno)

Modelo productivo del curso (aprendizaje **no supervisado**). Reemplaza al clasificador
supervisado previo (ver `docs/model_comparison_v1_vs_v2.md`, hoy legacy).

## Objetivo

1. Agrupar observaciones climáticas de Puno en **regímenes térmicos** (clusters).
2. Derivar niveles de **riesgo de helada** por distrito a partir del cluster dominante.
3. Alimentar la pantalla *Zonas* (`/ml/clusters`) y la predicción puntual (`/predict/frost-risk`).

## Pipeline

- Script: `ml_pipeline/clustering/train_clusters.py`
- Algoritmo: `KMeans` (scikit-learn) sobre features escaladas (`StandardScaler`), envuelto en un `Pipeline`.
- Selección de `k` (3–6) por **silhouette score**; se reportan además **Davies-Bouldin** e **inercia** (codo).
- Perfilado post-hoc: los clusters se ordenan por temperatura media; el más frío → riesgo `alto`, el más cálido → `bajo`. Esto es descripción del clustering, no reintroduce etiquetas supervisadas.

## Features (`CLUSTER_FEATURES` en `ml_pipeline/config.py`)

`altitud_estimada`, `temperature_2m`, `dew_point_2m`, `relative_humidity_2m`.

Subconjunto reducido a las variables más discriminantes para helada. Se descartaron
`precipitation`, `wind_speed_10m`, `cloud_cover` y `apparent_temperature` porque eran
ruidosas o colineales y **degradaban la separación de clusters** (silhouette bajaba a
~0.29). Todas están disponibles al agregar por distrito y en inferencia en vivo
(provienen de `CurrentWeatherResponse` + altitud), garantizando que el mismo vector se
construya en producción.

## Métricas (ejecución MVP)

- k seleccionado: **3**
- silhouette ≈ **0.419**, Davies-Bouldin ≈ **0.81** (más bajo es mejor)
- Selección de features vía experimento de subconjuntos (maximiza silhouette manteniendo variables con sentido físico).
- Gate de IC: `check_cluster_quality.py --min-silhouette 0.35`

## Salidas / artefactos

| Artefacto | Ruta |
|---|---|
| Modelo | `ml_pipeline/registry/frost_cluster_model.joblib` |
| Metadata (k, centroides, métricas, tiers, perfiles) | `ml_pipeline/registry/cluster_metadata.json` |
| Perfil de clusters | `ml_pipeline/evaluation/cluster_profiles.csv` |
| Agrupación de distritos | `data/processed/district_clusters.csv` |

## Inferencia en el backend

`prediction_service.py` construye el vector de features, asigna el **centroide más
cercano** (`KMeans.predict`) → nivel de riesgo vía `cluster_tiers` del metadata. La
**confianza** se deriva de la cercanía relativa al centroide (`KMeans.transform`).

## Métricas por qué no accuracy/f1

El modelo no tiene etiquetas de verdad de terreno: la calidad se mide por cohesión y
separación de clusters (silhouette, Davies-Bouldin), no por accuracy/f1 supervisado.

## Limitaciones

- Los niveles de riesgo se derivan del perfil térmico, no de observaciones oficiales.
- La semilla de distritos INEI es un MVP; reemplazar por exportes oficiales en producción.
- SENAMHI aún no aporta observaciones de campo como validación cruzada.
