# Guion — HÉCTOR LUIS FLORES CURASI
## Rol: Despliegue y puesta en producción

**Tiempo: ~2 min** — Vale **2 puntos** de "Despliegue de la aplicación" y aporta al
"Informe técnico" (consideraciones de despliegue inicial).

**Repositorio:** https://github.com/JosephElvisMaman1/frost-puno

**Ten abierto:** `render.yaml`, el dashboard de Render y la app en Vercel.

---

## 1. Dónde vive cada pieza (30 s)

> "Gracias. Yo explico cómo está desplegado el sistema.
>
> No es un proyecto local: cada componente está en una plataforma distinta, en la nube:
>
> - El **backend FastAPI** corre en **Render**, en `frost-puno.onrender.com`.
> - El **cliente web Flutter** está en **Vercel**, en `frost-puno.vercel.app`.
> - La **base de datos** es **Supabase**, PostgreSQL gestionado.
> - Y además compilamos un **APK de Android** que consume la misma API.
>
> Los cuatro se comunican por HTTP, y cada uno puede escalarse o reemplazarse sin tocar a los
> otros."

## 2. Infraestructura como código (35 s)

*Muestra `render.yaml`.*

> "El despliegue del backend no se hace a mano: está declarado como **infraestructura como
> código** en el archivo `render.yaml`.
>
> Ahí definimos el runtime **Python 3.11**, el comando de build que instala las dependencias,
> el comando de arranque con **Uvicorn**, y un **health check** en la ruta `/health` para que
> Render sepa si el servicio está sano.
>
> Y tiene **autoDeploy activado**: cada vez que se hace merge a la rama principal, Render
> redespliega automáticamente. Lo mismo hace Vercel con el cliente web.
>
> Las variables sensibles, como la clave de servicio de Supabase, están marcadas como
> `sync: false`: **nunca se suben al repositorio**, se cargan solo en el panel del servidor."

## 3. Una lección real que aprendimos (30 s) — *esto impresiona, es experiencia de producción*

> "Quiero contar un problema real que tuvimos, porque es justo el tipo de cosa que un equipo
> de TI necesita saber.
>
> Cuando migramos el modelo a K-Means, hicimos el merge, Render redesplegó correctamente...
> y la API **seguía sirviendo el modelo anterior**.
>
> La causa: las variables de entorno definidas **manualmente en el panel de Render tienen
> prioridad** sobre las declaradas en `render.yaml`. Las rutas del modelo viejo seguían
> fijadas ahí. Hasta corregirlas en el panel, el archivo de configuración no tenía efecto.
>
> Lo documentamos en el informe como consideración crítica de despliegue."

## 4. Configuración del cliente (25 s)

> "En el cliente Flutter, la URL del backend **no está escrita en el código**. Se inyecta al
> compilar con el parámetro `--dart-define`:
>
> - Para la web en Vercel, apunta al backend de Render.
> - Para desarrollo local, a localhost.
> - Para el emulador Android, a la IP especial del emulador.
>
> Así el mismo código sirve para todos los entornos, sin ramas ni condicionales."

## 5. Orden de puesta en marcha (20 s)

> "Para levantar el sistema desde cero, el orden es:
>
> 1. **Entrenar y publicar el modelo** en el registry.
> 2. **Desplegar la API** y verificar que `/health` y `/ml/model-info` respondan con el modelo
>    correcto.
> 3. **Desplegar el cliente** con la URL de esa API.
> 4. Opcionalmente activar Supabase: si está apagado, el sistema funciona igual con un
>    repositorio en memoria — así corren también nuestras pruebas automatizadas.
>
> Le paso la palabra a [compañero 5] para la integración continua."

---

## Preguntas probables

**"¿Por qué Render y Vercel y no todo en un solo servidor?"**
> "Por separación de responsabilidades y porque cada plataforma está optimizada para lo suyo:
> Vercel sirve el cliente estático por CDN global, y Render corre el proceso Python con el
> modelo cargado en memoria. Además ambos tienen plan gratuito, que es lo adecuado para un
> proyecto académico."

**"¿Qué pasa si Render se cae o tarda?"**
> "El plan gratuito duerme el servicio tras un tiempo sin tráfico, así que la primera petición
> puede tardar unos segundos. Está documentado como limitación. La app maneja el error y
> muestra un estado degradado en vez de romperse."

**"¿Cómo protegen las credenciales?"**
> "La clave de servicio de Supabase solo existe en el panel de Render, marcada como no
> sincronizable. El cliente Flutter únicamente recibe la URL pública de la API — nunca toca
> credenciales de base de datos."
