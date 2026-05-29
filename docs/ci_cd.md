# FrostPuno - CI/CD

## Objetivo

Automatizar controles de calidad para backend, datos y modelo ML sin depender de Supabase real ni secretos.

## Workflows

### `backend-tests.yml`

Se ejecuta en `push` y `pull_request`.

Valida:

- instalacion de dependencias de FastAPI;
- `PYTHONPATH` del backend;
- `ENABLE_SUPABASE=false`;
- pruebas de `backend_fastapi/tests`.

Este workflow asegura que los endpoints principales sigan funcionando aunque Supabase no este configurado.

### `data-validation.yml`

Se ejecuta en `push`, `pull_request` y manualmente con `workflow_dispatch`.

Flujo:

1. valida ubicaciones INEI-compatible;
2. descarga clima demo de Open-Meteo para tres ubicaciones;
3. construye features;
4. valida columnas, nulos criticos y rangos climaticos.

Se usa una ventana pequena para que GitHub Actions sea rapido y estable. Para produccion se ampliarian fechas y ubicaciones.

### `ml-training.yml`

Se ejecuta manualmente y semanalmente los lunes a las 09:00 UTC.

Flujo:

1. ingesta ubicaciones;
2. ingesta clima Open-Meteo;
3. features;
4. validacion;
5. entrenamiento de Logistic Regression, Decision Tree y Random Forest;
6. evaluacion;
7. subida de artefactos.

Artefactos:

- `frost_risk_model.joblib`;
- `model_metadata.json`;
- metricas comparativas;
- reporte de evaluacion;
- matriz de confusion;
- dataset procesado.

### `model-quality-gate.yml`

Evalua `ml_pipeline/registry/model_metadata.json`.

Regla MVP:

- `f1_macro >= MIN_F1_MACRO`;
- por defecto `MIN_F1_MACRO=0.70`.

Si el modelo no supera el umbral, el workflow falla y no debe promoverse.

## Referencias

GitHub Actions usa `workflow_dispatch` para ejecucion manual, `schedule` con cron UTC para jobs programados y `upload-artifact@v4` para guardar artefactos de entrenamiento.
