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
> altiplano de Puno. El equipo lo integramos **Juan Lipe Machaca, Jhoel Ticona Erquinigo,
> Paul Tapara Ccahuana** y yo, **Joseph Mamani Mendoza**.
>
> Yo voy a presentar el problema y la arquitectura; luego Juan explicará el modelo, Jhoel
> hará la demostración de la aplicación, y Paul cerrará con el despliegue y la
> automatización."

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
> Le dejo la palabra a **Juan**, que va a explicar el dataset y el modelo."

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
> bloqueo funciona. Paul lo demostró en vivo."

## Checklist antes de exponer
- [ ] Abrir el backend unos minutos antes (Render Free se duerme).
- [ ] Tener listas las pestañas: web, `/docs`, GitHub Actions.
- [ ] Repositorio a mano por si piden ver el código.
- [ ] **Diapositivas**: `docs/presentacion/FrostPuno_Joseph.pptx` (y el PDF de respaldo).
- [ ] **Hoja de inglés impresa**: `docs/guiones/JOSEPH_hoja_ingles.md`.

---

# CÓMO EXPONER PRESENCIALMENTE

## Antes de entrar (30 min)

- **Despierta el backend.** Abre https://frost-puno.onrender.com/health desde el celular.
  Render Free duerme el servicio y la primera carga tarda ~30 s: si lo despiertas antes,
  en vivo responde al instante.
- **Lleva todo por duplicado**: el `.pptx` y el **PDF** en una USB, y una copia en tu
  correo o Drive. Si la laptop del aula no tiene PowerPoint, el PDF siempre abre.
- **Prueba el proyector antes** si te dejan. Conecta, verifica que se vea el 16:9 completo
  (que no corte los bordes) y que los colores oscuros no se vean lavados.
- **Pantalla extendida, no espejada**, si usas modo presentador: tú ves tus notas, el
  jurado ve solo la diapositiva. Si el aula complica, usa **espejada** y no dependas de
  las notas: por eso tu guion está memorizado en 5 ideas, no en párrafos.
- **Cierra notificaciones** (WhatsApp de escritorio, correo). Modo avión en el celular si
  lo usas para mostrar el APK.
- **Ten el APK instalado en un celular** por si piden ver la app Android.

## Durante tu intervención

- **Dónde pararte**: a un costado de la pantalla, no delante. Si el proyector te da en la
  cara, un paso adelante y hacia el lado.
- **No leas la diapositiva.** El jurado ya la lee solo. Tú cuentas lo que **no** está
  escrito. Tus slides tienen poco texto justamente para eso.
- **No des la espalda.** Mira la pantalla máximo 2 segundos para ubicarte, y vuelve al
  jurado. Señala con la mano abierta, no con el dedo.
- **Reparte la mirada**: elige tres puntos (izquierda, centro, derecha) y ve rotando. No te
  quedes mirando solo al docente.
- **Pausa después de cada cifra.** Cuando digas "3 800 metros" o "0.419", **calla un
  segundo**. Ese silencio hace que el número se registre; si sigues de largo, se pierde.
- **Manos**: sueltas o sosteniendo el clicker/hoja. No en los bolsillos, no cruzadas, no
  jugando con el lapicero.
- **Ritmo**: tienes 2 minutos de apertura. Es poco. Si notas que vas lento, salta el
  detalle de la arquitectura y quédate con las cuatro piezas y el contrato de features.
- **Al pasar la palabra**, di el nombre y qué viene: *"Le dejo la palabra a Juan, que va a
  explicar el modelo."* Y **da un paso al costado**. El relevo se nota tanto como el
  contenido.

## Plan B

| Si falla… | Qué haces |
|---|---|
| No hay internet | No abras la app en vivo. Usa las **capturas de las diapositivas** — ya muestran el modelo real (0.419, K-Means). Dilo con naturalidad: "lo mostramos con capturas del sistema en producción". |
| El proyector no conecta | Abre el **PDF en el celular** y, si el jurado es cercano, expón con el equipo alrededor. Nunca improvises sin apoyo visual. |
| Render está dormido y la demo tarda | Sigue hablando mientras carga. Nunca te quedes en silencio mirando la pantalla: "mientras el servicio despierta —es plan gratuito, se suspende por inactividad— les comento que…". |
| Se te olvida una parte | Salta a la siguiente diapositiva. Nadie sabe lo que ibas a decir. Si lo recuerdas después, lo agregas al cierre. |
| Una diapositiva no se ve bien | No pidas disculpas dos veces. Una frase y sigues. |

## Manejo de preguntas

- **Repite la pregunta antes de responder.** Ganas 3 segundos para pensar, confirmas que
  entendiste y el resto del jurado la escucha. *"La pregunta es por qué elegimos K-Means y
  no otro algoritmo…"*
- **Responde lo que te preguntaron**, no todo lo que sabes. Frase corta, y si quieren más,
  preguntan.
- **Si no sabes**: *"Eso lo documentamos como limitación en el informe"* o *"Esa parte la
  trabajó mi compañero, ¿puede responder él?"*. **Nunca inventes un dato.** Un número
  inventado que el jurado detecta cuesta más que un "no lo medimos".
- **Si te corrigen y tienen razón**: *"Tiene razón, lo anotamos"*. Se acabó. No discutas.
- Las preguntas más probables ya están respondidas al final de este guion.
