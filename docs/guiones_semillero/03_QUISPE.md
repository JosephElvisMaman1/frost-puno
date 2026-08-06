# Guion — QUISPE GALINDO, JAHAN KEVIN
## Distribución del cómputo de aprendizaje y modelo de agrupamiento

Tiempo: 2:30. Hablas después de Yimmy.

Secciones del paper: V (Distribución del cómputo) y VI (Modelo de agrupamiento).
Ten a la vista la **Tabla III** (selección de k) y la **Figura 3** (zonas de riesgo).

---

## 1. Separación entre entrenamiento e inferencia (45 s)

> "Gracias Yimmy. Yo explico cómo se distribuye el cómputo del modelo.
>
> El sistema separa dos tipos de cómputo con exigencias opuestas.
>
> El **entrenamiento** es intensivo y se ejecuta por lotes, fuera de línea. Recorre una
> búsqueda de veinticuatro combinaciones de hiperparámetros y guarda el resultado en un
> **registro de modelos**, junto con sus metadatos.
>
> La **inferencia** es lo contrario: tiene que responder rápido. El servicio carga ese
> mismo artefacto **una sola vez por proceso** y, ante cada solicitud, simplemente asigna
> el vector climático al centroide más cercano. Es una operación proporcional al número de
> grupos, o sea a tres. Muy barata.
>
> Ese patrón, entrenamiento por lotes e inferencia en línea intermediados por un registro,
> es el estándar en sistemas distribuidos de aprendizaje automático."

## 2. El contrato que une ambos extremos (25 s)

> "La pieza que articula los dos lados es la **lista de características** declarada en los
> metadatos del modelo.
>
> El servicio construye el vector de entrada siguiendo ese orden. Por eso, cuando el
> modelo se reentrena, **no hay que modificar el código del servidor**: el metadata declara
> qué variables espera y el servicio se adapta.
>
> Ese contrato es la frontera entre el subsistema de aprendizaje y el de servicio."

## 3. El modelo y la selección de características (40 s)

> "Sobre el modelo. Usamos **K-Means**, aprendizaje no supervisado, precedido de un
> escalado estandarizado que es necesario porque las variables tienen magnitudes muy
> distintas: la altitud está en miles de metros y la temperatura en decenas de grados.
>
> Empezamos con **ocho variables** climáticas. Al medir la calidad del agrupamiento
> encontramos que la precipitación, el viento, la nubosidad y la temperatura aparente
> introducían ruido o eran colineales, y **degradaban** la separación entre grupos.
>
> Al retirarlas, el coeficiente de silueta subió de **0.286 a 0.419**, cerca de un 47 por
> ciento de mejora. *(pausa)* Es decir, mejoramos el modelo **quitando** información, no
> agregándola.
>
> Quedaron cuatro variables con sentido físico para una helada: altitud, temperatura,
> punto de rocío y humedad relativa."

## 4. Evaluación y resultado interpretable (40 s)

*Muestra la Tabla III y la Figura 3.*

> "¿Cómo se evalúa un modelo sin etiquetas? No se puede usar exactitud ni F1, porque no
> existe una verdad de terreno de 'aquí hubo helada' para estos distritos. Se mide la
> calidad de la estructura descubierta.
>
> El coeficiente de silueta llega a **0.419** y el índice de Davies-Bouldin a **0.813**.
> Elegimos tres grupos porque gana en **ambas** métricas, y además coincide con los tres
> niveles de riesgo que necesita la aplicación.
>
> Y el resultado es interpretable: **Macusani**, a 4315 metros, queda en riesgo alto;
> **Sandia**, que está en valle a 2170 metros, queda en riesgo bajo. *(pausa)*
>
> Nadie escribió esa regla. El algoritmo la descubrió a partir del clima, y coincide con
> la geografía de la región.
>
> Le paso la palabra a **Héctor**, que explicará el mantenimiento del sistema."

---

## Preguntas probables

**"¿Por qué K-Means y no otro algoritmo de agrupamiento?"**
> "Por tres razones: es interpretable, porque cada grupo tiene un centroide que se lee
> como un perfil climático; la inferencia es muy barata en producción; y produce un número
> fijo de grupos, que es lo que necesita la aplicación para mapear a tres niveles."

**"¿Cómo asignan alto, medio y bajo si no hay etiquetas?"**
> "Es un paso posterior al entrenamiento: ordenamos los grupos por su temperatura media y
> el más frío es el de mayor riesgo. Es describir los grupos que el algoritmo encontró, no
> supervisarlo. El entrenamiento nunca ve esas etiquetas."

**"¿Un silueta de 0.419 es bueno?"**
> "Con datos reales y ruidosos, por encima de 0.4 se considera una estructura razonable.
> Partimos de 0.286 y llegamos ahí podando variables. Además la barrera de calidad exige
> un mínimo de 0.35, así que hay margen."

**"¿Por qué escalar las variables?"**
> "Porque K-Means usa distancias. Sin escalar, la altitud, que está en miles, dominaría
> por completo el cálculo y el modelo agruparía únicamente por altura."
