# Coordinación de la exposición — FrostPuno

**Duración total: 12 minutos máximo.** Cada integrante tiene su guion individual en esta
carpeta. Repositorio: https://github.com/JosephElvisMaman1/frost-puno

## Equipo

| Integrante | Guion |
|---|---|
| Joseph Elvis Mamani Mendoza | `00_JOSEPH_apertura_y_cierre.md` |
| Juan Artemio Lipe Machaca | `01_JUAN_LIPE_dataset.md` |
| Jhoel Yovani Ticona Erquinigo | `02_JHOEL_TICONA_demo_ingles.md` |
| Paul Renmis Tapara Ccahuana | `03_PAUL_TAPARA_despliegue_y_ci.md` |

## Orden de intervención

| # | Integrante | Sección | Tiempo | Puntos que defiende |
|---|---|---|---|---|
| 1 | **Joseph** | Apertura: problema + arquitectura | 2:00 | Contexto y explicación técnica |
| 2 | **Juan** | Dataset y fuentes de datos | 1:30 | Dataset |
| 3 | **Joseph** | **Modelo: entrenamiento, hiperparámetros y evaluación** | 2:30 | **Entrenamiento (3 pts)** |
| 4 | **Jhoel** | Demo de la app **en inglés** | 2:30 | **App en inglés (3 pts)** |
| 5 | **Paul** | Despliegue + IC, mantenimiento y pruebas | 3:00 | **Despliegue (2) + Pipelines (2) + Pruebas (2)** |
| 6 | **Joseph** | Cierre: limitaciones + conclusión | 1:00 | Cierre |

**Total: 12:30** → recortar 30 s en el ensayo (lo más comprimible: §1.4 de Joseph y la
anécdota A.3 de Paul). **El límite son 12 minutos.**

> **Joseph desarrolló el sistema** (los 30 commits del repositorio son suyos), por eso
> presenta la arquitectura y el modelo, y **responde todas las preguntas técnicas**. Si una
> pregunta baja al código o al modelo, la toma él aunque sea de la sección de otro.

## Evidencia de autoría (acordado con el equipo)

- Durante la sección de **integración continua**, Paul abre la pestaña **Actions** de
  GitHub. Ahí mismo, con un clic en **Insights → Contributors**, se ve el historial real de
  contribuciones del repositorio. No hay que decir nada: se ve.
- Todas las **preguntas técnicas** las responde Joseph.
- El repositorio queda proyectado o disponible por si el jurado quiere revisarlo.

## Preparación (30 min antes)

- [ ] **Despertar el backend**: abrir https://frost-puno.onrender.com/health (Render Free
      duerme el servicio; la primera petición tarda ~30 s).
- [ ] Abrir pestañas: app web, `/docs`, GitHub → Actions, editor con el código.
- [ ] **Jhoel**: cambiar la app a inglés (Ajustes → Language → English).
- [ ] **Paul**: terminal abierta en la carpeta del proyecto, dependencias instaladas.
- [ ] Opcional: un celular con el APK instalado para mostrar la versión Android.

## Datos que todos deben saber (por si preguntan)

| Dato | Valor |
|---|---|
| Modelo | K-Means (no supervisado), `v1.0.0-clustering` |
| Silhouette | 0.419 |
| Davies-Bouldin | 0.813 |
| Clusters | 3 (alto / medio / bajo) |
| Hiperparámetros | k=3, init=random, n_init=10, StandardScaler |
| Grid search | 24 combinaciones |
| Dataset | 4 368 registros, 13 distritos |
| Features | altitud, temperatura, punto de rocío, humedad |
| Quality gate | silhouette ≥ 0.35 |
| Pruebas | 12 backend + 6 mantenimiento/IC |
| Workflows | 5 (uno con cron semanal) |

## Reglas de oro

1. **No leer de corrido**: los guiones están escritos para sonar hablados, pero míralos como
   apoyo, no como lectura.
2. **Si algo falla en vivo** (Render dormido, sin internet): hay capturas en `docs/capturas/`.
   Nunca improvisar datos.
3. **Las limitaciones se dicen**: un informe honesto puntúa mejor que uno que promete de más.
4. **12 minutos máximo**: si van justos, la sección más comprimible es la apertura (1.4) y la
   parte A.3 de Paul.
