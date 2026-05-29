# Frost Puno Flutter App

Cliente Flutter mobile/web inspirado en el diseño Stitch `stitch_frost_puno_predictor`.

## Ejecutar web local

Primero levanta FastAPI:

```powershell
Set-Location "D:\Dev\02_UNIVERSIDAD\FrostPuno"
$env:PYTHONPATH = "D:\Dev\02_UNIVERSIDAD\FrostPuno\backend_fastapi"
uvicorn app.main:app --reload --app-dir backend_fastapi
```

Luego ejecuta Flutter Web:

```powershell
Set-Location "D:\Dev\02_UNIVERSIDAD\FrostPuno\app_flutter"
flutter pub get
flutter run -d chrome --dart-define=API_BASE_URL=http://127.0.0.1:8000
```

Para servir build estatico:

```powershell
flutter build web --dart-define=API_BASE_URL=http://127.0.0.1:8000
python -m http.server 5174 --bind 127.0.0.1 --directory build\web
```

## Vercel Hobby

El proyecto incluye `app_flutter/vercel.json`. Al importar en Vercel, configura:

- **Root Directory:** `app_flutter`
- **Build Command:** `flutter build web --release --dart-define=API_BASE_URL=$API_BASE_URL`
- **Output Directory:** `build/web`
- **Environment Variable:** `API_BASE_URL=https://TU-BACKEND.onrender.com`

El `vercel.json` instala Flutter estable durante el build porque Vercel no trae Flutter preinstalado. El primer build puede tardar mas que una app JavaScript simple.

## Android emulator

Usa `10.0.2.2` para hablar con FastAPI del host:

```powershell
flutter run -d emulator --dart-define=API_BASE_URL=http://10.0.2.2:8000
```

Flutter nunca usa credenciales de Supabase. Toda persistencia pasa por FastAPI.
