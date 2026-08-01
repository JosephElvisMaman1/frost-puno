# Guion — JOSEPH: DESPLIEGUE Y PUESTA EN PRODUCCIÓN
## (~2 min · vale 2 pts de "Despliegue de la aplicación")

Tú lo desplegaste, así que habla **en primera persona**. Ten abierto: `render.yaml`,
y de respaldo https://frost-puno.onrender.com/health y https://frost-puno.vercel.app

---

## 1. Dónde vive cada pieza (30 s)

> "Voy a explicar cómo está desplegado el sistema. No es un proyecto local: cada
> componente está en la nube, en una plataforma distinta:
>
> - El **backend FastAPI** corre en **Render**, en `frost-puno.onrender.com`.
> - El **cliente web Flutter** está en **Vercel**, en `frost-puno.vercel.app`.
> - La **base de datos** es **Supabase**, PostgreSQL gestionado.
> - Y además compilé un **APK de Android** que consume la misma API.
>
> Los cuatro se comunican por HTTP y cada uno puede escalarse o reemplazarse sin tocar a
> los otros."

## 2. Infraestructura como código (35 s)

*Muestra `render.yaml`.*

> "El despliegue del backend no se hace a mano: lo declaré como **infraestructura como
> código** en el archivo `render.yaml`.
>
> Ahí está definido el runtime **Python 3.11**, el comando de build que instala las
> dependencias, el arranque con **Uvicorn**, y un **health check** en la ruta `/health`
> para que Render sepa si el servicio está sano.
>
> Y tiene **autoDeploy activado**: cada vez que hago merge a la rama principal, Render
> redespliega automáticamente. Lo mismo hace Vercel con el cliente web.
>
> Las credenciales, como la clave de servicio de Supabase, están marcadas `sync: false`:
> **nunca se suben al repositorio**. El cliente Flutter solo recibe la URL pública de la
> API."

## 3. Una lección real que me pasó (30 s) — *esto impresiona*

> "Les cuento un problema real que tuve, porque es lo que un equipo de TI necesita saber.
>
> Cuando migré el modelo a K-Means, hice el merge, Render redesplegó correctamente...
> y la API **seguía sirviendo el modelo anterior**.
>
> La causa: las variables de entorno definidas **manualmente en el panel de Render tienen
> prioridad** sobre las del archivo `render.yaml`. Las rutas del modelo viejo seguían
> fijadas en el panel. Hasta corregirlas ahí, el archivo no tenía efecto.
>
> Lo documenté en el informe como consideración crítica de despliegue."

## 4. Configuración del cliente y puesta en marcha (25 s)

> "En el cliente Flutter, la URL del backend **no está en el código**: se inyecta al
> compilar con `--dart-define`. El mismo código sirve para web, para desarrollo local y
> para el APK, solo cambia ese parámetro.
>
> El orden de puesta en marcha desde cero es: entrenar y publicar el modelo, desplegar la
> API y verificar `/health` y `/ml/model-info`, desplegar el cliente apuntando a esa API,
> y opcionalmente activar Supabase — si está apagado, el sistema funciona igual con un
> repositorio en memoria, que es como corren las pruebas en integración continua."

---

## Preguntas probables

**"¿Por qué Render y Vercel y no un solo servidor?"**
> "Separación de responsabilidades: Vercel sirve el cliente estático por CDN global y
> Render corre el proceso Python con el modelo cargado en memoria. Y ambos tienen plan
> gratuito, adecuado para un proyecto académico."

**"¿Qué pasa si Render se cae o tarda?"**
> "El plan gratuito duerme el servicio tras inactividad; la primera petición tarda unos
> segundos mientras despierta. Está documentado como limitación y la app muestra un estado
> degradado en vez de romperse."

**"¿Cómo protegen las credenciales?"**
> "La clave de servicio de Supabase existe solo en el panel de Render, marcada como no
> sincronizable. El cliente nunca toca credenciales: solo conoce la URL pública de la API."

**"¿El APK apunta a qué servidor?"**
> "Al backend de producción en Render. Se compila con
> `flutter build apk --release --dart-define=API_BASE_URL=https://frost-puno.onrender.com`."

---

## Chuleta (por si solo puedes ver esto)

- Render = API FastAPI (`render.yaml`, health check `/health`, autoDeploy)
- Vercel = Flutter web · Supabase = PostgreSQL · APK = misma API
- Secretos: `sync: false`, nunca en el repo
- Anécdota: panel de Render **gana** a `render.yaml` → modelo viejo servido hasta corregir
- Cliente: `--dart-define=API_BASE_URL`, nada hardcodeado
- Arranque: modelo → API (/health) → cliente → Supabase opcional
