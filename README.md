# Frost Puno

Sistema inteligente distribuido para prediccion de heladas y apoyo a la produccion de chuno en comunidades altoandinas de Puno mediante aprendizaje supervisado y datos abiertos.

## Arquitectura final MVP

- `ml_pipeline`: ingesta Open-Meteo, semilla territorial INEI-compatible, features, validacion, entrenamiento, evaluacion y registry.
- `backend_fastapi`: API modular con modelo ML, Pydantic, CORS, health check y persistencia Supabase opcional.
- `app_flutter`: Flutter Web/mobile con pantallas Home, consulta, resultado, historial, fuentes y modelo.
- `supabase`: SQL para PostgreSQL, RLS, seed y tablas del MVP.
- `.github/workflows`: CI/CD para backend, datos, ML, quality gate y Flutter Web.
- `docs`: documentacion academica, despliegue, ciclo ML y evidencias.

## Estado del proyecto

- Backend tests: `7 passed`.
- Flutter analyze: sin errores.
- Flutter test: pasando.
- Flutter build web: funcionando.
- Quality gate ML: aprobado.
- Capturas del informe: generadas localmente.
- Despliegue: preparado, pendiente de ejecucion manual en Render, Vercel y Supabase.

## Ejecucion local rapida

```powershell
Set-Location "D:\Dev\02_UNIVERSIDAD\FrostPuno"
python -m pip install -r .\ml_pipeline\requirements.txt
python -m pip install -r .\backend_fastapi\requirements-dev.txt

$env:PYTHONPATH = "$PWD\backend_fastapi"
$env:ENABLE_SUPABASE = "false"
pytest .\backend_fastapi\tests -q
python -m ml_pipeline.registry.check_model_quality --metadata .\ml_pipeline\registry\model_metadata.json --min-f1-macro 0.70
```

Levantar backend:

```powershell
$env:PYTHONPATH = "$PWD\backend_fastapi"
$env:ENABLE_SUPABASE = "false"
$env:CORS_ORIGINS = "http://localhost:3000,http://127.0.0.1:5174,http://localhost:5174"
uvicorn app.main:app --reload --app-dir backend_fastapi
```

Levantar Flutter Web:

```powershell
Set-Location .\app_flutter
flutter pub get
flutter run -d chrome --dart-define=API_BASE_URL=http://127.0.0.1:8000
```

## Builds

Backend, comando de produccion equivalente:

```bash
uvicorn app.main:app --host 0.0.0.0 --port $PORT --app-dir backend_fastapi
```

Flutter Web:

```powershell
Set-Location .\app_flutter
flutter build web --release --dart-define=API_BASE_URL=http://127.0.0.1:8000
```

## URLs esperadas

Local:

- Backend: `http://127.0.0.1:8000`
- Swagger: `http://127.0.0.1:8000/docs`
- Flutter Web: puerto asignado por Flutter o servidor estatico local.

Produccion esperada:

- Backend Render: `https://TU-BACKEND.onrender.com`
- Flutter Vercel: `https://TU-FRONTEND.vercel.app`
- Supabase: `https://TU-PROYECTO.supabase.co`

## CI/CD

Workflows principales:

- `backend-tests.yml`: valida FastAPI sin Supabase real.
- `data-validation.yml`: valida ubicaciones, clima demo y dataset.
- `ml-training.yml`: ejecuta entrenamiento/evaluacion y guarda artefactos.
- `model-quality-gate.yml`: bloquea modelos bajo el umbral de `f1_macro`.
- `flutter-build.yml`: analiza, prueba y compila Flutter Web.

## Despliegue gratuito

Archivos preparados:

- `render.yaml`: Render Free para FastAPI.
- `app_flutter/vercel.json`: Vercel Hobby para Flutter Web.
- `supabase/`: migraciones, RLS y seed.
- `docs/deployment.md`: guia paso a paso.

## Defensa academica

Para Aprendizaje de Maquina:

- Dataset inicial reproducible.
- Comparacion de modelos supervisados.
- Metrica principal `f1-score macro`.
- Registry, metadata y quality gate.
- Limitaciones explicitas por etiquetas basadas en reglas.

Para Computacion Paralela y Distribuida:

- Ingesta climatica paralela por distritos/centros poblados.
- Backend modular con separacion de responsabilidades.
- Jobs independientes en CI/CD.
- Estrategia de escalabilidad hacia microservicios.

## Seguridad

No se suben credenciales. `SUPABASE_SERVICE_ROLE_KEY` debe existir solo en Render/backend. Flutter Web y Vercel solo reciben `API_BASE_URL`.
