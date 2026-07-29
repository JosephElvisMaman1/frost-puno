# Guion — JUAN ARTEMIO LIPE MACHACA
## Rol: Dataset, modelo de Machine Learning e hiperparámetros

**Tiempo: ~3 min** — Es la sección con más puntaje (3 pts de "Entrenamiento del modelo").
Hablas después de Joseph.

**Repositorio:** https://github.com/JosephElvisMaman1/frost-puno

**Archivos que debes tener abiertos:**
- `ml_pipeline/clustering/train_clusters.py`
- `ml_pipeline/registry/cluster_metadata.json`
- `data/processed/district_clusters.csv`

---

## 1. El dataset (35 s)

> "Gracias Joseph. Yo voy a explicar el dataset y el modelo.
>
> Los datos vienen de **Open-Meteo**, una API abierta de clima. Ingestamos series horarias
> para **13 distritos de Puno**, lo que nos da **4 368 registros**. La información territorial
> —latitud, longitud y altitud de cada distrito— viene de una semilla compatible con INEI.
>
> Ese dataset está **versionado en el repositorio** y se valida en cada integración: funciona
> como nuestro *feature store*, que es uno de los elementos que pide el enunciado."

## 2. Selección de características — *el hallazgo más interesante* (45 s)

> "Empezamos con **ocho variables** climáticas. Pero al medir la calidad del agrupamiento
> vimos algo importante: la **precipitación**, el **viento**, la **nubosidad** y la
> **temperatura aparente** eran ruidosas o estaban correlacionadas con otras, y en vez de
> ayudar, **degradaban la separación** de los grupos.
>
> Hicimos un experimento de subconjuntos y nos quedamos con las **cuatro variables con sentido
> físico** para una helada: **altitud, temperatura, punto de rocío y humedad relativa**.
>
> El resultado fue claro: la métrica de calidad subió de **0.286 a 0.419**, casi un **47 % de
> mejora**, simplemente quitando variables. Es un buen recordatorio de que más datos no
> siempre significa mejor modelo."

## 3. El modelo y los hiperparámetros optimizados (60 s)

*Muestra `train_clusters.py`, función `search_hyperparameters`.*

> "El modelo es **K-Means**, un algoritmo de **aprendizaje no supervisado**: no le damos
> etiquetas, él descubre solo la estructura de los datos.
>
> Va dentro de un *pipeline* con **StandardScaler**, porque las variables tienen escalas muy
> distintas: metros de altitud contra grados centígrados contra porcentaje de humedad. Sin
> escalar, la altitud dominaría todo el cálculo de distancias.
>
> Para los **hiperparámetros** no elegimos valores a mano: hacemos un **grid search de 24
> combinaciones**, maximizando la métrica de silhouette:
>
> - **k**, el número de grupos: probamos de 3 a 8.
> - **init**, el método de inicialización: k-means++ y aleatorio.
> - **n_init**, cuántas veces reinicia: 10 y 25.
> - Con `random_state` fijo en 42 para que sea **reproducible**.
>
> La configuración ganadora fue **k igual a 3, init aleatorio y n_init diez**. Y algo
> importante para la auditoría: **el grid completo, con las 24 combinaciones y sus métricas,
> queda guardado** en el archivo de metadata del modelo. No es una afirmación nuestra: está
> registrado y se puede revisar."

## 4. Evaluación (40 s)

> "¿Cómo evaluamos un modelo que no tiene etiquetas? No podemos usar accuracy ni F1, porque
> **no existe una verdad de terreno** de 'aquí hubo helada' para estos distritos.
>
> Usamos métricas propias del clustering:
>
> - **Silhouette: 0.419** — mide qué tan cohesionado está cada grupo y qué tan separado está
>   de los demás. Más alto es mejor.
> - **Davies-Bouldin: 0.813** — compara la dispersión dentro del grupo contra la distancia
>   entre grupos. Más bajo es mejor.
>
> Elegimos k igual a 3 porque **gana en ambas métricas**, y además coincide con los tres
> niveles de riesgo que necesita la aplicación: alto, medio y bajo."

## 5. El resultado es interpretable (30 s)

*Muestra `district_clusters.csv`.*

> "Y esto es lo que más nos gustó del resultado. El modelo encontró tres regímenes:
>
> - Un grupo **frío**, con temperatura media de 4 grados y altitud de 3 900 metros.
> - Un grupo **intermedio**, a 11 grados.
> - Y un grupo **templado**, a 13 grados y solo 2 170 metros.
>
> Al mapear los distritos: **Macusani** —a 4 315 metros— **Juliaca y Huancané** caen en riesgo
> alto. **Sandia**, que está en valle a 2 170 metros, cae en riesgo bajo.
>
> Nadie escribió esa regla. El algoritmo la descubrió solo a partir del clima, y coincide con
> el conocimiento geográfico de la región. Eso nos da confianza en que el agrupamiento tiene
> sentido físico.
>
> Le paso la palabra a Jhoel para la demostración de la aplicación."

---

## Preguntas probables

**"¿Por qué silhouette 0.419 y no más alto?"**
> "En clustering, un silhouette por encima de 0.4 se considera una estructura razonable con
> datos reales y ruidosos. Partimos de 0.286 y llegamos a 0.419 podando variables. Además el
> quality gate exige mínimo 0.35, así que hay margen de seguridad."

**"¿Por qué K-Means y no DBSCAN o jerárquico?"**
> "K-Means es interpretable —cada grupo tiene un centroide que podemos leer como un perfil
> climático—, es rápido para inferencia en producción, y produce un número fijo de grupos,
> que es lo que necesita la app para mapear a tres niveles de riesgo."

**"¿Cómo asignan alto/medio/bajo si no hay etiquetas?"**
> "Es un paso posterior al entrenamiento: ordenamos los grupos por su temperatura media y el
> más frío es el de mayor riesgo. Es *describir* los grupos que el algoritmo encontró, no
> supervisarlo. El entrenamiento nunca ve esas etiquetas."
