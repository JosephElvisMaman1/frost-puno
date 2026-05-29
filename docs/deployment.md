# FrostPuno - guia de despliegue gratuito

Esta guia prepara el despliegue manual end-to-end del MVP:

- Backend FastAPI en Render Free.
- Flutter Web en Vercel Hobby.
- Base de datos en Supabase Free.
- CI/CD con GitHub Actions.

No se incluyen credenciales reales. El despliegue productivo debe configurarse desde GitHub, Render, Vercel y Supabase.

## 1. Supabase Free

### Crear proyecto

1. Entra al dashboard de Supabase.
2. Crea un proyecto nuevo, por ejemplo `frost-puno`.
3. Espera a que la base PostgreSQL quede lista.
4. Abre `SQL Editor`.

### Ejecutar SQL

Ejecuta en este orden:

1. `supabase/migrations/001_create_core_tables.sql`
2. `supabase/policies/rls_policies.sql`
3. `supabase/seed/seed_locations.sql`

### Copiar credenciales

En `Project Settings > API` copia:

- `Project URL`: se usara como `SUPABASE_URL`.
- `service_role key`: se usara solo en Render como `SUPABASE_SERVICE_ROLE_KEY`.

Nunca colocar `SUPABASE_SERVICE_ROLE_KEY` en Flutter, Vercel, `dart-define`, JavaScript publico ni archivos versionados.

## 2. Render Free - FastAPI

### Estado actual verificado

- Backend productivo: `https://frost-puno.onrender.com`
- Endpoint de salud: `https://frost-puno.onrender.com/health`
- Documentacion Swagger: `https://frost-puno.onrender.com/docs`
- Modelo activo: `v0.1.0`
- Rama productiva usada por Render: `main`

La rama `codex/model-v0-2-0` contiene la evaluacion academica `v0.2.0`, pero no reemplaza el modelo activo del backend productivo.

### Opcion A: Blueprint v0.1.0 productivo

El repositorio incluye `render.yaml`. En Render:

1. Crea un nuevo Blueprint desde el repositorio de GitHub.
2. Render detectara `render.yaml`.
3. Revisa el servicio `frost-puno-api`.
4. Configura las variables faltantes.
5. Despliega.

### Opcion B: Blueprint v0.2.0 experimental

El repositorio incluye `render.v2.yaml` para levantar un servicio separado:

- **Nombre sugerido:** `frost-puno-api-v2`
- **Rama sugerida:** `codex/model-v0-2-0`
- **Modelo:** `ml_pipeline/registry/frost_risk_model_v0_2_0.joblib`
- **Metadata:** `ml_pipeline/registry/model_metadata_v0_2_0.json`
- **AutoDeploy:** desactivado para evitar promover cambios experimentales sin revision.

Esta opcion permite exponer `v0.2.0` como endpoint academico sin romper el backend actual. La URL esperada, una vez creado el servicio en Render, seria similar a:

```text
https://frost-puno-api-v2.onrender.com
```

### Opcion C: Web Service manual

Configuracion recomendada:

- **Environment:** Python
- **Root Directory:** raiz del repositorio
- **Build Command:**

```bash
pip install --upgrade pip && pip install -r backend_fastapi/requirements.txt
```

- **Start Command:**

```bash
uvicorn app.main:app --host 0.0.0.0 --port $PORT --app-dir backend_fastapi
```

- **Health Check Path:** `/health`

### Variables de entorno Render

```env
PYTHON_VERSION=3.11.9
ENABLE_SUPABASE=false
SUPABASE_URL=https://TU-PROYECTO.supabase.co
SUPABASE_SERVICE_ROLE_KEY=TU_SERVICE_ROLE_SOLO_BACKEND
CORS_ORIGINS=https://TU-FRONTEND.vercel.app,http://localhost:3000,http://127.0.0.1:5174,http://localhost:5174
MODEL_PATH=ml_pipeline/registry/frost_risk_model.joblib
MODEL_METADATA_PATH=ml_pipeline/registry/model_metadata.json
```

Para el servicio experimental `v0.2.0`, cambiar solo:

```env
MODEL_PATH=ml_pipeline/registry/frost_risk_model_v0_2_0.joblib
MODEL_METADATA_PATH=ml_pipeline/registry/model_metadata_v0_2_0.json
```

Para probar primero sin base de datos, deja `ENABLE_SUPABASE=false`. Cuando Supabase este listo y verificado, cambia a `ENABLE_SUPABASE=true`.

### Pruebas Render

```text
https://frost-puno.onrender.com/health
https://frost-puno.onrender.com/ml/model-info
https://frost-puno.onrender.com/docs
```

Render Free puede dormir tras inactividad; la primera peticion puede tardar mientras despierta el servicio.

## 3. Vercel Hobby - Flutter Web

El frontend publico esta disponible en:

```text
https://frost-puno.vercel.app
```

El frontend se despliega desde `app_flutter`.

### Configuracion en Vercel

- **Framework Preset:** Other
- **Root Directory:** `app_flutter`
- **Install Command:** usar el de `app_flutter/vercel.json`
- **Build Command:** usar el de `app_flutter/vercel.json`
- **Output Directory:** `build/web`

Variable de entorno:

```env
API_BASE_URL=https://frost-puno.onrender.com
```

El build command efectivo es:

```bash
flutter build web --release --dart-define=API_BASE_URL=$API_BASE_URL
```

El archivo `vercel.json` instala Flutter estable durante el build. En Hobby, el build puede tardar mas que un sitio estatico comun.

## PWA y GPS

FrostPuno Web requiere HTTPS para que el navegador permita geolocalizacion. Vercel entrega HTTPS por defecto, por lo que el boton `Usar mi ubicacion` funciona siempre que el usuario otorgue permisos.

Si el navegador bloquea GPS, revisar permisos del sitio, probar en Chrome/Edge movil o usar fallback manual con coordenadas y distrito.

## 4. GitHub Actions

Workflows incluidos:

- `backend-tests.yml`: pruebas del backend sin Supabase real.
- `data-validation.yml`: validacion de datos y construccion de dataset demo.
- `ml-training.yml`: entrenamiento/evaluacion manual o semanal.
- `model-quality-gate.yml`: validacion de `f1_macro`.
- `flutter-build.yml`: `flutter pub get`, `flutter analyze`, `flutter test` y `flutter build web`.

Estos workflows no requieren credenciales reales para ejecutarse en CI.

## 5. Prueba end-to-end

1. Abrir `https://TU-BACKEND.onrender.com/health`.
2. Confirmar `status = ok` y `model_available = true`.
3. Abrir `https://frost-puno.vercel.app`.
4. Verificar que la pantalla principal muestre el estado del sistema.
5. Ir a consulta de riesgo.
6. Enviar los valores demo.
7. Confirmar respuesta de riesgo, confianza, recomendacion y version del modelo.
8. Revisar `/predictions/history`.
9. Si `ENABLE_SUPABASE=true`, revisar en Supabase la tabla `frost_predictions`.

## 6. Errores comunes

- **CORS bloquea Flutter:** agregar el dominio Vercel exacto en `CORS_ORIGINS` de Render y redeploy.
- **Render muestra `model_available=false`:** verificar `MODEL_PATH`, `MODEL_METADATA_PATH` y que los archivos del registry esten versionados.
- **Primera peticion lenta:** comportamiento normal de Render Free tras inactividad.
- **Flutter llama a localhost en produccion:** revisar `API_BASE_URL` en Vercel y redeploy.
- **No se guardan predicciones:** confirmar `ENABLE_SUPABASE=true`, `SUPABASE_URL`, `SUPABASE_SERVICE_ROLE_KEY` y tablas creadas.
- **Error RLS:** recordar que el backend usa service role; las lecturas por usuario requieren autenticacion futura.

## 7. Limitaciones free tier

- Render Free puede dormir y tener arranque frio.
- Vercel Hobby es adecuado para demo academica, pero tiene limites de uso y build.
- Supabase Free debe usarse con volumen controlado; no guardar historicos horarios masivos sin agregacion.
- El MVP no reemplaza alertas oficiales de SENAMHI ni validacion de campo.

## 8. Checklist final

- [ ] Repositorio subido a GitHub.
- [ ] Workflows de GitHub Actions en verde.
- [ ] Supabase creado.
- [ ] Migraciones ejecutadas.
- [ ] RLS y seed ejecutados.
- [ ] Render creado y `GET /health` funcionando.
- [ ] `CORS_ORIGINS` contiene dominio de Vercel.
- [ ] Vercel creado con root `app_flutter`.
- [ ] `API_BASE_URL` en Vercel apunta a Render.
- [ ] Flutter Web consulta y muestra prediccion.
- [ ] Si Supabase esta activo, `frost_predictions` recibe registros.

## 9. Evidencias capturadas

Las capturas remotas del despliegue se encuentran en:

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

Los conectores privados de GitHub, Vercel y Supabase devolvieron `token_expired` durante la captura automatica. Por ello, las capturas de dashboard privado deben repetirse tras reautenticar conectores o desde la sesion web del navegador.
