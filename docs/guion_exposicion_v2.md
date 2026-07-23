# Guión de exposición — FrostPuno (12 min máx)

Equipo de hasta 4. Distribuir secciones entre integrantes. La sección 4 (demo) va **en
inglés** (rúbrica: "Funcionamiento de la aplicación en inglés = 3 pts"). El resto en
español. Al final, checklist de qué abrir en vivo y qué código mostrar.

> URLs en vivo:
> - App web: https://frost-puno.vercel.app
> - Backend/API docs: https://frost-puno.onrender.com/docs
> - Repo: https://github.com/JosephElvisMaman1/frost-puno

---

## 1. Problema y contexto (1.5 min) — español

- Puno, altiplano andino > 3800 m: las **heladas** dañan cultivos y matan crías de ganado, pero también son el insumo del **chuño** (papa deshidratada por congelamiento nocturno + secado diurno).
- Necesidad: una app que avise del riesgo de helada y ayude a decidir cuándo hacer chuño.
- Alcance académico: MVP con datos abiertos, ML no supervisado, desplegado y con CI/CD.

## 2. Arquitectura (2 min) — español

Flujo end-to-end:
```
Open-Meteo ─▶ ml_pipeline (features) ─▶ registry (.joblib + metadata) ─▶ FastAPI ─▶ Flutter
                                                              │
                                          Supabase (historial) │  Render / Vercel (deploy)
```
- `ml_pipeline/`: ingesta y entrenamiento del modelo.
- `backend_fastapi/`: sirve el modelo y la lógica (predicción, chuño, alertas, histórico).
- `app_flutter/`: cliente web + Android.
- Contrato ML↔backend: la **lista de features** del `cluster_metadata.json`.
- **Mostrar:** `CLAUDE.md` (sección Arquitectura) o este diagrama.

## 3. Modelo ML no supervisado (3 min) — español · NÚCLEO

- Algoritmo: **K-Means** (aprendizaje no supervisado). Agrupa observaciones climáticas de Puno en **regímenes térmicos**; cada cluster se mapea a riesgo alto/medio/bajo por su temperatura media.
- Dataset: `data/processed/frost_training_dataset.csv` (~4368 registros horarios, 13 distritos, Open-Meteo).
- Features (`CLUSTER_FEATURES`): altitud, temperatura, humedad, punto de rocío, nubosidad, viento, precipitación, temp. aparente.
- Selección de `k` por **silhouette** (probamos k=3..6, gana k=3). Métricas: **silhouette 0.286**, **Davies-Bouldin 1.21**.
- Por qué no accuracy/F1: no hay etiquetas de verdad de terreno → se mide **cohesión y separación** de clusters, no clasificación supervisada.
- Resultado tangible: `district_clusters.csv` — Macusani (4315 m) y Juliaca = riesgo **alto**; Sandia (2170 m, valle) = **bajo**.
- **Mostrar código:** `ml_pipeline/clustering/train_clusters.py` (funciones `select_k`, `assign_tiers`), `ml_pipeline/registry/cluster_metadata.json`, `ml_pipeline/registry/check_cluster_quality.py`.
- **Mostrar en vivo:** correr `python -m ml_pipeline.clustering.train_clusters` (tarda <1 s, imprime silhouette por k).

## 4. Demo funcional (2.5 min) — **ENGLISH** (3 pts)

Open https://frost-puno.vercel.app and walk through:

- **Home / daily alert:** "The home screen shows today's frost alert. The banner turns red when tonight's minimum drops below the user's threshold. Below it, a separate **livestock card** warns cattle herders when temperatures endanger newborn alpacas and sheep."
- **Settings (tune icon):** "Users can turn alarms on or off, set their own temperature threshold, and pick a profile — farmer, herder, or chuño-maker — which changes what alerts they see first."
- **Zonas (Zones):** "This map groups Puno's districts by frost-risk level using the K-Means model — the high-risk cluster is shown in amber."
- **Chuño module:** "It evaluates the daily forecast against traditional chuño rules — three consecutive freezing nights below minus five degrees plus dry, clear days — and flags an optimal production window, active only in the May–August season."
- **Clima histórico (History):** "Interactive charts of the last thirty days of minimum/maximum temperature and humidity, pulled from the Open-Meteo Archive API."
- **Anomaly card:** "When today's minimum is unusually far below the recent average, the app flags it as an unusual frost."
- **API:** open https://frost-puno.onrender.com/docs → GET `/ml/model-info` → "the served model is KMeans, version v1.0.0-clustering."

## 5. Despliegue + CI/CD (2 min) — español

- **Backend:** Render (`render.yaml`, autoDeploy en push a `main`). Comando: `uvicorn app.main:app`.
- **Frontend:** Vercel (`vercel.json`), auto-deploy desde `main`.
- **Persistencia:** Supabase (opcional, historial de predicciones).
- **Workflows** (`.github/workflows/`):
  - `ml-training.yml`: entrena K-Means y sube artefactos.
  - `model-quality-gate.yml`: **bloquea** modelos con silhouette < 0.25.
  - `backend-tests.yml` (12 tests), `data-validation.yml`, `flutter-build.yml`.
- **Mostrar:** pestaña Actions en GitHub + `render.yaml`.

## 6. Mantenimiento, IC y cierre (1 min) — español

- El modelo se **reentrena** por workflow (manual o programado) y solo se promueve si pasa el gate de silhouette → mantenimiento automatizado del elemento inteligente.
- **Limitaciones:** etiquetas de riesgo derivadas del perfil térmico (no oficiales); SENAMHI sin API pública estable (Open-Meteo es la fuente operativa); umbrales de chuño/ganado son diseño MVP documentado (`docs/chuno_criteria.md`, `docs/livestock_criteria.md`).
- Cierre: app útil para el poblador (alertas de cultivo y ganado, ventana de chuño) + rigor técnico (ML no supervisado, despliegue, CI/CD).

---

## Checklist en vivo

**Abrir por adelantado (pestañas):**
- [ ] https://frost-puno.vercel.app (web)
- [ ] https://frost-puno.onrender.com/docs (Swagger)
- [ ] GitHub → Actions
- [ ] Editor con `train_clusters.py` y `cluster_metadata.json` abiertos

**Endpoints a demostrar en Swagger:**
- [ ] `GET /ml/model-info` → model_name KMeans
- [ ] `GET /ml/clusters` → distritos por tier
- [ ] `GET /chuno/window?latitude=-15.84&longitude=-70.02`
- [ ] `GET /alerts/today?latitude=-15.84&longitude=-70.02` → bloques `livestock` y `anomaly`

**Reparto sugerido (4 integrantes):**
- Integrante A: secciones 1 y 2.
- Integrante B: sección 3 (ML) — la más puntuada.
- Integrante C: sección 4 (demo en inglés).
- Integrante D: secciones 5 y 6 (deploy + CI/CD).

**Tiempo total:** 1.5 + 2 + 3 + 2.5 + 2 + 1 = **12 min**.
