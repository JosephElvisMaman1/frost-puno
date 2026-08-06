# Guion — MAMANI MENDOZA, JOSEPH ELVIS
## Apertura, arquitectura distribuida y cierre

Intervienes dos veces: abres (2:30) y cierras (1:00). Desarrollaste el sistema, por lo
que también respondes las preguntas técnicas de código y modelo.

Secciones del paper: I (Introducción), III (Arquitectura distribuida), X (Conclusiones).

---

## PARTE 1 — Apertura (2:30)

### 1.1 Presentación (20 s)

> "Buenas tardes. Presentamos el trabajo **FrostPuno: arquitectura distribuida y cómputo
> paralelo para la predicción de heladas mediante aprendizaje no supervisado en el
> altiplano de Puno**.
>
> El equipo lo integramos Yimmy Pari, Jahan Quispe, Héctor Flores, Yoel Apaza y yo,
> Joseph Mamani."

### 1.2 El problema (50 s)

> "En la región Puno, por encima de los tres mil ochocientos metros, las heladas tienen
> una doble condición.
>
> Por un lado **destruyen**: dañan los cultivos y provocan mortalidad neonatal en crías
> de alpaca y ovino, que son el patrimonio productivo de las familias altoandinas.
>
> Por otro lado son **necesarias**: constituyen el insumo del chuño, la papa deshidratada
> por congelamiento nocturno y secado diurno que se conserva durante años y forma parte
> de la seguridad alimentaria de la región.
>
> El problema es que la decisión de proteger un cultivo, resguardar el ganado o tender la
> papa se toma por experiencia empírica, sin información climática integrada. *(pausa)*
>
> Y no es solo un problema de modelado: exige recolectar datos de múltiples ubicaciones,
> servirlos con baja latencia a usuarios dispersos y mantener el sistema operativo sin
> intervención constante. Ahí es donde entra el cómputo paralelo y distribuido."

### 1.3 Las tres contribuciones (30 s)

> "El paper declara tres contribuciones:
>
> **Primera**, una estrategia de ingesta paralela por hilos con aislamiento de fallos por
> ubicación.
>
> **Segunda**, una arquitectura distribuida en cuatro servicios autónomos, desplegados en
> proveedores distintos.
>
> **Tercera**, un esquema de mantenimiento automatizado del componente inteligente,
> ejecutado como trabajos concurrentes y protegido por una barrera de calidad."

### 1.4 Arquitectura distribuida (50 s)

*Muestra la tabla I del paper.*

> "La arquitectura tiene cuatro componentes y cada uno reside en una plataforma distinta,
> de modo que la distribución es efectiva y no una separación lógica dentro de un mismo
> proceso:
>
> - El **cliente Flutter**, en Vercel y como aplicación Android.
> - El **servicio FastAPI**, en Render, que hace la inferencia.
> - La **base de datos**, en Supabase.
> - Y la **fuente climática**, Open-Meteo, que es externa.
>
> El desacoplamiento se sostiene en dos decisiones. La primera: el cliente conoce
> únicamente la dirección del servicio, inyectada al compilar, por lo que el mismo código
> fuente produce la versión web y la aplicación Android. La segunda: el servicio organiza
> su código en capas de rutas, servicios y repositorios, lo que permite sustituir la
> persistencia sin tocar los controladores.
>
> Le paso la palabra a **Yimmy**, que explicará el paralelismo en la ingesta."

---

## PARTE 2 — Cierre (1:00)

### 2.1 Conclusiones (45 s)

> "Para cerrar. Presentamos un sistema distribuido para la predicción de heladas,
> desplegado en producción y accesible como aplicación web, interfaz de programación y
> aplicación Android.
>
> Desde la perspectiva del cómputo paralelo y distribuido, el trabajo aporta tres
> elementos: la ingesta se paraleliza con un conjunto de hilos con aislamiento de fallos;
> la arquitectura se distribuye en cuatro servicios autónomos acoplados solo por contratos
> explícitos, entre los que destaca la lista de características que separa el subsistema
> de aprendizaje del de servicio; y el mantenimiento se automatiza como trabajos
> concurrentes con una barrera de calidad verificada por pruebas.
>
> El modelo alcanza una silueta de 0.419 y produce una clasificación territorial coherente
> con la geografía regional sin haber sido programada explícitamente."

### 2.2 Trabajo futuro y agradecimiento (15 s)

> "Como trabajo futuro planteamos incorporar observaciones oficiales como validación
> cruzada, ampliar la cobertura territorial y evolucionar la ingesta paralela hacia un
> esquema distribuido en varios nodos.
>
> El código fuente completo está disponible de forma pública en el repositorio. Muchas
> gracias, quedamos atentos a sus preguntas."

---

## Preguntas que respondes tú

**"¿Por qué no usaron aprendizaje supervisado?"**
> "Porque no existe un registro etiquetado de heladas observadas por distrito. Un modelo
> supervisado tendría que inventar las etiquetas con reglas, que es justo lo que
> queríamos evitar. El agrupamiento descubre la estructura sin necesitar etiquetas."

**"¿Esto funciona o es una maqueta?"**
> "Está en producción. La API responde en frost-puno.onrender.com y la aplicación web en
> frost-puno.vercel.app. Podemos abrirlas ahora mismo."

**"¿Dónde está el aporte de cómputo paralelo?"**
> "En tres lugares: la ingesta con pool de hilos, la arquitectura distribuida en cuatro
> proveedores, y los cinco flujos de integración continua que corren concurrentemente.
> Están detallados en las secciones IV, III y VII del paper."

**"¿Por qué el contrato de características es importante?"**
> "Porque separa el subsistema de aprendizaje del de servicio. El backend arma el vector
> siguiendo la lista declarada en los metadatos del modelo, así que reentrenar no obliga
> a modificar el código del servidor. Es la frontera del sistema."
