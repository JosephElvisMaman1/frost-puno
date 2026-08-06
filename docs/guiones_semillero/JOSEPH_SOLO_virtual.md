# Exposición del semillero — Joseph solo, modalidad virtual

Expones tú solo compartiendo pantalla. Duración objetivo: **10 a 12 minutos**.
Diapositivas: `docs/presentacion/FrostPuno_Semillero.pptx` (10 slides) y su PDF de respaldo.

---

## ANTES DE ENTRAR (10 minutos antes)

1. **Despierta el backend.** Abre https://frost-puno.onrender.com/health y espera a que
   responda. El plan gratuito suspende el servicio y la primera carga tarda unos 30 s. Si
   no lo haces, la demo en vivo se cuelga delante de todos.
2. **Abre estas pestañas en este orden** (las vas a ir mostrando):
   - 1: Las diapositivas en modo presentación
   - 2: https://frost-puno.vercel.app
   - 3: https://frost-puno.onrender.com/docs
   - 4: https://github.com/JosephElvisMaman1/frost-puno/actions
   - 5: El editor con `ml_pipeline/data_ingestion/ingest_weather_open_meteo.py` abierto
3. **Cierra todo lo demás.** WhatsApp de escritorio, correo, notificaciones. Se ven cuando
   compartes pantalla.
4. **Comparte pantalla completa, no una ventana.** Si compartes solo una ventana, al
   cambiar de pestaña el público se queda mirando la anterior.
5. Prueba tu micrófono. Si puedes, cámara encendida al inicio y al cierre.

---

## GUION CON QUÉ MOSTRAR

### 1. Portada (20 s) — MUESTRA: diapositiva 1

> "Buenas tardes. Presento el trabajo del semillero: **FrostPuno, arquitectura distribuida
> y cómputo paralelo para la predicción de heladas mediante aprendizaje no supervisado en
> el altiplano de Puno**.
>
> Soy Joseph Mamani y expongo en nombre del equipo, que integramos junto a Yimmy Pari,
> Jahan Quispe, Héctor Flores y Yoel Apaza."

### 2. El problema (1:10) — MUESTRA: diapositiva 2

> "Empiezo por el problema, porque explica todo lo demás.
>
> En el altiplano, por encima de los tres mil ochocientos metros, las heladas tienen dos
> caras.
>
> Por un lado **destruyen**: dañan los cultivos de la campaña y matan crías de alpaca y
> ovino, que son el patrimonio de las familias altoandinas.
>
> Por otro lado son **necesarias**: son el insumo del **chuño**, la papa deshidratada por
> congelamiento nocturno que se conserva por años y es seguridad alimentaria de la región.
> *(señala la captura del módulo de chuño a la derecha)*
>
> El problema es que la decisión de proteger el cultivo, resguardar el ganado o tender la
> papa se toma por experiencia, sin datos integrados. *(pausa)*
>
> Y no es solo un problema de modelado: hay que recolectar datos de muchas ubicaciones,
> servirlos rápido a usuarios dispersos y mantener el sistema vivo sin que nadie lo esté
> vigilando. Ahí entra el cómputo paralelo y distribuido."

### 3. Las tres contribuciones (40 s) — MUESTRA: diapositiva 3

> "El paper declara tres contribuciones, y las voy a recorrer en ese orden.
>
> **Primera**: una ingesta paralela por hilos con aislamiento de fallos por distrito.
>
> **Segunda**: una arquitectura distribuida en cuatro servicios autónomos, cada uno en un
> proveedor distinto.
>
> **Tercera**: un mantenimiento automatizado del modelo, ejecutado como trabajos
> concurrentes y protegido por una barrera de calidad."

### 4. Arquitectura (1:10) — MUESTRA: diapositiva 4, luego PESTAÑA 3 (/docs)

> "La arquitectura tiene cuatro componentes y cada uno vive en una plataforma distinta. No
> es una separación lógica dentro de un mismo proceso: es distribución real.
>
> El cliente Flutter en Vercel y como APK. La API FastAPI en Render. La base de datos en
> Supabase. Y la fuente climática, Open-Meteo, que es externa.
>
> Lo que los desacopla está abajo: **la lista de características declarada en el metadata
> del modelo**. El backend arma el vector en ese orden, así que cuando reentrenamos el
> modelo no hay que tocar el código del servidor. Ese contrato es la frontera del sistema."

*Cambia a la PESTAÑA 3, la documentación de la API.*

> "Y esto no es un diagrama de intenciones. Este es el contrato REST publicado por el
> servicio, en producción, ahora mismo."

*Vuelve a las diapositivas.*

### 5. Paralelismo en la ingesta (2:00) — MUESTRA: diapositiva 5, luego PESTAÑA 5 (código)

> "Esta es la primera contribución y la más ligada al curso.
>
> Para construir el conjunto de datos necesitamos el clima horario de **trece distritos**.
> Cada solicitud es independiente: pedir el clima de Juliaca no depende de Macusani. Y el
> costo está dominado por la **latencia de red**, no por el procesador: el programa pasa
> casi todo el tiempo esperando.
>
> Tareas independientes más espera de entrada y salida es exactamente el caso donde el
> paralelismo por hilos rinde.
>
> El código hace dos cosas *(señala el bloque oscuro)*. Primero **dispersa**: envía trece
> tareas al pool. Después **recolecta** conforme van terminando, no en el orden en que se
> enviaron. Es el patrón fan-out y fan-in.
>
> Y quiero que se fijen en un detalle: **dónde está el manejo de excepciones**. Está
> dentro del bucle, por tarea. Eso significa que si un distrito falla, los demás
> continúan, y ese fallo queda registrado individualmente. *(pausa)* No perdemos toda la
> ingesta por una ubicación caída.
>
> A la derecha están las cuatro propiedades: fan-out y fan-in, aislamiento de fallos,
> paralelismo configurable, y el rendimiento. Sobre esto último: al ser una carga de
> entrada y salida, el tiempo total ya no es trece veces el tiempo de una solicitud, sino
> que tiende al tiempo de **una sola**. Es consistente con la ley de Amdahl: la ganancia
> está acotada por la fracción del trabajo que se puede paralelizar, y aquí esa fracción
> es casi todo."

*Opcional, si te sobra tiempo: cambia a la PESTAÑA 5 y muestra el archivo real.*

> "Este es el código, en el repositorio."

### 6. Cómputo de aprendizaje distribuido (1:10) — MUESTRA: diapositiva 6

> "La segunda pieza distribuida está en cómo separamos el cómputo del modelo.
>
> Hay dos cómputos con exigencias opuestas. El **entrenamiento** es pesado: recorre una
> búsqueda de veinticuatro combinaciones de hiperparámetros. Se ejecuta por lotes, fuera
> de línea, una vez por semana.
>
> La **inferencia** tiene que responder ya. El servicio carga el modelo una sola vez por
> proceso y, ante cada solicitud, solo asigna el vector climático al centroide más
> cercano. Es una operación proporcional al número de grupos, o sea a tres. Muy barata.
>
> En el medio está el **registro de modelos**, que guarda el artefacto y su metadata. Ese
> es el patrón estándar en sistemas distribuidos de aprendizaje automático."

### 7. El modelo (1:30) — MUESTRA: diapositiva 7, luego PESTAÑA 2 (app, sección Zonas)

> "Sobre el modelo. Usamos **K-Means**, aprendizaje no supervisado: no le damos etiquetas,
> descubre solo la estructura.
>
> Y aquí está el hallazgo que más nos gustó. Empezamos con **ocho variables**. Al medir la
> calidad del agrupamiento vimos que la precipitación, el viento, la nubosidad y la
> temperatura aparente **degradaban** la separación de los grupos.
>
> Al quitarlas, el coeficiente de silueta subió de **0.286 a 0.419**. *(pausa)* Mejoramos
> el modelo **quitando** información, no agregándola.
>
> Las métricas finales: silueta 0.419, Davies-Bouldin 0.813, sobre una búsqueda de
> veinticuatro combinaciones.
>
> Y el resultado es interpretable: Macusani, a 4315 metros, queda en riesgo alto. Sandia,
> que está en valle a 2170 metros, queda en riesgo bajo. **Nadie escribió esa regla.**"

*Cambia a la PESTAÑA 2, entra a la sección Zonas de la aplicación.*

> "Y esto está funcionando. Esta es la aplicación en producción: tres clusters, silueta
> cero punto cuatro uno nueve, modelo K-Means. Los mismos números del paper, sirviéndose
> en vivo."

*Vuelve a las diapositivas.*

### 8. Mantenimiento e integración continua (1:40) — MUESTRA: diapositiva 8, luego PESTAÑA 4 (Actions)

> "La tercera contribución. Cuando un sistema tiene un componente de aprendizaje, el
> mantenimiento no es solo del código: hay que reentrenar, versionar y controlar calidad.
> Si eso es manual, el sistema se degrada apenas nadie se ocupa.
>
> Tenemos **cinco flujos** que corren de forma concurrente ante cada cambio. Como no
> dependen entre sí, el tiempo total es el del flujo **más lento**, no la suma. Es
> paralelismo aplicado al proceso, no solo al cálculo.
>
> El reentrenamiento es **adaptativo**: si la calidad no alcanza el objetivo, en lugar de
> rendirse amplía la ventana de datos, de catorce a veintinueve y luego a cuarenta y
> cuatro días, y reintenta.
>
> Y está la **barrera de calidad**: si la silueta baja de 0.35, el proceso termina con
> código de error y la integración se detiene. El modelo malo no llega a producción.
>
> Pero aquí está lo importante *(pausa)*: **la existencia de la barrera no demuestra que
> funcione**. Por eso tenemos seis pruebas automatizadas, y una de ellas construye
> deliberadamente un modelo degradado y verifica que la barrera lo bloquea. Es decir,
> tenemos una prueba que verifica que nuestra propia red de seguridad funciona."

*Cambia a la PESTAÑA 4, GitHub Actions.*

> "Estos son los flujos ejecutándose, en verde."

*Vuelve a las diapositivas.*

### 9. Resultados (50 s) — MUESTRA: diapositiva 9

> "Los resultados verificados: doce pruebas del servicio, seis de mantenimiento, la
> barrera aprobada con 0.419, el cliente web y la aplicación Android compilando, y el
> modelo en producción es K-Means versión uno punto cero.
>
> Del lado del usuario, la aplicación entrega alerta diaria con umbral configurable, aviso
> diferenciado para ganado, detección de eventos inusuales, el agrupamiento territorial,
> el módulo de chuño e histórico climático."

### 10. Limitaciones y cierre (1:10) — MUESTRA: diapositiva 10

> "Antes de cerrar, las limitaciones, porque un trabajo honesto se defiende mejor.
>
> Los niveles de riesgo salen del perfil térmico de cada grupo, no de un registro oficial
> de heladas observadas, porque ese registro etiquetado no existe para estos distritos.
> SENAMHI está declarado como fuente prioritaria pero no tiene una API pública estable, así
> que Open-Meteo es la fuente operativa. Y los umbrales de chuño y ganado son diseño
> documentado con fuentes, no cifras oficiales.
>
> Ninguna de esas limitaciones invalida la arquitectura ni el paralelismo que mostramos.
>
> Para cerrar: aportamos una ingesta paralela con aislamiento de fallos, una arquitectura
> distribuida en cuatro servicios acoplados solo por contratos, y un mantenimiento
> automatizado cuya barrera está verificada por pruebas.
>
> El código fuente completo está público en el repositorio. Muchas gracias, quedo atento a
> sus preguntas."

---

## SI TE QUEDA CORTO O LARGO

| Situación | Qué hacer |
|---|---|
| Vas largo | Salta la demo en vivo de la sección 4 (`/docs`) y la de la 8 (Actions). Con las capturas de las diapositivas basta. |
| Vas corto | Abre el repositorio y muestra la estructura del proyecto, o entra al módulo de chuño en la app. |
| Se cae internet | Todo lo esencial está en las diapositivas: no dependes de la demo. Dilo con naturalidad y sigue. |
| Render no responde | "El servicio se suspende por inactividad en el plan gratuito, está despertando". Sigue hablando, no te quedes en silencio. |

---

## PREGUNTAS PROBABLES

**"¿Dónde está exactamente el cómputo paralelo?"**
> "En tres lugares: la ingesta con pool de hilos, la arquitectura distribuida en cuatro
> proveedores y los cinco flujos de integración continua que corren concurrentemente.
> Secciones IV, III y VII del paper."

**"¿Por qué hilos y no procesos?"**
> "Porque la carga depende de entrada y salida, no de procesador. Mientras un hilo espera
> la respuesta de red libera el intérprete. Si el cuello de botella fuera de cálculo, ahí
> sí convendrían procesos."

**"¿Midieron el speedup real?"**
> "No hicimos una medición formal de tiempos comparativos, es algo que podemos incorporar.
> Lo que afirmamos en el paper es el comportamiento esperado según la naturaleza de la
> carga."

**"¿Por qué no usaron aprendizaje supervisado?"**
> "Porque no existe un registro etiquetado de heladas observadas por distrito. Un modelo
> supervisado tendría que inventar las etiquetas con reglas, que es justo lo que queríamos
> evitar."

**"¿Un silueta de 0.419 es bueno?"**
> "Con datos reales y ruidosos, por encima de 0.4 se considera una estructura razonable.
> Partimos de 0.286 y llegamos ahí podando variables, y la barrera exige mínimo 0.35."

**"¿Cómo asignan alto, medio y bajo sin etiquetas?"**
> "Es un paso posterior al entrenamiento: ordeno los grupos por temperatura media y el más
> frío es el de mayor riesgo. Es describir los grupos que el algoritmo encontró, no
> supervisarlo."

**"¿Quién hizo qué en el equipo?"**
> "Yo desarrollé el sistema y el modelo; el trabajo de documentación, validación y
> redacción del artículo fue del equipo."
