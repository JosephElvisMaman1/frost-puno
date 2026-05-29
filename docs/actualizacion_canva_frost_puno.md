# Actualizacion sugerida para diapositivas Canva - FrostPuno

Estado de acceso: los conectores de Canva devolvieron `token_expired` el 2026-05-29, por lo que no fue posible guardar cambios directamente en la presentacion desde Codex. Este documento deja el contenido exacto para actualizar el deck compartido: https://www.canva.com/design/DAHLEUKRGqM/G71sleBFxoYo_KXrC6fzsQ/edit

## Enfoque narrativo actualizado

La exposicion ya no debe presentar FrostPuno solo como un formulario tecnico. El mensaje actualizado es:

> FrostPuno evoluciono hacia una app movil usable, con GPS, clima automatico, historial, despliegue real y un ciclo de mejora supervisada del modelo. La version productiva se mantiene estable, mientras la version experimental v0.2.0 elimina data leakage y reporta metricas mas realistas.

## Cambios que deben reflejarse en el deck

- App movil mejorada: menos inputs, botones principales, clima automatico y resultado visual.
- GPS completo: permisos, lat/lng, ubicacion detectada y fallback manual.
- Dark mode: ThemeMode.system y toggle claro/oscuro.
- Backend intacto: FastAPI sigue usando v0.1.0 en produccion.
- ML v0.2.0: version experimental con dataset v2, sin leakage y split por distrito.
- Supabase preparado: historial, feedback y observaciones oficiales futuras con RLS.
- Despliegue: Render para API, Vercel para Flutter web, GitHub Actions para CI/CD.
- Limitaciones corregidas parcialmente: INEI documentado como semilla curada, SENAMHI como validacion progresiva, etiquetas rule-based transparentadas.

## Plan de diapositivas recomendado

### Diapositiva 1 - Titulo

Titulo:
FrostPuno

Subtitulo:
Sistema inteligente distribuido para prediccion de heladas en Puno con app movil, FastAPI, Supabase y aprendizaje supervisado

Texto corto:
MVP academico orientado a productores altoandinos y validacion progresiva del modelo.

### Diapositiva 2 - Problema

Titulo:
Problema regional

Puntos:
- Las heladas afectan cultivos, ganado y produccion tradicional de chuno.
- La toma de decisiones suele depender de experiencia local sin una herramienta integrada.
- Se requiere una app simple que use ubicacion, clima actual y modelo predictivo.

### Diapositiva 3 - Solucion actual

Titulo:
De formulario tecnico a app movil usable

Puntos:
- Se eliminaron inputs manuales de temperatura, humedad, viento y nubosidad.
- La app obtiene GPS y clima actual automaticamente.
- El resultado muestra riesgo, confianza, color e icono.
- Incluye historial y modo oscuro.

Visual sugerido:
Capturas `docs/capturas/01_flutter_home.png`, `13_flutter_prediction_form.png`, `15_flutter_model_info.png` o capturas moviles actualizadas.

### Diapositiva 4 - Arquitectura

Titulo:
Arquitectura distribuida

Puntos:
- Flutter consume endpoints REST.
- FastAPI centraliza clima, prediccion, historial y metadata del modelo.
- Open-Meteo entrega variables meteorologicas por coordenadas.
- Supabase queda preparado para persistencia, feedback y observaciones.
- Render, Vercel y GitHub Actions completan el flujo de despliegue.

Visual sugerido:
Diagrama simple: Flutter -> FastAPI -> Modelo/Supabase/Open-Meteo.

### Diapositiva 5 - Datos

Titulo:
Fuentes de datos y trazabilidad

Puntos:
- Open-Meteo: clima horario y actual por lat/lng.
- INEI: semilla curada MVP de distritos, no extraccion oficial completa automatica.
- SENAMHI: validacion oficial progresiva, no integracion completa aun.
- Feedback de usuario y observaciones oficiales: base para mejora supervisada.

### Diapositiva 6 - Modelo v0.1.0

Titulo:
Modelo inicial v0.1.0

Puntos:
- RandomForestClassifier como modelo productivo.
- Backend actual sigue usando v0.1.0 para no romper produccion.
- Metricas perfectas fueron optimistas.
- Causa: variables derivadas de la regla de etiquetado.

Frase clave:
No se elimina v0.1.0; se conserva como version estable del MVP.

### Diapositiva 7 - Data leakage

Titulo:
Por que F1 macro = 1.00 no era suficiente

Puntos:
- Data leakage ocurre cuando las features contienen informacion demasiado cercana a la etiqueta.
- En v0.1.0 se usaban `temperatura_minima_diaria` y `horas_bajo_cero`.
- Esas variables estaban ligadas a la regla que creaba `riesgo_helada`.
- Por eso la evaluacion podia verse perfecta sin medir generalizacion real.

### Diapositiva 8 - Modelo v0.2.0

Titulo:
v0.2.0: evaluacion mas realista

Puntos:
- Dataset nuevo: `frost_training_dataset_v2.csv`.
- Se eliminaron features con leakage.
- Split por distrito: prueba con distritos no vistos.
- Se guardo como version experimental, sin cambiar produccion.

Metricas:
- Accuracy: 0.5097
- Precision macro: 0.4697
- Recall macro: 0.4954
- F1 macro: 0.4790

### Diapositiva 9 - Comparacion v1 vs v2

Titulo:
Comparacion formal

Tabla sugerida:

| Metrica | v0.1.0 | v0.2.0 |
|---|---:|---:|
| Accuracy | 1.00 | 0.5097 |
| Precision macro | 1.00 | 0.4697 |
| Recall macro | 1.00 | 0.4954 |
| F1 macro | 1.00 | 0.4790 |

Mensaje:
v0.2.0 no busca verse perfecta; busca medir mejor la capacidad de generalizar.

### Diapositiva 10 - Mejora supervisada

Titulo:
Como mejora el sistema

Puntos:
- No aprende automaticamente en produccion.
- Recoge feedback y observaciones.
- Evalua contra eventos observados.
- Entrena una version nueva.
- Compara metricas.
- Promociona manualmente si cumple criterios.

Visual sugerido:
Datos -> Entrenamiento -> Evaluacion -> Comparacion -> Aprobacion -> Produccion.

### Diapositiva 11 - Despliegue

Titulo:
Despliegue y evidencias

Puntos:
- API FastAPI en Render: `https://frost-puno.onrender.com`.
- Flutter web en Vercel: `https://frost-puno.vercel.app`.
- Repositorio y ramas en GitHub.
- Workflows CI/CD para backend, Flutter, datos y ML.
- Supabase con migraciones y RLS preparado.

Visual sugerido:
Capturas de `docs/capturas/25_` a `37_`.

### Diapositiva 12 - APK y mobile ready

Titulo:
APK Android

Puntos:
- Build release generado con backend productivo.
- Icono propio de FrostPuno.
- Pantallas optimizadas para movil.
- API base configurada con `--dart-define=API_BASE_URL=https://frost-puno.onrender.com`.

Ruta:
`app_flutter/build/app/outputs/flutter-apk/app-release.apk`

### Diapositiva 13 - Limitaciones honestas

Titulo:
Limitaciones actuales

Puntos:
- SENAMHI aun no esta integrado como validacion oficial completa.
- Las etiquetas iniciales siguen siendo rule-based.
- La cobertura temporal y territorial debe ampliarse.
- v0.2.0 es experimental y requiere mas datos observados.
- El sistema no reemplaza alertas oficiales.

### Diapositiva 14 - Conclusiones

Titulo:
Conclusiones

Puntos:
- FrostPuno ya funciona como app movil y web desplegada.
- La arquitectura separa frontend, backend, datos, ML y despliegue.
- Se corrigio la evaluacion optimista mediante v0.2.0.
- La mejora continua esta planteada con feedback y observaciones.
- El proyecto queda listo para exposicion y siguientes iteraciones.

## Sugerencias visuales

- Usar colores frios, pero no una paleta monotona: azul profundo, celeste hielo, verde andino y acentos amarillos para alertas.
- Mostrar capturas reales de la app actualizada.
- Evitar texto muy tecnico en slides; dejar detalles para el guion.
- Usar una tabla simple para v1 vs v2.
- Usar badges visuales: Produccion v0.1.0, Experimental v0.2.0, Render, Vercel, Supabase, GitHub Actions.

## Nota para actualizar en Canva

Cuando el plugin vuelva a estar conectado, abrir la presentacion y aplicar estos cambios. Si se quiere evitar dañar el deck original, primero duplicar el diseno y actualizar la copia.
