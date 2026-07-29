# Coordinación de la exposición — FrostPuno

**Duración total: 12 minutos máximo.** Cada integrante tiene su guion individual en esta
carpeta. Repositorio: https://github.com/JosephElvisMaman1/frost-puno

## Orden de intervención

| # | Integrante | Sección | Tiempo | Puntos que defiende |
|---|---|---|---|---|
| 1 | **Joseph Mamani** | Apertura: problema + arquitectura | 2:00 | Contexto y explicación técnica |
| 2 | **Yoel Apaza** | Dataset, modelo K-Means, hiperparámetros | 3:00 | **Entrenamiento (3 pts)** |
| 3 | **Yimmy Pari** | Demo de la app **en inglés** | 2:30 | **App en inglés (3 pts)** |
| 4 | **Héctor Flores** | Despliegue y puesta en producción | 2:00 | **Despliegue (2 pts)** |
| 5 | **Jahan Quispe** | IC, mantenimiento y **pruebas** | 2:30 | **Pipelines (2) + Pruebas (2)** |
| 6 | **Joseph Mamani** | Cierre: limitaciones + conclusión | 1:00 | Cierre |

**Total: 13:00** → recortar ~1 min ensayando (las secciones más comprimibles son la 1 y la 4).

## Archivos

- `00_JOSEPH_apertura_y_cierre.md`
- `01_APAZA_LLANOS_YOEL_modelo_ml.md`
- `02_PARI_PARI_YIMMY_demo_ingles.md`
- `03_FLORES_CURASI_HECTOR_despliegue.md`
- `04_QUISPE_GALINDO_JAHAN_ci_mantenimiento.md`

## Preparación (30 min antes)

- [ ] **Despertar el backend**: abrir https://frost-puno.onrender.com/health (Render Free
      duerme el servicio; la primera petición tarda ~30 s).
- [ ] Abrir pestañas: app web, `/docs`, GitHub → Actions, editor con el código.
- [ ] **Yimmy**: cambiar la app a inglés (Ajustes → Language → English).
- [ ] **Jahan**: terminal abierta en la carpeta del proyecto, dependencias instaladas.
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
4. **El video dura 12 minutos máximo**: cronometrar en el ensayo.
