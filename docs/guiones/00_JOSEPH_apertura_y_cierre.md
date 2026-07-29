# Guion — JOSEPH ELVIS MAMANI MENDOZA
## Rol: Autor y presentador principal — Apertura, arquitectura y cierre

**Tiempo total: ~3 min** (abres los primeros 2 min y cierras el último 1 min).
Eres quien abre y cierra: presentas el problema, el producto y la arquitectura, y al final
recoges todo. Es la parte más visible y la más fácil de defender: **no tienes que explicar
fórmulas**, tú cuentas el *qué* y el *porqué*.

**Repositorio:** https://github.com/JosephElvisMaman1/frost-puno

---

## PARTE 1 — Apertura (al inicio, ~2 min)

### 1.1 Presentación (20 s)

> "Buenas tardes. Presentamos **FrostPuno**, un sistema de predicción de heladas para el
> altiplano de Puno. El equipo somos [nombres]. Yo soy Joseph Mamani y voy a presentar el
> problema y la arquitectura; luego mis compañeros explicarán el modelo, el despliegue y
> la automatización."

### 1.2 El problema (40 s) — *esto es lo que engancha al jurado*

> "En Puno, por encima de los tres mil ochocientos metros, las heladas tienen dos caras.
>
> Por un lado **destruyen**: dañan los cultivos y matan crías de alpaca y ovino, que son el
> patrimonio de las familias altoandinas.
>
> Por otro lado, esas mismas heladas **son necesarias**: son el insumo del **chuño**, la papa
> deshidratada que se conserva por años y que es seguridad alimentaria para la región.
>
> El problema es que hoy esas decisiones —¿tapo el cultivo?, ¿guardo el ganado?, ¿tiendo la
> papa?— se toman por experiencia empírica, sin información climática integrada. FrostPuno
> convierte datos abiertos de clima en decisiones concretas para el poblador."

### 1.3 Qué construimos (30 s)

> "Construimos una aplicación con **elementos inteligentes**: la lógica de negocio no está
> escrita como reglas fijas, sino que se operativiza a través de un **modelo de aprendizaje
> no supervisado** que descubre por sí solo los patrones climáticos de la región.
>
> Y no es una maqueta: está **desplegada en producción**, funcionando ahora mismo en la web
> y como aplicación Android, con procesos de mantenimiento automatizados."

### 1.4 Arquitectura (30 s) — *muestra el diagrama o el CLAUDE.md*

> "La arquitectura tiene cuatro piezas conectadas:
>
> - Un **pipeline de machine learning** en Python que ingesta el clima y entrena el modelo.
> - Un **registry** donde queda guardado el modelo entrenado con su metadata.
> - Una **API en FastAPI**, desplegada en Render, que carga ese mismo modelo y sirve las
>   predicciones.
> - Y un **cliente Flutter**, en Vercel y como APK Android, que consume esa API.
>
> La clave del diseño es que la **lista de características del modelo es el contrato** entre
> el pipeline y el backend: si cambian las variables, el metadata lo declara y el backend se
> adapta. Con eso, reentrenar no obliga a tocar el código del servidor.
>
> Le dejo la palabra a [compañero 2], que va a explicar el modelo."

---

## PARTE 2 — Cierre (al final, ~1 min)

### 2.1 Limitaciones — *decirlas suma, no resta* (30 s)

> "Antes de cerrar, queremos ser explícitos con las limitaciones, porque un informe técnico
> honesto vale más que uno perfecto:
>
> - Los niveles de riesgo salen del **perfil térmico de cada grupo**, no de un registro
>   oficial de heladas observadas: no existe ese dataset etiquetado para estos distritos.
> - **SENAMHI** es nuestra fuente oficial prioritaria, pero no expone una API pública
>   estable, así que Open-Meteo es la fuente operativa real. Está documentado en el código
>   y en la app.
> - Los umbrales de chuño y de ganado son **diseño de MVP documentado con fuentes**, no
>   cifras oficiales.
>
> Ninguna de estas limitaciones invalida la arquitectura ni el ciclo de vida que mostramos."

### 2.2 Conclusión (30 s)

> "En resumen, FrostPuno cumple lo que pedía la unidad:
>
> - Una aplicación con **elementos inteligentes** basados en aprendizaje **no supervisado**.
> - **Desplegada en producción**, accesible desde la web y desde un APK Android.
> - Con **mantenimiento e integración continua automatizados**: el modelo se reentrena solo,
>   registra su historial de calidad y está protegido por un quality gate que **probamos que
>   bloquea** un modelo degradado.
>
> Y, sobre todo, resuelve un problema real de nuestra región. Muchas gracias — quedamos
> atentos a sus preguntas."

---

## Preguntas probables (tú las respondes)

**"¿Por qué no usaron aprendizaje supervisado?"**
> "El enunciado de la unidad pide no supervisado o refuerzo. Además, en nuestro caso no
> existe un dataset etiquetado de heladas observadas por distrito, así que un supervisado
> tendría que inventarse las etiquetas con reglas — que es justamente lo que queríamos
> evitar. El clustering descubre la estructura sin necesitar etiquetas."

**"¿Esto realmente funciona o es una demo?"**
> "Está en producción. La API responde en frost-puno.onrender.com y la web en
> frost-puno.vercel.app. Podemos abrirlas ahora mismo."

**"¿Y si el modelo empeora con el tiempo?"**
> "Ese fue justo uno de nuestros focos. Hay un quality gate que bloquea cualquier modelo con
> silhouette por debajo de 0.35, y tenemos una prueba automatizada que verifica que ese
> bloqueo funciona. [Compañero 4] lo demostró."

## Checklist antes de exponer
- [ ] Abrir el backend unos minutos antes (Render Free se duerme).
- [ ] Tener listas las pestañas: web, `/docs`, GitHub Actions.
- [ ] Repositorio a mano por si piden ver el código.
