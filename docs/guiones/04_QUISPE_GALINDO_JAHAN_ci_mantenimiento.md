# Guion — JAHAN KEVIN QUISPE GALINDO
## Rol: Integración continua, mantenimiento y **pruebas** del ciclo automatizado

**Tiempo: ~2.5 min** — Vale **4 puntos**: 2 de "Pipelines de mantenimiento e IC" y 2 de
"Pruebas de funcionamiento". Tu parte es la que demuestra que el sistema **se mantiene solo**.

**Repositorio:** https://github.com/JosephElvisMaman1/frost-puno

**Ten abierto:** GitHub → pestaña **Actions**, y una terminal en la carpeta del proyecto.

---

## 1. Los cinco pipelines (30 s)

*Muestra la pestaña Actions.*

> "Gracias. Yo cierro con la parte de mantenimiento e integración continua.
>
> Tenemos **cinco workflows** en GitHub Actions que corren **en paralelo** ante cada push:
>
> - **ML Training**: ingesta el clima, construye las características y entrena el modelo.
> - **Model Quality Gate**: la barrera de calidad del modelo.
> - **Backend Tests**: doce pruebas de la API.
> - **Data Validation**: valida los datasets y la agrupación de distritos.
> - **Flutter Build**: analiza, prueba y compila el cliente web.
>
> Cada uno es un job aislado, con su propio entorno, y no se bloquean entre sí."

## 2. El modelo se reentrena solo (35 s)

> "El enunciado pide mantener también el **elemento inteligente**, no solo el código. Eso lo
> resolvemos así:
>
> El workflow de entrenamiento tiene un disparo **por cron, semanal**. Nadie tiene que
> acordarse de reentrenar: ocurre solo.
>
> Y hay algo más: implementamos un **reentrenamiento adaptativo**. El script descarga datos
> frescos, reentrena y mide la calidad. Si la métrica **no alcanza el objetivo**, en vez de
> rendirse **amplía la ventana de datos** —de 14 a 29 a 44 días— y vuelve a intentar.
>
> Cada corrida queda registrada en un archivo de **historial de entrenamiento** con la fecha,
> cuántos días de datos usó, el tamaño del dataset y la métrica obtenida. Ese historial es la
> evidencia de que el modelo **sigue aprendiendo y mejora con más datos**."

## 3. El quality gate: la barrera (30 s)

> "Ahora, reentrenar automáticamente es peligroso si no hay control: un modelo nuevo podría
> ser **peor** que el que está en producción.
>
> Por eso existe el **quality gate**. Antes de promover cualquier modelo, se verifica su
> métrica de silhouette. Si está por debajo de **0.35**, el gate **falla con código de error
> 1** y la integración se detiene. El modelo malo nunca llega a producción."

## 4. DEMOSTRACIÓN EN VIVO (40 s) — *esta es tu parte fuerte*

*En la terminal, ejecuta los dos comandos.*

**Comando 1 — el modelo actual pasa:**
```bash
python -m ml_pipeline.registry.check_cluster_quality --min-silhouette 0.35
```
> "Con el umbral real, nuestro modelo tiene 0.419 y el gate responde **QUALITY GATE PASSED**."

**Comando 2 — simulamos un modelo malo:**
```bash
python -m ml_pipeline.registry.check_cluster_quality --min-silhouette 0.99
```
> "Y si exigimos un umbral que no cumple, responde **QUALITY GATE FAILED** y devuelve código
> de error 1. Eso es exactamente lo que detendría el pipeline en GitHub Actions."

## 5. Pruebas del mantenimiento (35 s)

```bash
python -m pytest ml_pipeline/tests/test_maintenance_ci.py -v
```

> "Pero no basta con decir que el mantenimiento funciona: lo **probamos**. Tenemos **seis
> pruebas automatizadas** que corren dentro de la integración continua y verifican:
>
> 1. Que el reentrenamiento deja el modelo, la metadata y la agrupación de distritos.
> 2. Que el modelo guardado **se puede cargar e inferir** — o sea, que el contrato con el
>    backend sigue vivo.
> 3. Que los 13 distritos quedan asignados a un nivel de riesgo válido.
> 4. Que la metadata documenta la búsqueda de hiperparámetros y que la configuración elegida
>    es realmente la mejor del grid.
> 5. Que el quality gate **aprueba** el modelo de producción.
> 6. Y la más importante: que el quality gate **bloquea un modelo degradado**. La prueba
>    fabrica una metadata con silhouette 0.10 y verifica que el gate devuelve error.
>
> Es decir: tenemos una prueba automatizada que verifica que **nuestra propia barrera de
> seguridad funciona**."

## 6. Cierre de tu parte (20 s)

> "En conjunto: el modelo se reentrena solo por cron, busca mejorar ampliando su ventana de
> datos, registra su historial de calidad, y está protegido por una barrera que probamos que
> bloquea regresiones. Todo eso sin intervención humana.
>
> Le devuelvo la palabra a Joseph para el cierre."

---

## Preguntas probables

**"¿Qué pasa si el reentrenamiento automático genera un modelo peor?"**
> "No se promueve. El quality gate lo bloquea antes, y el modelo anterior sigue sirviendo en
> producción. Además queda registrado en el historial de entrenamiento para poder analizarlo."

**"¿El cron realmente corre o solo está configurado?"**
> "Está configurado como `schedule` semanal en el workflow y se puede ver en la pestaña
> Actions, donde aparecen las ejecuciones programadas además de las disparadas por push."

**"¿Por qué el umbral es 0.35 y no otro?"**
> "Nuestro modelo actual está en 0.419. Pusimos 0.35 como piso: da margen para variaciones
> normales entre reentrenamientos, pero bloquea una degradación real. Es un parámetro
> configurable por variable de entorno."

**"¿Las pruebas corren en la nube o solo local?"**
> "Ambas. Están integradas en el workflow del quality gate, así que se ejecutan en cada push
> en los servidores de GitHub, no solo en nuestras máquinas."
