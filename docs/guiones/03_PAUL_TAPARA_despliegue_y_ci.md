# Guion — PAUL RENMIS TAPARA CCAHUANA
## Rol: Despliegue, integración continua, mantenimiento y **pruebas**

**Tiempo: ~3.5 min** — Es la sección con **más puntaje acumulado**: 2 pts de "Despliegue",
2 pts de "Pipelines de mantenimiento e IC" y 2 pts de "Pruebas de funcionamiento".

**Repositorio:** https://github.com/JosephElvisMaman1/frost-puno

**Ten abierto:** `render.yaml`, GitHub → pestaña **Actions**, y una terminal en la carpeta
del proyecto.

---

# PARTE A — DESPLIEGUE (1:30)

## A.1 Dónde vive cada pieza (30 s)

> "Gracias Jhoel. Yo cierro con el despliegue y la automatización.
>
> No es un proyecto local: cada componente está en una plataforma distinta, en la nube:
>
> - El **backend FastAPI** corre en **Render**, en `frost-puno.onrender.com`.
> - El **cliente web Flutter** está en **Vercel**, en `frost-puno.vercel.app`.
> - La **base de datos** es **Supabase**, PostgreSQL gestionado.
> - Y además compilamos un **APK de Android** que consume la misma API.
>
> Los cuatro se comunican por HTTP y cada uno puede escalarse o reemplazarse sin tocar a los
> otros."

## A.2 Infraestructura como código (30 s)

*Muestra `render.yaml`.*

> "El despliegue del backend no se hace a mano: está declarado como **infraestructura como
> código** en `render.yaml`. Ahí definimos el runtime Python 3.11, el comando de build, el
> arranque con Uvicorn y un **health check** en `/health`.
>
> Tiene **autoDeploy activado**: cada merge a la rama principal redespliega automáticamente.
> Lo mismo hace Vercel con el cliente web.
>
> Las variables sensibles, como la clave de Supabase, están marcadas como `sync: false`:
> **nunca se suben al repositorio**, se cargan solo en el panel del servidor. El cliente
> Flutter recibe únicamente la URL pública de la API."

## A.3 Una lección real de producción (30 s) — *esto impresiona*

> "Quiero contar un problema real que tuvimos, porque es el tipo de cosa que un equipo de TI
> necesita saber.
>
> Cuando migramos el modelo a K-Means, hicimos el merge, Render redesplegó correctamente...
> y la API **seguía sirviendo el modelo anterior**.
>
> La causa: las variables de entorno definidas **manualmente en el panel de Render tienen
> prioridad** sobre las declaradas en `render.yaml`. Las rutas del modelo viejo seguían
> fijadas ahí. Hasta corregirlas en el panel, el archivo de configuración no tenía efecto.
>
> Lo documentamos en el informe como consideración crítica de despliegue."

---

# PARTE B — INTEGRACIÓN CONTINUA Y MANTENIMIENTO (2:00)

## B.1 Los cinco pipelines (25 s)

*Muestra la pestaña Actions.*

> "Pasando a la automatización: tenemos **cinco workflows** en GitHub Actions que corren **en
> paralelo** ante cada push:
>
> - **ML Training**: ingesta el clima, construye las características y entrena el modelo.
> - **Model Quality Gate**: la barrera de calidad.
> - **Backend Tests**: doce pruebas de la API.
> - **Data Validation**: valida datasets y agrupación de distritos.
> - **Flutter Build**: analiza, prueba y compila el cliente web."

## B.2 El modelo se reentrena solo (35 s)

> "El enunciado pide mantener también el **elemento inteligente**, no solo el código.
>
> El workflow de entrenamiento tiene un disparo **por cron, semanal**: nadie tiene que
> acordarse de reentrenar, ocurre solo.
>
> Y hay algo más: implementamos un **reentrenamiento adaptativo**. El script descarga datos
> frescos, reentrena y mide la calidad. Si la métrica **no alcanza el objetivo**, en vez de
> rendirse **amplía la ventana de datos** —de 14 a 29 a 44 días— y vuelve a intentar.
>
> Cada corrida queda registrada en un **historial de entrenamiento** con la fecha, los días de
> datos usados, el tamaño del dataset y la métrica obtenida. Ese historial es la evidencia de
> que el modelo **sigue aprendiendo y mejora con más datos**."

## B.3 El quality gate: la barrera (20 s)

> "Ahora, reentrenar automáticamente es peligroso sin control: un modelo nuevo podría ser
> **peor** que el que está en producción.
>
> Por eso existe el **quality gate**. Antes de promover cualquier modelo se verifica su
> silhouette. Si está por debajo de **0.35**, el gate **falla con código de error 1** y la
> integración se detiene. El modelo malo nunca llega a producción."

## B.4 DEMOSTRACIÓN EN VIVO (30 s) — *tu momento fuerte*

**Comando 1 — el modelo actual pasa:**
```bash
python -m ml_pipeline.registry.check_cluster_quality --min-silhouette 0.35
```
> "Con el umbral real, nuestro modelo tiene 0.419 y responde **QUALITY GATE PASSED**."

**Comando 2 — simulamos un modelo malo:**
```bash
python -m ml_pipeline.registry.check_cluster_quality --min-silhouette 0.99
```
> "Y si exigimos un umbral que no cumple, responde **QUALITY GATE FAILED** con código de error
> 1. Eso es exactamente lo que detendría el pipeline en GitHub Actions."

## B.5 Pruebas del mantenimiento (30 s)

```bash
python -m pytest ml_pipeline/tests/test_maintenance_ci.py -v
```

> "Pero no basta con decir que el mantenimiento funciona: lo **probamos**. Seis pruebas
> automatizadas corren dentro de la integración continua y verifican:
>
> 1. Que el reentrenamiento deja modelo, metadata y agrupación de distritos.
> 2. Que el modelo guardado **se puede cargar e inferir** — el contrato con el backend sigue vivo.
> 3. Que los 13 distritos quedan en un nivel de riesgo válido.
> 4. Que la metadata documenta la búsqueda de hiperparámetros y la configuración elegida es la
>    mejor del grid.
> 5. Que el quality gate **aprueba** el modelo de producción.
> 6. Y la más importante: que el quality gate **bloquea un modelo degradado**. La prueba
>    fabrica una metadata con silhouette 0.10 y verifica que el gate devuelve error.
>
> Es decir: tenemos una prueba automatizada que verifica que **nuestra propia barrera de
> seguridad funciona**.
>
> Le devuelvo la palabra a Joseph para el cierre."

---

## Preguntas probables

**"¿Por qué Render y Vercel y no todo en un servidor?"**
> "Separación de responsabilidades: Vercel sirve el cliente estático por CDN global y Render
> corre el proceso Python con el modelo en memoria. Además ambos tienen plan gratuito,
> adecuado para un proyecto académico."

**"¿Qué pasa si el reentrenamiento genera un modelo peor?"**
> "No se promueve. El quality gate lo bloquea y el modelo anterior sigue sirviendo. Además
> queda registrado en el historial de entrenamiento para analizarlo."

**"¿El cron realmente corre o solo está configurado?"**
> "Está configurado como `schedule` semanal y se puede ver en la pestaña Actions, donde
> aparecen las ejecuciones programadas además de las disparadas por push."

**"¿Por qué el umbral es 0.35?"**
> "Nuestro modelo está en 0.419. Pusimos 0.35 como piso: da margen para variaciones normales
> entre reentrenamientos, pero bloquea una degradación real. Es configurable por variable de
> entorno."

**"¿Qué pasa si Render se cae o tarda?"**
> "El plan gratuito duerme el servicio tras un tiempo sin tráfico, así que la primera petición
> puede tardar unos segundos. Está documentado como limitación y la app muestra un estado
> degradado en vez de romperse."
