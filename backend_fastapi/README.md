# Frost Puno FastAPI Backend

Backend MVP que carga el modelo entrenado desde `ml_pipeline/registry` y expone:

- `GET /health`
- `GET /ml/model-info`
- `POST /predict/frost-risk`
- `GET /predictions/history`

## Ejecutar en Windows

Desde la raiz del proyecto:

```powershell
python -m venv .venv
.\.venv\Scripts\Activate.ps1
pip install -r .\backend_fastapi\requirements-dev.txt
pip install -r .\ml_pipeline\requirements.txt

$env:PYTHONPATH = "$PWD\backend_fastapi"
uvicorn app.main:app --reload --app-dir backend_fastapi
```

Luego abre:

- http://127.0.0.1:8000/docs
- http://127.0.0.1:8000/health
- http://127.0.0.1:8000/ml/model-info

## Pruebas

```powershell
$env:PYTHONPATH = "$PWD\backend_fastapi"
pytest .\backend_fastapi\tests
```

## Despliegue en Render Free

El archivo `render.yaml` de la raiz prepara un servicio web Python:

```bash
pip install --upgrade pip && pip install -r backend_fastapi/requirements.txt
uvicorn app.main:app --host 0.0.0.0 --port $PORT --app-dir backend_fastapi
```

Variables recomendadas en Render:

```env
ENABLE_SUPABASE=false
SUPABASE_URL=
SUPABASE_SERVICE_ROLE_KEY=
CORS_ORIGINS=https://TU-FRONTEND.vercel.app,http://localhost:3000,http://127.0.0.1:5174,http://localhost:5174
MODEL_PATH=ml_pipeline/registry/frost_risk_model.joblib
MODEL_METADATA_PATH=ml_pipeline/registry/model_metadata.json
```

Render debe verificar `GET /health`. En Free tier el servicio puede dormir por inactividad; la primera peticion despues de un periodo sin uso puede tardar.

## Supabase

La capa `repositories` guarda predicciones en Supabase solo si esta habilitada por variables de entorno. Si falta configuracion, usa `NoOpPredictionRepository` automaticamente y la prediccion se devuelve igual.

### Crear proyecto y tablas

1. Crea un proyecto en Supabase.
2. Abre `SQL Editor`.
3. Ejecuta `supabase/migrations/001_create_core_tables.sql`.
4. Ejecuta `supabase/policies/rls_policies.sql`.
5. Ejecuta `supabase/seed/seed_locations.sql`.

### Configurar `.env`

Crea `backend_fastapi/.env` con:

```env
SUPABASE_URL=https://your-project-ref.supabase.co
SUPABASE_SERVICE_ROLE_KEY=your-server-only-service-role-key
ENABLE_SUPABASE=true
CORS_ORIGINS=http://localhost:3000,http://127.0.0.1:5174,http://localhost:5174
```

El `service_role` se usa solo en FastAPI porque puede saltarse RLS. Nunca debe estar en Flutter, Flutter Web, variables publicas de Vercel ni repositorios.

### Probar insercion

Levanta el backend y ejecuta una prediccion desde Swagger:

- http://127.0.0.1:8000/docs

Luego consulta:

```sql
select id, district, risk_level, confidence, model_version, created_at
from public.frost_predictions
order by created_at desc
limit 10;
```

### Limitaciones free tier

- Guarda predicciones y agregados, no historicos horarios masivos.
- Mantener `data/raw` fuera de Supabase o resumido.
- Render Free puede dormir; la primera peticion puede tardar.
- Supabase Free sirve para demo/MVP, pero el volumen debe controlarse.
