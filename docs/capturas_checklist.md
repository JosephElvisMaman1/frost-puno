# Checklist de capturas - Frost Puno

Este documento se actualiza con `node tools/screenshots/update_checklist.js` o desde `tools/screenshots/run_all_screenshots.ps1`.

## Estado de capturas

| Nro. | Captura | Archivo | Modo | Estado |
|---|---|---|---|---|
| 01 | Estructura del proyecto | `docs/capturas/01_estructura_proyecto.png` | Automatica | Generada |
| 02 | Dataset generado | `docs/capturas/02_dataset_generado.png` | Automatica | Generada |
| 03 | Model metadata | `docs/capturas/03_model_metadata.png` | Automatica | Generada |
| 04 | Quality gate aprobado | `docs/capturas/04_quality_gate.png` | Automatica | Generada |
| 05 | FastAPI Swagger | `docs/capturas/05_fastapi_swagger.png` | Automatica con backend activo | Generada |
| 06 | Endpoint health | `docs/capturas/06_endpoint_health.png` | Automatica con backend activo | Generada |
| 07 | Endpoint model-info | `docs/capturas/07_endpoint_model_info.png` | Automatica con backend activo | Generada |
| 08 | Endpoint predict | `docs/capturas/08_endpoint_predict.png` | Automatica con backend activo | Generada |
| 09 | Tests backend | `docs/capturas/09_tests_backend.png` | Automatica | Generada |
| 10 | Flutter Home | `docs/capturas/10_flutter_home.png` | Automatica con Flutter Web activo | Generada |
| 11 | Formulario Flutter | `docs/capturas/11_flutter_formulario.png` | Automatica con Flutter Web activo | Generada |
| 12 | Resultado de prediccion | `docs/capturas/12_flutter_resultado.png` | Automatica con Flutter Web y backend activos | Generada |
| 13 | Historial | `docs/capturas/13_flutter_historial.png` | Automatica con Flutter Web activo | Generada |
| 14 | Fuentes de datos | `docs/capturas/14_flutter_fuentes_datos.png` | Automatica con Flutter Web activo | Generada |
| 15 | Flutter ModelInfo | `docs/capturas/15_flutter_model_info.png` | Automatica con Flutter Web activo | Generada |
| 16 | Flutter analyze y test | `docs/capturas/16_flutter_analyze_test.png` | Automatica | Generada |
| 17 | Flutter build web | `docs/capturas/17_flutter_build_web.png` | Automatica | Generada |
| 18 | GitHub workflows | `docs/capturas/18_github_workflows.png` | Automatica | Generada |
| 19 | Supabase SQL | `docs/capturas/19_supabase_sql.png` | Automatica | Generada |

## Comandos principales

```powershell
Set-Location tools\screenshots
npm install
npx playwright install chromium
Set-Location ..\..
.\tools\screenshots\run_all_screenshots.ps1
```

## Requisitos de servidores locales

- Backend FastAPI: `http://127.0.0.1:8000`.
- Flutter Web: usar `FLUTTER_WEB_URL`, recomendado `http://127.0.0.1:5174`.
- No se usan credenciales reales ni servicios desplegados.

## Capturas manuales posibles

- Si Flutter Web usa CanvasKit sin semantica accesible y Playwright no puede hacer clic por texto, capturar manualmente las pantallas indicadas.
- Si Swagger o endpoints no estan disponibles, levantar FastAPI y repetir `npm run capture:api`.
- Si un comando de terminal falla por dependencias locales, revisar el archivo `.txt` correspondiente en `docs/capturas_data/`.

