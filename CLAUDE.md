# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What this is

FrostPuno: sistema de predicción de heladas y apoyo a la producción de chuño en el altiplano de Puno, Perú. Proyecto universitario desplegado en producción (Render + Vercel + Supabase) con CI/CD. Tres subsistemas + datos compartidos:

- `ml_pipeline/` — pipeline Python de ML: ingesta → features → entrenamiento → registry (`.joblib` + metadata JSON) → evaluación.
- `backend_fastapi/` — API FastAPI que sirve el modelo del registry y los proveedores de clima.
- `app_flutter/` — cliente Flutter Web/Android que consume el backend.
- `data/` — datasets versionados (`external/` semilla INEI, `processed/`, `raw/`, `validation/`).
- `supabase/` — migraciones SQL + RLS para persistencia opcional.
- `.github/workflows/` — 5 pipelines de IC.

## Migración de modelo en curso (LEER ANTES DE TOCAR ML)

El curso exige **aprendizaje NO SUPERVISADO (K-Means clustering)**. El repo nació con **clasificación supervisada** (`ml_pipeline/training/train_models.py`, target `riesgo_helada`, métrica `f1_macro`, modelos `v0.1.0`/`v0.2.0` en `registry/`). Se está migrando a K-Means:

- El artefacto productivo pasa a ser un modelo de **clustering** (`registry/frost_cluster_model.joblib` + `cluster_metadata.json`), evaluado con **silhouette / Davies-Bouldin**, no `f1_macro`.
- Los scripts supervisados quedan como **legacy documentado** (no borrar: se citan en el informe como "modelo previo migrado"), pero no forman parte del path productivo ni de la IC.
- Al añadir ML nuevo, usar el módulo de clustering, no reintroducir `train_models.py` en producción.

## Comandos

Ejecutar todo desde la raíz del repo. Windows/PowerShell.

```powershell
# Instalar deps
python -m pip install -r ml_pipeline/requirements.txt
python -m pip install -r backend_fastapi/requirements-dev.txt

# Backend: tests (Supabase desactivado — obligatorio para tests)
$env:PYTHONPATH = "$PWD\backend_fastapi"; $env:ENABLE_SUPABASE = "false"
pytest backend_fastapi/tests -q

# Un solo test
pytest backend_fastapi/tests/test_api.py::<nombre_del_test> -q

# ML: entrenar clustering (path nuevo)
python -m ml_pipeline.clustering.train_clusters
# Quality gate no supervisado
python -m ml_pipeline.registry.check_cluster_quality --metadata ml_pipeline/registry/cluster_metadata.json --min-silhouette 0.35

# Levantar backend
$env:PYTHONPATH = "$PWD\backend_fastapi"; $env:ENABLE_SUPABASE = "false"
uvicorn app.main:app --reload --app-dir backend_fastapi   # http://127.0.0.1:8000/docs
```

```powershell
# Flutter (desde app_flutter/)
flutter pub get
flutter analyze
flutter test
flutter run -d chrome --dart-define=API_BASE_URL=http://127.0.0.1:8000
flutter build web --release --dart-define=API_BASE_URL=<backend_url>
flutter build apk --release --dart-define=API_BASE_URL=https://frost-puno.onrender.com
# Emulador Android contra backend local: API_BASE_URL=http://10.0.2.2:8000
```

## Arquitectura

**Flujo ML → producción.** `ml_pipeline/config.py` es la fuente única de rutas, listas de features y constantes; todo script las importa (no hardcodear rutas). El entrenamiento serializa a `ml_pipeline/registry/` (modelo `.joblib` + metadata JSON con features, métricas, versión, limitaciones). El backend carga *ese mismo* artefacto vía `ModelRegistry` (`backend_fastapi/app/services/model_registry.py`), que lee las rutas desde `settings` (`app/core/config.py`, sobreescribibles por env `MODEL_PATH`/`MODEL_METADATA_PATH`). **El contrato entre ML y backend es la lista de features en el metadata**: `prediction_service.py` arma el `DataFrame` en ese orden exacto. Si cambias features en el pipeline, se rompe la inferencia hasta reentrenar y actualizar el metadata.

**Backend (FastAPI modular).** `app/main.py` (`create_app`) monta routers (`health`, `ml`, `predict`, `predictions`, `weather`) + CORS (orígenes por env `CORS_ORIGINS`) + handlers de `ModelLoadError`→503 y `PredictionError`→422. Capas: `api/routes/` (HTTP) → `services/` (lógica) → `repositories/` (persistencia) → `schemas/` (Pydantic). Todos los singletons usan `@lru_cache(maxsize=1)` (registry, prediction service, weather provider) — al testear con estado distinto, limpiar la caché.

**Clima.** `services/weather_providers.py` → `HybridWeatherProvider` intenta SENAMHI primero y cae a Open-Meteo. **SENAMHI es un stub conceptual** (`SenamhiProvider.get_current_weather` siempre retorna `None`: no hay API pública estable); Open-Meteo es la fuente operativa real. La respuesta expone `source_priority` y `fallback_used` para que la app muestre la degradación. Hay caché en memoria por (lat,lon) con TTL. Bounding box de Puno validado en la ruta (`lat -18.5..-13.0`, `lon -71.5..-68.0`).

**Persistencia.** Supabase es **opcional**: `ENABLE_SUPABASE=false` usa repositorio en memoria; `true` requiere `SUPABASE_URL` + `SUPABASE_SERVICE_ROLE_KEY` (solo en el backend, nunca en Flutter). El service-role key nunca se commitea.

**Flutter (feature-first).** `lib/main.dart` → `app.dart` → `features/shell/app_shell.dart` (NavigationBar por tabs). Cada feature bajo `lib/features/<x>/{screens,models,services}`. Toda llamada HTTP pasa por `lib/core/api/frost_api_service.dart` (sobre `api_client.dart`); los modelos usan `fromJson`. `API_BASE_URL` se inyecta por `--dart-define` (ver `core/config/app_config.dart`), no se hardcodea. Widgets compartidos reutilizables en `lib/shared/widgets/` (`glass_card`, `section_header`, `status_chip`, `page_scaffold`). Tema con `ThemeMode.system` vía `core/theme/theme_mode_scope.dart`.

## Despliegue e IC

- Backend: `render.yaml` (Render Free, `frost-puno.onrender.com`). `render.v2.yaml` es un servicio separado experimental. `startCommand`: `uvicorn app.main:app --host 0.0.0.0 --port $PORT --app-dir backend_fastapi`.
- Flutter Web: `app_flutter/vercel.json` (Vercel, `frost-puno.vercel.app`).
- Workflows: `ml-training` (entrena), `model-quality-gate` (bloquea modelos bajo umbral — migrando de `f1_macro` a silhouette), `backend-tests` (FastAPI sin Supabase), `data-validation` (datasets/ubicaciones), `flutter-build` (analyze+test+build web).

## Convenciones

- Config y rutas centralizadas: `ml_pipeline/config.py` (ML), `app/core/config.py` (backend), `--dart-define` (Flutter). No duplicar constantes.
- Excepciones del backend se convierten a errores API estables (`app/core/exceptions.py`); no filtrar internals del modelo al cliente.
- Datos de dominio de chuño (temporada, umbrales de congelamiento/secado) están en `docs/chuno_criteria.md` con fuentes — reusar esos números, no inventar.
- Los datasets en `data/` están versionados en git y se validan en IC; cambiarlos exige pasar `data-validation`.
