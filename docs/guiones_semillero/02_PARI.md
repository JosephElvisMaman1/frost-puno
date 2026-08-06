# Guion — PARI PARI, YIMMY RONALDO
## Paralelismo en la ingesta de datos

Tiempo: 2:30. Hablas después de Joseph. Expones la **primera contribución** del paper y
la más directamente ligada al curso: el cómputo paralelo.

Sección del paper: IV. Ten a la vista el **Listado 1** (código de la ingesta).

---

## 1. Por qué esta carga se puede paralelizar (35 s)

> "Gracias Joseph. Yo explico el paralelismo en la ingesta de datos.
>
> Para construir el conjunto de entrenamiento necesitamos recolectar series climáticas
> horarias de **trece distritos**. Cada solicitud es independiente de las demás: pedir el
> clima de Juliaca no depende de haber pedido el de Macusani.
>
> Y hay un detalle importante: el costo de cada solicitud está dominado por la **latencia
> de red**, no por el procesador. El programa pasa la mayor parte del tiempo esperando la
> respuesta del servidor remoto.
>
> Esa combinación, tareas independientes y espera de entrada y salida, es exactamente el
> caso donde el **paralelismo por hilos** rinde. Si lo hiciéramos secuencialmente,
> estaríamos esperando trece veces una detrás de otra."

## 2. La implementación (50 s)

*Muestra el Listado 1 del paper.*

> "La implementación usa un **pool de hilos**. El código hace dos cosas.
>
> Primero **dispersa el trabajo**: construye un diccionario donde cada entrada es una
> tarea enviada al ejecutor, una por distrito. Ahí se lanzan las trece solicitudes.
>
> Segundo **recolecta los resultados** conforme van terminando, no en el orden en que se
> enviaron. Si el distrito que se pidió último responde primero, se procesa primero. Ese
> es el patrón de dispersión y recolección, o *fan-out* y *fan-in*.
>
> Y hay un tercer elemento que quiero destacar: fíjense **dónde está el manejo de
> excepciones**. Está dentro del bucle, por tarea. Eso significa que si un distrito falla,
> por ejemplo porque el servidor no responde, **los demás continúan** y ese fallo queda
> registrado individualmente con su código de distrito.
>
> Es tolerancia parcial a fallos: no perdemos toda la ingesta por una ubicación caída."

## 3. Propiedades y rendimiento (45 s)

> "El paper destaca cuatro propiedades:
>
> **Dispersión y recolección**, que ya expliqué.
>
> **Aislamiento de fallos** por ubicación.
>
> **Grado de paralelismo configurable**: el número de hilos es un parámetro, por defecto
> cuatro. Se ajusta según el ancho de banda disponible y las restricciones que imponga el
> proveedor de datos, porque tampoco conviene saturarlo.
>
> Y el **rendimiento**. Al ser una carga dependiente de entrada y salida, el tiempo total
> ya no es el número de distritos multiplicado por el tiempo de cada solicitud, sino que
> tiende al tiempo de **una sola** solicitud. *(pausa)* Ese comportamiento es consistente
> con la ley de Amdahl: la ganancia está acotada por la fracción del trabajo que
> efectivamente se puede paralelizar, y en este caso esa fracción es casi todo el proceso."

## 4. Cierre de tu parte (20 s)

> "En resumen: convertimos una recolección secuencial de trece ubicaciones en una
> operación paralela con aislamiento de fallos y grado de paralelismo ajustable.
>
> Le paso la palabra a **Jahan**, que explicará cómo se distribuye el cómputo del modelo."

---

## Preguntas probables

**"¿Por qué hilos y no procesos?"**
> "Porque la carga depende de entrada y salida, no de procesador. Mientras un hilo espera
> la respuesta de la red libera el intérprete, así que los hilos son suficientes y mucho
> más livianos que crear procesos. Si el cuello de botella fuera de cálculo, ahí sí
> convendrían procesos."

**"¿Por qué cuatro hilos y no trece?"**
> "Es un valor por defecto conservador para no saturar el servicio externo, que puede
> limitar la tasa de solicitudes. El parámetro es configurable, así que se puede subir si
> el proveedor lo permite."

**"¿Qué pasa si fallan varios distritos?"**
> "Cada fallo se registra por separado y el proceso continúa con los demás. Solo se
> detiene si no se obtuvo ningún resultado, en cuyo caso lanza un error explícito."

**"¿Midieron el speedup real?"**
> "No hicimos una medición formal de tiempos comparativos; es una de las cosas que
> podemos incorporar. Lo que sí afirmamos, y está en el paper, es el comportamiento
> esperado según la naturaleza de la carga."
