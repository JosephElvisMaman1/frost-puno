# Guion — FLORES CURASI, HÉCTOR LUIS
## Mantenimiento e integración continua

Tiempo: 2:30. Hablas después de Jahan. Expones la **tercera contribución** del paper.

Sección del paper: VII. Ten a la vista la **Figura 4** (ejecuciones concurrentes).
Si es posible, ten abierta la pestaña Actions del repositorio.

---

## 1. Por qué el mantenimiento es parte del problema (25 s)

> "Gracias Jahan. Yo explico cómo se mantiene el sistema.
>
> Cuando un sistema incorpora un componente de aprendizaje, el mantenimiento no se limita
> al código. Hay que reentrenar el modelo, versionarlo, almacenar las características y
> controlar la calidad antes de promover una versión nueva.
>
> Si eso queda como tarea manual, el sistema se degrada en cuanto nadie se ocupa. Por eso
> lo automatizamos."

## 2. Trabajos concurrentes (45 s)

*Muestra la Figura 4 del paper.*

> "Implementamos **cinco flujos independientes** que se ejecutan de forma simultánea, en
> entornos aislados, ante cada incorporación de cambios al repositorio:
>
> - El primero **entrena** el modelo y publica los artefactos.
> - El segundo aplica la **barrera de calidad** y ejecuta las pruebas de mantenimiento.
> - El tercero verifica el **servicio**.
> - El cuarto valida los **conjuntos de datos**.
> - Y el quinto analiza y compila el **cliente**.
>
> Aquí hay un punto de cómputo paralelo que quiero subrayar: como **no existen
> dependencias** entre estos flujos, el tiempo total no es la suma de los cinco, sino el
> del **flujo más lento**. Es paralelismo aplicado al proceso de integración, no solo al
> cálculo."

## 3. Reentrenamiento adaptativo (40 s)

> "El flujo de entrenamiento tiene una **programación semanal**, así que el modelo
> incorpora datos recientes sin que nadie tenga que acordarse.
>
> Pero hicimos algo más. El procedimiento no se limita a repetir el entrenamiento: si la
> calidad obtenida **no alcanza el objetivo**, en lugar de rendirse **amplía la ventana de
> datos históricos**, de catorce a veintinueve y luego a cuarenta y cuatro días, y vuelve a
> intentar.
>
> Cada ejecución queda registrada en un historial con la fecha, los días de datos usados,
> el tamaño del conjunto y la métrica obtenida. Ese historial documenta cómo evoluciona la
> calidad frente al volumen de datos disponible."

## 4. La barrera de calidad y su verificación (40 s)

> "Ahora, reentrenar automáticamente tiene un riesgo evidente: el modelo nuevo podría ser
> **peor** que el que está en producción.
>
> Para evitarlo verificamos el coeficiente de silueta antes de cualquier promoción. Si
> está por debajo de **0.35**, el proceso termina con código de error y la integración se
> **detiene**. El modelo malo no llega a producción.
>
> Y aquí está lo que considero más importante de esta sección: *(pausa)* **la existencia
> de la barrera no demuestra que funcione**.
>
> Por eso implementamos seis pruebas automatizadas que corren dentro de la integración
> continua. Verifican la generación de artefactos, que el modelo guardado se pueda cargar
> e inferir, la cobertura de los trece distritos, la documentación de los
> hiperparámetros, la aprobación del modelo vigente y, la más relevante, **el rechazo de
> un modelo deliberadamente degradado**: la prueba construye unos metadatos con una
> métrica insuficiente y comprueba que el control lo bloquea.
>
> Es decir, tenemos una prueba automatizada que verifica que **nuestra propia barrera de
> seguridad funciona**.
>
> Le paso la palabra a **Yoel**, con los resultados."

---

## Preguntas probables

**"¿Qué pasa si el reentrenamiento automático genera un modelo peor?"**
> "No se promueve. La barrera lo bloquea y el modelo anterior sigue sirviendo en
> producción. Además queda registrado en el historial de entrenamiento para analizarlo."

**"¿El cron realmente corre o solo está configurado?"**
> "Está configurado como ejecución programada semanal y las corridas se ven en la pestaña
> Actions del repositorio, junto a las disparadas por cambios."

**"¿Por qué el umbral es 0.35?"**
> "El modelo actual está en 0.419. Pusimos 0.35 como piso: da margen para variaciones
> normales entre reentrenamientos pero bloquea una degradación real. Es configurable por
> variable de entorno."

**"¿Los flujos corren de verdad en paralelo?"**
> "Sí, cada uno se ejecuta en un entorno separado del proveedor de integración continua.
> No comparten estado ni esperan al anterior."
