# Guion — JUAN ARTEMIO LIPE MACHACA
## Rol: Dataset y fuentes de datos

**Tiempo: ~1:30** — Hablas después de Joseph (apertura) y antes de Joseph (el modelo).
Tu parte prepara el terreno: **con qué datos se entrena**. El modelo en sí lo explica
Joseph, que lo desarrolló.

**Repositorio:** https://github.com/JosephElvisMaman1/frost-puno

**Ten abierto:** `data/processed/frost_training_dataset.csv` y `ml_pipeline/config.py`.

---

## 1. De dónde salen los datos (40 s)

> "Gracias Joseph. Yo explico con qué datos se entrena el sistema.
>
> La fuente climática es **Open-Meteo**, una API abierta. De ahí traemos series **horarias**
> para **13 distritos de Puno**, lo que nos da **4 368 registros**.
>
> La información territorial —latitud, longitud y altitud de cada distrito— viene de una
> semilla compatible con **INEI**.
>
> **SENAMHI** es la fuente oficial peruana y la tenemos declarada como prioritaria en el
> sistema, pero no expone una API pública estable, así que Open-Meteo es la fuente
> operativa real. Eso está documentado en la app y en el informe, no lo escondemos."

## 2. El dataset como feature store (30 s)

> "Algo que el enunciado pide explícitamente es el **almacenamiento de características**.
>
> Nuestro dataset de features está **versionado dentro del repositorio** y se **valida en
> cada integración continua**: si alguien cambia los datos y rompen la estructura, el
> pipeline lo detecta. Funciona como el *feature store* del proyecto.
>
> Además, la ingesta no es secuencial: descarga el clima de los 13 distritos **en paralelo**
> con un pool de hilos, y si un distrito falla, los demás continúan."

## 3. Paso al modelo (20 s)

> "Sobre esos 4 368 registros se entrena el modelo. Y ahí hay una decisión importante que
> cambió mucho el resultado: **no usamos todas las variables**.
>
> Le devuelvo la palabra a **Joseph**, que desarrolló el modelo y les va a explicar por qué
> y cómo se entrena."

---

## Preguntas probables

**"¿Por qué solo 13 distritos?"**
> "Es el alcance del MVP: distritos representativos de la región, con altitudes desde 2 170
> hasta 4 315 metros, para cubrir el rango térmico. La semilla territorial se puede
> reemplazar por el export oficial completo del INEI sin tocar el código."

**"¿Por qué no usan datos de SENAMHI directamente?"**
> "Porque no hay una API pública estable que podamos consumir de forma automatizada. Está
> declarado en el sistema como fuente prioritaria: si mañana se habilita, el proveedor de
> clima ya está preparado para usarla y caer a Open-Meteo solo como respaldo."

**"¿4 368 registros no son pocos?"**
> "Para clustering es suficiente para encontrar estructura estable, y el modelo tiene un
> reentrenamiento adaptativo que amplía la ventana de datos si la calidad baja. Eso lo
> explica Paul en la parte de mantenimiento."

> Si la pregunta baja al modelo, los hiperparámetros o el código, **la responde Joseph**.
