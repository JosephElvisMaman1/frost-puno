# FrostPuno - automatizacion de capturas

Estos scripts generan evidencias visuales locales para el informe academico de FrostPuno. No modifican la logica del backend, Flutter, ML ni Supabase.

## Requisitos

- Node.js y npm disponibles en PowerShell.
- Dependencias locales instaladas en `tools/screenshots`.
- Backend FastAPI levantado en `http://127.0.0.1:8000`.
- Flutter Web levantado en una URL local estable. Se recomienda `http://127.0.0.1:5174`.

## Preparar dependencias

```powershell
Set-Location tools\screenshots
npm install
npx playwright install chromium
Set-Location ..\..
```

## Levantar backend

En una terminal:

```powershell
$env:ENABLE_SUPABASE = "false"
$env:PYTHONPATH = "$PWD\backend_fastapi"
uvicorn app.main:app --reload --app-dir backend_fastapi
```

URL esperada:

```text
http://127.0.0.1:8000
```

## Levantar Flutter Web

En otra terminal:

```powershell
Set-Location app_flutter
flutter run -d chrome --web-port 5174 --dart-define=API_BASE_URL=http://127.0.0.1:8000
```

URL esperada:

```text
http://127.0.0.1:5174
```

Si usas otro puerto, define:

```powershell
$env:FLUTTER_WEB_URL = "http://127.0.0.1:PUERTO"
```

## Ejecutar todo

Desde la raiz del proyecto:

```powershell
.\tools\screenshots\run_all_screenshots.ps1
```

## Scripts individuales

```powershell
.\tools\screenshots\generate_project_tree.ps1
.\tools\screenshots\generate_terminal_evidence.ps1

Set-Location tools\screenshots
npm run capture:api
npm run capture:flutter
npm run capture:static
npm run capture:deploy
npm run checklist
Set-Location ..\..
```

## Capturas generadas automaticamente

- `docs/capturas/01_estructura_proyecto.png`
- `docs/capturas/02_dataset_generado.png`
- `docs/capturas/03_model_metadata.png`
- `docs/capturas/04_quality_gate.png`
- `docs/capturas/05_fastapi_swagger.png`
- `docs/capturas/06_endpoint_health.png`
- `docs/capturas/07_endpoint_model_info.png`
- `docs/capturas/08_endpoint_predict.png`
- `docs/capturas/09_tests_backend.png`
- `docs/capturas/10_flutter_home.png`
- `docs/capturas/11_flutter_formulario.png`
- `docs/capturas/12_flutter_resultado.png`
- `docs/capturas/13_flutter_historial.png`
- `docs/capturas/14_flutter_fuentes_datos.png`
- `docs/capturas/15_flutter_model_info.png`
- `docs/capturas/16_flutter_analyze_test.png`
- `docs/capturas/17_flutter_build_web.png`
- `docs/capturas/18_github_workflows.png`
- `docs/capturas/19_supabase_sql.png`
- `docs/capturas/20_dataset_v2_sin_leakage.png`
- `docs/capturas/21_model_metadata_v0_2_0.png`
- `docs/capturas/22_comparacion_modelos.png`
- `docs/capturas/23_despliegue_render_vercel_supabase.png`
- `docs/capturas/24_android_apk_mobile.png`
- `docs/capturas/25_github_repo.png`
- `docs/capturas/26_github_branch_v0_2_0.png`
- `docs/capturas/27_github_commits_v0_2_0.png`
- `docs/capturas/28_github_actions.png`
- `docs/capturas/29_render_health.png`
- `docs/capturas/30_render_model_info.png`
- `docs/capturas/31_render_swagger.png`
- `docs/capturas/32_vercel_flutter_mobile.png`
- `docs/capturas/33_vercel_flutter_desktop.png`
- `docs/capturas/34_despliegue_headers.png`
- `docs/capturas/35_ramas_y_versiones.png`
- `docs/capturas/36_supabase_estado.png`
- `docs/capturas/37_vercel_estado.png`

## Datos auxiliares generados

- `docs/capturas_data/project_tree.txt`
- `docs/capturas_data/predict_response.json`
- `docs/capturas_data/backend_tests_output.txt`
- `docs/capturas_data/flutter_analyze_output.txt`
- `docs/capturas_data/flutter_test_output.txt`
- `docs/capturas_data/flutter_build_output.txt`
- `docs/capturas_data/quality_gate_output.txt`

## Capturas que pueden requerir intervencion manual

- Pantallas Flutter si el render web no expone texto accesible para Playwright.
- Resultado de prediccion si el backend no esta activo cuando se captura Flutter.
- Swagger y endpoints si FastAPI no esta corriendo.

En esos casos, el script deja mensajes claros y el checklist marca la captura como pendiente.
