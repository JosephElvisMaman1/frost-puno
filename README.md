# FrostPuno

Sistema inteligente distribuido para prediccion de heladas y apoyo a la produccion de chuno en comunidades altoandinas de Puno mediante aprendizaje supervisado y datos abiertos.

## Arquitectura final MVP

- `ml_pipeline`: ingesta Open-Meteo, semilla territorial INEI-compatible, features, validacion, entrenamiento, evaluacion y registry.
- `backend_fastapi`: API modular con modelo ML, Pydantic, CORS, health check y persistencia Supabase opcional.
- `app_flutter`: Flutter Web/mobile con pantallas Home, consulta, resultado, historial, fuentes y modelo.
- `backend_fastapi/app/services/weather_providers.py`: proveedores climaticos SENAMHI/Open-Meteo con fallback.
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
- Despliegue: backend Render disponible en `https://frost-puno.onrender.com`; Vercel y Supabase documentados para ejecucion manual.
- Movil: flujo GPS + clima automatico, modo oscuro, permisos Android, PWA y build APK preparados.
- ML v0.2.0: version experimental sin data leakage, con split por distrito y evaluacion realista.

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

Android APK:

```powershell
Set-Location .\app_flutter
flutter build apk --release --dart-define=API_BASE_URL=https://frost-puno.onrender.com
```

## Flujo movil actual

La app ya no funciona como formulario tecnico. En `Consulta de riesgo` el usuario trabaja con tres acciones:

- `Usar mi ubicacion`: solicita permiso GPS, obtiene latitud/longitud y consulta automaticamente `GET /weather/current`.
- `Obtener clima`: vuelve a consultar el clima para la ubicacion actual; si no hay GPS, usa Puno demo como fallback manual.
- `Predecir`: envia al backend la ubicacion, variables climaticas internas y contexto agricola requerido por el modelo.

La UI muestra una tarjeta de ubicacion, una tarjeta de clima actual y una pantalla de resultado con riesgo grande, confianza, icono, color por nivel y recomendacion breve. El historial se presenta como cards con distrito, riesgo, fecha y confianza.

El tema usa `ThemeMode.system` y permite alternar entre sistema, claro y oscuro desde la app.

Para probar en Android local con FastAPI en la misma maquina:

```powershell
Set-Location .\app_flutter
flutter run -d emulator --dart-define=API_BASE_URL=http://10.0.2.2:8000
```

En un telefono fisico, usa una URL accesible desde el dispositivo, por ejemplo el backend desplegado en Render:

```powershell
flutter run -d android --dart-define=API_BASE_URL=https://frost-puno.onrender.com
```

## URLs esperadas

Local:

- Backend: `http://127.0.0.1:8000`
- Swagger: `http://127.0.0.1:8000/docs`
- Flutter Web: puerto asignado por Flutter o servidor estatico local.

Produccion esperada:

- Backend Render: `https://frost-puno.onrender.com`
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
- Modelo productivo `v0.1.0` intacto en FastAPI.
- Modelo experimental `v0.2.0` en `ml_pipeline/registry/`, sin reemplazar produccion.
- Dataset `data/processed/frost_training_dataset_v2.csv` sin `temperatura_minima_diaria` ni `horas_bajo_cero` como features.
- Comparacion formal en `docs/model_comparison_v1_vs_v2.md`.

Para Computacion Paralela y Distribuida:

- Ingesta climatica paralela por distritos/centros poblados.
- Backend modular con separacion de responsabilidades.
- Jobs independientes en CI/CD.
- Estrategia de escalabilidad hacia microservicios.

## Evolucion movil

- GPS mediante `geolocator` y permisos Android.
- Fallback manual si el permiso se deniega.
- Clima actual mediante `GET /weather/current`.
- SENAMHI preparado como proveedor oficial prioritario.
- Open-Meteo como fallback operativo.
- PWA con manifest FrostPuno y fallback offline basico.
- UX movil simplificada sin inputs climaticos manuales.
- Dark/light mode con `ThemeMode.system`.

## Seguridad

No se suben credenciales. `SUPABASE_SERVICE_ROLE_KEY` debe existir solo en Render/backend. Flutter Web y Vercel solo reciben `API_BASE_URL`.

## Informe y capturas

- Informe Markdown completo: `docs/informe_frost_puno.md`.
- Informe Word generado: `docs/informe_frost_puno_completo.docx`.
- Checklist de capturas: `docs/capturas_checklist.md`.
- Capturas: `docs/capturas/01_estructura_proyecto.png` hasta `docs/capturas/24_android_apk_mobile.png`.
