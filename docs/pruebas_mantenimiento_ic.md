# Pruebas de funcionamiento del mantenimiento e integración continua

Evidencia para el criterio **"Pruebas de funcionamiento de mantenimiento e IC" (2 pts)**.
No basta con que los pipelines existan: aquí se comprueba que **funcionan y que bloquean
lo que deben bloquear**.

## 1. Qué flujos de mantenimiento existen

| Flujo | Implementación | Disparo |
|---|---|---|
| Reentrenamiento del modelo | `ml_pipeline/clustering/train_clusters.py` | manual / workflow |
| **Reentrenamiento adaptativo** | `ml_pipeline/clustering/adaptive_retrain.py` | **cron semanal** (`ml-training.yml`) |
| Quality gate (barrera) | `ml_pipeline/registry/check_cluster_quality.py` | cada push y PR |
| Pruebas de la API | `backend_fastapi/tests/` | cada push y PR |
| Validación de datos | `ml_pipeline/preprocessing/validate_dataset.py` | cada push y PR |
| Build del cliente | `flutter-build.yml` | cada push y PR |

## 2. Pruebas automatizadas del mantenimiento

`ml_pipeline/tests/test_maintenance_ci.py` (6 pruebas, corren en el workflow
**Model Quality Gate**):

| Prueba | Qué demuestra |
|---|---|
| `test_registry_artifacts_exist` | El reentrenamiento deja modelo, metadata y agrupación de distritos. |
| `test_model_loads_and_predicts` | El `.joblib` se carga e infiere → el contrato con el backend sigue vivo. |
| `test_district_groupings_cover_all_districts` | Los 13 distritos quedan asignados a un tier válido. |
| `test_hyperparameters_are_optimized` | La metadata documenta el grid search y la config elegida es la mejor del grid. |
| `test_quality_gate_passes_for_production_model` | El gate **aprueba** el modelo en producción. |
| **`test_quality_gate_blocks_degraded_model`** | El gate **bloquea** (exit code 1) un modelo con silhouette 0.10 → la integración se detiene ante una regresión. |

Ejecutar localmente:

```bash
python -m pytest ml_pipeline/tests/test_maintenance_ci.py -v
```

Resultado esperado: `6 passed`.

## 3. Prueba manual del quality gate (demo en vivo)

Se puede demostrar la barrera en la exposición sin romper nada:

```bash
python -m ml_pipeline.registry.check_cluster_quality --min-silhouette 0.35
```
→ `QUALITY GATE PASSED: silhouette=0.419456`

```bash
python -m ml_pipeline.registry.check_cluster_quality --min-silhouette 0.99
```
→ `QUALITY GATE FAILED` y **exit code 1**: así es como la IC detiene la promoción de un
modelo que empeoró.

## 4. Prueba del reentrenamiento adaptativo

```bash
python -m ml_pipeline.clustering.adaptive_retrain --target 0.45 --max-iters 3
```

El script ingesta clima (en paralelo por distrito), reconstruye features, hace grid search
y mide silhouette. Si no alcanza el objetivo, **amplía la ventana de datos** (14 → 29 → 44
días) y reintenta. Cada corrida se registra en `ml_pipeline/registry/training_history.json`:

```json
[{"iteration": 1, "window_days": 14, "dataset_size": 4368, "silhouette": 0.4195, ...}]
```

Ese historial es la evidencia de que **el modelo sigue aprendiendo y mejora con más datos**.
Para reentrenar sin volver a descargar clima: `--skip-ingest`.

## 5. Pruebas del resto del sistema

```bash
# API (12 pruebas)
$env:PYTHONPATH="$PWD\backend_fastapi"; $env:ENABLE_SUPABASE="false"
pytest backend_fastapi/tests -q

# Cliente
cd app_flutter; flutter analyze; flutter test; flutter build web --release
```

## 6. Evidencia en la nube

- GitHub → pestaña **Actions**: los 5 workflows en verde en cada push.
- El workflow **ML Training** aparece también con disparo `schedule` (reentrenamiento
  programado ejecutándose sin intervención humana).
- Artefactos descargables por corrida: modelo, metadata, `training_history.json`,
  perfiles de cluster y dataset.

> URL del video de la exposición: _[completar]_
