# Guion — APAZA LLANOS, YOEL
## Resultados y limitaciones

Tiempo: 1:30. Hablas después de Héctor y antes del cierre de Joseph.

Secciones del paper: VIII (Resultados) y IX (Limitaciones).
Ten a la vista la **Tabla IV** (verificaciones) y la **Figura 5** (cliente en operación).

---

## 1. Resultados verificados (40 s)

*Muestra la Tabla IV del paper.*

> "Gracias Héctor. Yo presento los resultados y las limitaciones.
>
> El sistema está desplegado y operativo. Estas son las verificaciones:
>
> - **Doce pruebas** del servicio, satisfactorias.
> - **Seis pruebas** de mantenimiento, satisfactorias.
> - La barrera de calidad, **aprobada**, con una silueta de 0.419 frente a un mínimo
>   exigido de 0.35.
> - La compilación del cliente web, satisfactoria.
> - La aplicación Android, compilando, con 47.3 megabytes.
> - Y el modelo en producción es **K-Means versión uno punto cero**, lo que se puede
>   verificar consultando la interfaz de programación en vivo."

## 2. Lo que entrega la aplicación (25 s)

*Muestra la Figura 5.*

> "Del lado del usuario, la aplicación entrega: alerta diaria de helada con **umbral
> configurable**; un aviso **diferenciado para ganado**, porque las heladas afectan de
> forma distinta a las crías que a los cultivos; detección de eventos inusuales
> comparando con la climatología reciente; el agrupamiento territorial; un módulo
> estacional de chuño; e histórico climático.
>
> Incorpora además selección de idioma entre español e inglés."

## 3. Limitaciones (25 s)

> "Y ahora las limitaciones, que declaramos de forma explícita porque un trabajo honesto
> se sostiene mejor:
>
> - Los niveles de riesgo se derivan del **perfil térmico** de cada grupo, no de un
>   registro oficial de heladas observadas, porque ese conjunto etiquetado no existe para
>   estos distritos.
> - **SENAMHI** está declarado en el sistema como fuente oficial prioritaria, pero no
>   expone una interfaz pública estable, así que Open-Meteo es la fuente operativa real.
> - La semilla territorial es una **versión reducida** y debe reemplazarse por el export
>   oficial completo.
> - Los umbrales de chuño y ganado son **diseño documentado con fuentes**, no cifras
>   oficiales.
> - La detección de eventos inusuales usa climatología de treinta días, no una serie
>   multianual.
> - Y el plan gratuito de alojamiento suspende la instancia por inactividad, lo que
>   introduce demora en la primera solicitud.
>
> Ninguna de estas limitaciones invalida la arquitectura ni el paralelismo demostrados.
>
> Le devuelvo la palabra a **Joseph** para las conclusiones."

---

## Preguntas probables

**"¿Cómo saben que el modelo en producción es el que dicen?"**
> "Porque la interfaz de programación expone un punto de acceso de información del modelo
> que devuelve el nombre, la versión y las métricas del artefacto efectivamente cargado.
> Se puede consultar ahora mismo."

**"¿Por qué no usaron datos de SENAMHI?"**
> "Porque no hay una interfaz pública estable que se pueda consumir de forma
> automatizada. El sistema ya está preparado para priorizarla si se habilita, y usar
> Open-Meteo solo como respaldo."

**"¿47 megabytes no es mucho para una aplicación?"**
> "Es el tamaño habitual de una compilación de Flutter sin optimizaciones adicionales de
> distribución. Se puede reducir generando paquetes por arquitectura."

**"¿Qué pasa si el usuario abre la app y el servicio está dormido?"**
> "La primera solicitud tarda unos segundos mientras el servicio despierta. La aplicación
> maneja ese caso mostrando un estado degradado en lugar de fallar."
