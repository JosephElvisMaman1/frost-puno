# FrostPuno — Informe Técnico
## Curso: Aprendizaje de Máquina — Proyecto de la Segunda Unidad

**Aplicación con elementos inteligentes basada en aprendizaje NO SUPERVISADO (K-Means),
desplegada en producción, con mantenimiento e integración continua automatizados.**

- **Universidad:** Universidad Nacional del Altiplano — Ingeniería de Sistemas
- **Integrantes:**
  - Mamani Mendoza, Joseph Elvis
  - Lipe Machaca, Juan Artemio
  - Ticona Erquinigo, Jhoel Yovani
  - Tapara Ccahuana, Paul Renmis
- **Docente:** _[Completar]_
- **Lugar y año:** Puno, Perú — 2026

**Producto en producción**

| Componente | URL |
|---|---|
| Aplicación web (Flutter) | https://frost-puno.vercel.app |
| API (FastAPI) | https://frost-puno.onrender.com — docs en `/docs` |
| Repositorio | https://github.com/JosephElvisMaman1/frost-puno |
| APK Android | build release de Flutter (`app-release.apk`, 47 MB) |
| Video de la exposición | _[completar URL]_ |

---

## 1. Resumen

FrostPuno predice el riesgo de heladas en el altiplano de Puno y apoya la producción
tradicional de **chuño**. La lógica de negocio se operativiza mediante un modelo de
**aprendizaje no supervisado (K-Means)** que agrupa los regímenes climáticos de los
distritos y los mapea a niveles de riesgo. El sistema está **desplegado en producción**
(Render + Vercel + Supabase) y su mantenimiento —incluido el reentrenamiento del
modelo— está **automatizado con GitHub Actions**, con un *quality gate* que bloquea
modelos que empeoran.

> **Nota de trazabilidad académica.** El proyecto nació con un clasificador supervisado
> (RandomForest, métrica `f1_macro`). Se **migró a aprendizaje no supervisado** conforme
> al enunciado de la segunda unidad. Los scripts supervisados se conservan como *legacy
> documentado* (`ml_pipeline/training/train_models.py`), fuera del path productivo.

## 2. Problema y contexto

En el altiplano (> 3 800 m) las heladas dañan cultivos y causan mortalidad neonatal en
crías de alpaca y ovino. Las mismas heladas, sin embargo, son el insumo del chuño (papa
deshidratada por congelamiento nocturno y secado diurno). Las decisiones se toman por
experiencia empírica, sin información climática integrada. FrostPuno entrega: alerta
diaria de helada, riesgo diferenciado para ganado, ventanas óptimas de chuño, detección
de eventos inusuales e histórico climático.

## 3. Dataset y características

**Fuentes.** Open-Meteo (clima horario, histórico y pronóstico), semilla territorial
compatible con INEI para los distritos de Puno, SENAMHI documentado como fuente oficial
prioritaria (sin API pública estable en el MVP).

**Volumen.** 13 distritos × ventana horaria → **4 368 registros** en
`data/processed/frost_training_dataset.csv` (versionado en git: actúa como *feature store*
del MVP y se valida en IC).

**Características del modelo** (`CLUSTER_FEATURES` en `ml_pipeline/config.py`):

| Feature | Origen |
|---|---|
| `altitud_estimada` | semilla territorial del distrito |
| `temperature_2m` | Open-Meteo |
| `dew_point_2m` | Open-Meteo |
| `relative_humidity_2m` | Open-Meteo |

**Selección de características (experimento).** Se partió de 8 variables. Un experimento
de subconjuntos mostró que `precipitation`, `wind_speed_10m`, `cloud_cover` y
`apparent_temperature` eran **ruidosas o colineales** y degradaban la separación de
grupos. Al podarlas, la silhouette subió de **0.286 → 0.419** (+47 %). Se conservaron las
cuatro variables con sentido físico para helada (altitud, temperatura, punto de rocío y
humedad).

Estas cuatro features están disponibles **tanto en entrenamiento como en inferencia en
vivo** (provienen de `CurrentWeatherResponse` + altitud), garantizando que el mismo vector
se pueda construir en producción. Este es el **contrato ML↔backend**, declarado en el
metadata del modelo.

## 4. Entrenamiento del modelo e hiperparámetros optimizados

**Algoritmo:** `KMeans` (scikit-learn) dentro de un `Pipeline` con `StandardScaler`
(las features tienen escalas muy distintas: metros vs. grados vs. porcentaje).

**Optimización de hiperparámetros.** Grid search de **24 combinaciones** maximizando
silhouette (`search_hyperparameters` en `ml_pipeline/clustering/train_clusters.py`):

| Hiperparámetro | Valores explorados |
|---|---|
| `n_clusters` (k) | 3, 4, 5, 6, 7, 8 |
| `init` | `k-means++`, `random` |
| `n_init` | 10, 25 |
| `random_state` | 42 (reproducibilidad) |

**Configuración ganadora:** `k=3`, `init=random`, `n_init=10`, `StandardScaler`.
El grid completo se persiste en `cluster_metadata.json` bajo `hyperparameter_search`
como evidencia auditable.

**Selección de k** (mejor combinación por cada k):

| k | Silhouette | Davies-Bouldin |
|---|---|---|
| **3** | **0.4195** | **0.813** |
| 4 | 0.3894 | 0.906 |
| 5 | 0.3760 | 0.820 |
| 6 | 0.3697 | 0.870 |
| 7 | 0.3645 | 0.865 |
| 8 | 0.3391 | 0.883 |

k = 3 gana en silhouette y en Davies-Bouldin, y además coincide con los tres niveles de
riesgo operativos (alto/medio/bajo).

**Asignación de niveles (post-hoc).** Los clusters se ordenan por temperatura media: el
más frío es riesgo **alto**. Esto es *descripción* de los grupos hallados, no supervisión:
no se usan etiquetas en el entrenamiento.

## 5. Evaluación

**Métricas del modelo productivo** (`v1.0.0-clustering`):

| Métrica | Valor | Interpretación |
|---|---|---|
| **Silhouette** | **0.4195** | cohesión/separación de los grupos (↑ mejor) |
| **Davies-Bouldin** | **0.813** | dispersión intra vs. inter cluster (↓ mejor) |
| Inercia | 5 783 | suma de distancias al centroide |

**Por qué no accuracy ni F1.** No existen etiquetas de verdad de terreno para "hubo
helada" en estos distritos. Al ser aprendizaje **no supervisado**, la evaluación mide la
**calidad de la estructura descubierta**, no el acierto contra una etiqueta.

**Perfil de los clusters encontrados:**

| Cluster | Nivel | Temp. media | Altitud media | Observaciones |
|---|---|---|---|---|
| 0 | alto | 4.0 °C | 3 905 m | 1 889 |
| 2 | medio | 11.6 °C | 3 893 m | 2 145 |
| 1 | bajo | 13.6 °C | 2 170 m | 334 |

**Resultado interpretable** (`data/processed/district_clusters.csv`): Macusani (4 315 m),
Juliaca y Huancané → riesgo **alto**; Puno, Azángaro, Ayaviri → **medio**; Sandia
(2 170 m, valle) → **bajo**. El ordenamiento surge del clustering, no de reglas escritas
a mano, y coincide con el conocimiento geográfico de la región (validación cualitativa).

## 6. Organización del código fuente

```
ml_pipeline/       # Pipeline de ML
  config.py            # fuente única de rutas, features y constantes
  data_ingestion/      # ingesta paralela Open-Meteo (ThreadPoolExecutor)
  features/            # construcción del dataset (feature store)
  clustering/          # train_clusters.py (K-Means) + adaptive_retrain.py
  registry/            # modelo .joblib + metadata + quality gate
  tests/               # pruebas de mantenimiento e IC
backend_fastapi/   # API que sirve el modelo
  app/api/routes/      # HTTP  → services → repositories → schemas
app_flutter/       # Cliente web + Android (feature-first, i18n ES/EN)
data/              # datasets versionados y validados en IC
.github/workflows/ # 5 pipelines de integración continua
```

Principios: **configuración centralizada** (nada de rutas hardcodeadas), separación
estricta por capas en el backend, y el **metadata del modelo como contrato** entre el
pipeline de ML y el servicio de inferencia.

## 7. Herramientas y plataformas

| Área | Herramienta |
|---|---|
| ML | Python 3.11, scikit-learn, pandas, joblib |
| Backend | FastAPI, Uvicorn, Pydantic, httpx |
| Cliente | Flutter (Web + Android), fl_chart, shared_preferences |
| Despliegue | Render (API), Vercel (web), Supabase (PostgreSQL) |
| CI/CD | GitHub Actions (5 workflows) |
| Datos | Open-Meteo API (histórico, pronóstico y archivo) |

## 8. Consideraciones de despliegue inicial

**Backend (Render).** Definido como *infraestructura como código* en `render.yaml`:
runtime Python 3.11, `buildCommand` con `requirements.txt`, `healthCheckPath: /health`,
`autoDeploy: true`. Variables de entorno: `MODEL_PATH`, `MODEL_METADATA_PATH`,
`DISTRICT_CLUSTERS_PATH`, `CORS_ORIGINS`, `ENABLE_SUPABASE` y `SUPABASE_SERVICE_ROLE_KEY`
(marcada `sync: false`, **nunca** en el repositorio).

> **Lección aprendida en producción:** las variables definidas manualmente en el panel de
> Render **prevalecen** sobre `render.yaml`. Tras migrar a K-Means, la API siguió sirviendo
> el modelo anterior hasta corregir esas variables en el panel. Punto crítico para el
> equipo de TI que reciba el sistema.

**Cliente web (Vercel).** `app_flutter/vercel.json`; `API_BASE_URL` se inyecta con
`--dart-define` (nunca hardcodeado). Auto-deploy desde `main`.

**APK Android.**
```bash
flutter build apk --release --dart-define=API_BASE_URL=https://frost-puno.onrender.com
```

**Persistencia.** Supabase es opcional: con `ENABLE_SUPABASE=false` se usa un repositorio
en memoria (así corren los tests en IC).

**Orden de puesta en marcha:** entrenar y publicar el modelo → desplegar API y verificar
`/health` y `/ml/model-info` → desplegar cliente con la URL de la API → (opcional) activar
Supabase.

## 9. Flujos de mantenimiento e integración continua

Cinco workflows independientes, en paralelo, ante cada push:

| Workflow | Función |
|---|---|
| `ml-training.yml` | Ingesta → features → entrenamiento → artefactos. **Cron semanal.** |
| `model-quality-gate.yml` | **Barrera**: bloquea silhouette < 0.35 + pruebas de mantenimiento |
| `backend-tests.yml` | 12 pruebas de la API sin Supabase |
| `data-validation.yml` | Valida datasets y agrupación de distritos |
| `flutter-build.yml` | `analyze` + `test` + build web |

**Mantenimiento del elemento inteligente (lo que pide el enunciado):**

- **Reentrenamiento automatizado:** `ml-training.yml` corre por `schedule` (cron semanal)
  sin intervención humana.
- **Reentrenamiento adaptativo — el modelo sigue aprendiendo:**
  `ml_pipeline/clustering/adaptive_retrain.py` reentrena con datos frescos y, **si la
  silhouette no alcanza el objetivo (0.45), amplía la ventana de datos** (14 → 29 → 44
  días) y reintenta. Cada corrida se registra en `registry/training_history.json`
  (fecha, días de datos, tamaño del dataset, silhouette, k, hiperparámetros), lo que
  documenta la evolución de la calidad frente al volumen de datos.
- **Registro de modelos (registry):** cada entrenamiento versiona modelo + metadata
  (features, métricas, hiperparámetros, limitaciones).
- **Almacenamiento de características:** el dataset de features está versionado en
  `data/processed/` y se valida en IC.
- **Quality gate:** ningún modelo se promueve si `silhouette < 0.35`.

## 10. Pruebas de funcionamiento del mantenimiento e IC

`ml_pipeline/tests/test_maintenance_ci.py` — **6 pruebas** que corren en IC:

1. El reentrenamiento deja modelo, metadata y agrupación de distritos.
2. El `.joblib` se carga e infiere (contrato con el backend intacto).
3. Los 13 distritos quedan asignados a un tier válido.
4. La metadata documenta el grid search y la config elegida es la mejor del grid.
5. El quality gate **aprueba** el modelo en producción.
6. **El quality gate bloquea un modelo degradado** (silhouette 0.10 → exit code 1): prueba
   de que la integración se **detiene** ante una regresión del modelo.

Demostración en vivo del gate:
```bash
python -m ml_pipeline.registry.check_cluster_quality --min-silhouette 0.35   # PASSED
python -m ml_pipeline.registry.check_cluster_quality --min-silhouette 0.99   # FAILED, exit 1
```

Otras evidencias: 12 pruebas del backend en verde, `flutter analyze/test/build web` en
verde, APK release compilando, y el historial de corridas en la pestaña **Actions**.
Detalle completo en `docs/pruebas_mantenimiento_ic.md`.

## 11. Funcionamiento de la aplicación (demo en inglés)

La aplicación incluye **modo inglés** (Ajustes → Language → English): navegación, alertas,
niveles de riesgo y recomendaciones se muestran en inglés. El guión palabra por palabra
para la exposición está en `docs/english_demo_script.md`.

Funcionalidades: alerta diaria de helada con umbral configurable, tarjeta de riesgo para
ganado, detección de anomalías, zonas de riesgo por K-Means, módulo estacional de chuño,
histórico climático y perfiles de usuario.

## 12. Limitaciones

- Los niveles de riesgo derivan del **perfil térmico de cada cluster**, no de etiquetas
  oficiales de heladas observadas.
- SENAMHI no expone API pública estable; Open-Meteo es la fuente operativa real.
- La semilla de distritos es un MVP y debe reemplazarse por exportes oficiales del INEI.
- Los umbrales de chuño y ganado son diseño MVP documentado
  (`docs/chuno_criteria.md`, `docs/livestock_criteria.md`).
- La detección de anomalías usa climatología reciente (30 días), no serie multianual.
- Render Free tiene arranque en frío (primera petición lenta).

## 13. Conclusiones

FrostPuno cumple el objetivo de la unidad: una aplicación **con elementos inteligentes
basados en aprendizaje no supervisado**, **desplegada en producción** y con **procesos de
mantenimiento e integración continua automatizados y probados**. El modelo K-Means alcanza
silhouette 0.419 tras selección de características y optimización de hiperparámetros; el
sistema se reentrena solo, registra su historial de calidad y se protege con un quality
gate verificado por pruebas.
