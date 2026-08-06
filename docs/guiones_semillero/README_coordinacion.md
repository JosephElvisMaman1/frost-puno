# Exposición del semillero — coordinación

Presentación del paper **FrostPuno: arquitectura distribuida y cómputo paralelo para
la predicción de heladas mediante aprendizaje no supervisado en el altiplano de Puno**.

Entregables: `docs/paper/paper_frostpuno.pdf` y `docs/paper/codigo_fuente.pdf`.
Repositorio: https://github.com/JosephElvisMaman1/frost-puno

## Orden de intervención

| # | Integrante | Sección del paper | Tiempo | Guion |
|---|---|---|---|---|
| 1 | **Mamani Mendoza, Joseph Elvis** | Problema y arquitectura distribuida (I, III) | 2:30 | `01_JOSEPH.md` |
| 2 | **Pari Pari, Yimmy Ronaldo** | Paralelismo en la ingesta (IV) | 2:30 | `02_PARI.md` |
| 3 | **Quispe Galindo, Jahan Kevin** | Cómputo de aprendizaje y modelo (V, VI) | 2:30 | `03_QUISPE.md` |
| 4 | **Flores Curasi, Héctor Luis** | Mantenimiento e integración continua (VII) | 2:30 | `04_FLORES.md` |
| 5 | **Apaza Llanos, Yoel** | Resultados y limitaciones (VIII, IX) | 1:30 | `05_APAZA.md` |
| 6 | **Mamani Mendoza, Joseph Elvis** | Conclusiones y cierre (X) | 1:00 | `01_JOSEPH.md` |

**Total: 12:30.** Ajustar según el tiempo que asigne el semillero.

## Datos que todos deben manejar

| Dato | Valor |
|---|---|
| Modelo | K-Means, aprendizaje no supervisado |
| Coeficiente de silueta | 0.419 |
| Índice de Davies-Bouldin | 0.813 |
| Número de grupos | 3 (alto, medio, bajo) |
| Búsqueda de hiperparámetros | 24 combinaciones |
| Conjunto de datos | 4368 registros, 13 distritos |
| Características | altitud, temperatura, punto de rocío, humedad |
| Mejora por selección de características | 0.286 a 0.419 |
| Barrera de calidad | silueta mínima 0.35 |
| Pruebas | 12 del servicio y 6 de mantenimiento |
| Flujos de integración continua | 5, concurrentes |
| Hilos de ingesta | 4 por defecto, configurable |

## Preparación

- [ ] Abrir el backend antes de exponer: https://frost-puno.onrender.com/health
- [ ] Tener el paper en PDF proyectable y el repositorio a mano.
- [ ] Pestañas listas: aplicación web, documentación de la API, GitHub Actions.
- [ ] Cada quien lee su guion en voz alta al menos una vez, cronometrado.

## Reglas

1. No leer la diapositiva ni el paper palabra por palabra. El guion es apoyo.
2. Pausar después de cada cifra. El número se registra en ese silencio.
3. Nombrar a quien sigue al terminar: "le paso la palabra a ...".
4. Las preguntas sobre el código o el modelo las responde Joseph, que desarrolló
   el sistema. El resto responde sobre su propia sección.
5. Decir las limitaciones sin rodeos. Un trabajo honesto se defiende mejor.
