# FrostPuno Flutter App

Cliente Flutter mobile/web inspirado en el diseño Stitch `stitch_frost_puno_predictor`.

Incluye GPS mediante `geolocator`, permisos Android, clima automatico desde FastAPI, dark/light mode, PWA basica y preparacion para APK Android.

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

## Flujo de consulta movil

La pantalla de consulta evita inputs climaticos manuales. El usuario ve tarjetas grandes y trabaja con tres acciones:

- `Usar mi ubicacion`: solicita permiso, obtiene GPS y consulta automaticamente `GET /weather/current`.
- `Obtener clima`: refresca el clima para la ubicacion actual; si GPS falla, usa Puno demo como fallback manual.
- `Predecir`: envia al backend ubicacion, clima interno y contexto agricola del modelo.

La pantalla muestra ubicacion detectada, precision aproximada, temperatura, humedad, viento, nubosidad, proveedor climatico y estacion cuando el backend la devuelve.

El resultado muestra riesgo ALTO/MEDIO/BAJO con color, icono, confianza y recomendacion breve. El historial usa cards con distrito, riesgo, fecha y confianza.

## GPS y permisos

En Flutter Web, GPS requiere HTTPS. En Android, revisar `docs/mobile_build.md`.

Para probar en emulador Android con FastAPI local:

```powershell
flutter run -d emulator --dart-define=API_BASE_URL=http://10.0.2.2:8000
```

Para probar en telefono fisico, usa una API accesible desde la red del telefono:

```powershell
flutter run -d android --dart-define=API_BASE_URL=https://TU-BACKEND.onrender.com
```

## Generar APK

```powershell
flutter pub get
flutter build apk --release --dart-define=API_BASE_URL=https://TU-BACKEND.onrender.com
```

El APK queda en `build\app\outputs\flutter-apk\app-release.apk`.
