# Coordinación de la exposición — FrostPuno

**Duración total: 12 minutos máximo.** Cada integrante tiene su guion individual en esta
carpeta. Repositorio: https://github.com/JosephElvisMaman1/frost-puno

## Equipo

| Integrante | Guion |
|---|---|
| Joseph Elvis Mamani Mendoza | `00_JOSEPH_apertura_y_cierre.md` |
| Juan Artemio Lipe Machaca | `01_JUAN_LIPE_modelo_ml.md` |
| Jhoel Yovani Ticona Erquinigo | `02_JHOEL_TICONA_demo_ingles.md` |
| Paul Renmis Tapara Ccahuana | `03_PAUL_TAPARA_despliegue_y_ci.md` |

## Orden de intervención

| # | Integrante | Sección | Tiempo | Puntos que defiende |
|---|---|---|---|---|
| 1 | **Joseph** | Apertura: problema + arquitectura | 2:00 | Contexto y explicación técnica |
| 2 | **Juan** | Dataset, modelo K-Means, hiperparámetros | 3:00 | **Entrenamiento (3 pts)** |
| 3 | **Jhoel** | Demo de la app **en inglés** | 2:30 | **App en inglés (3 pts)** |
| 4 | **Paul** | Despliegue + IC, mantenimiento y pruebas | 3:30 | **Despliegue (2) + Pipelines (2) + Pruebas (2)** |
| 5 | **Joseph** | Cierre: limitaciones + conclusión | 1:00 | Cierre |

**Total: 12:00** — justo en el límite. Cronometrar en el ensayo.

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
