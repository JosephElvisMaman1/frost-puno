# FrostPuno - build movil y PWA

Esta guia prepara FrostPuno para Android APK, App Bundle y PWA sin introducir claves privadas ni firmar releases definitivos.

## Requisitos locales

- Flutter estable instalado.
- Android SDK configurado.
- Un dispositivo Android o emulador.
- Backend local o desplegado en Render.

Verificacion:

```powershell
flutter doctor -v
```

Si aparece `Unable to locate Android SDK`, instalar Android Studio o configurar:

```powershell
flutter config --android-sdk "C:\Ruta\Al\Android\Sdk"
$env:ANDROID_HOME = "C:\Ruta\Al\Android\Sdk"
```

## Permisos Android

El `AndroidManifest.xml` declara `INTERNET`, `ACCESS_COARSE_LOCATION` y `ACCESS_FINE_LOCATION`.

La app solicita permiso de ubicacion en tiempo de ejecucion mediante `permission_handler` y obtiene coordenadas con `geolocator`.

## Ejecutar en Android

```powershell
Set-Location app_flutter
flutter run -d emulator --dart-define=API_BASE_URL=http://10.0.2.2:8000
```

Para dispositivo fisico con backend desplegado:

```powershell
flutter run -d android --dart-define=API_BASE_URL=https://TU-BACKEND.onrender.com
```

## Generar APK

```powershell
Set-Location app_flutter
flutter build apk --release --dart-define=API_BASE_URL=https://TU-BACKEND.onrender.com
```

Salida esperada:

```text
app_flutter/build/app/outputs/flutter-apk/app-release.apk
```

## Generar App Bundle

```powershell
flutter build appbundle --release --dart-define=API_BASE_URL=https://TU-BACKEND.onrender.com
```

## Probar GPS

1. Abrir FrostPuno en Android o Flutter Web HTTPS.
2. Ir a `Consultar riesgo`.
3. Tocar `Usar mi ubicacion`.
4. Aceptar permiso de ubicacion.
5. Confirmar que latitud/longitud cambien.
6. Confirmar que el bloque de clima indique proveedor y fallback.
7. Ejecutar prediccion.

## PWA

El proyecto incluye `web/manifest.json`, `web/offline.html` y service worker generado por Flutter durante `flutter build web`.

```powershell
flutter build web --release --dart-define=API_BASE_URL=https://TU-BACKEND.onrender.com
```

## Limitaciones actuales

- No hay modo offline-first complejo; clima y predicciones requieren red.
- El APK no esta firmado para Play Store.
- GPS en navegador requiere HTTPS y permiso del usuario.
- SENAMHI esta preparado como proveedor prioritario, pero el MVP usa Open-Meteo como fallback cuando no hay API publica estable configurada.
