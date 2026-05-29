# Frost Puno - guion breve de exposicion

## 1. Apertura

Presentar Frost Puno como un MVP academico para predecir riesgo de heladas en comunidades altoandinas de Puno y apoyar decisiones relacionadas con cultivos y produccion de chuno.

## 2. Demo de la aplicacion

1. Abrir Flutter Web.
2. Mostrar la pantalla Home y el estado del sistema.
3. Explicar que Flutter no se conecta directamente a Supabase; toda comunicacion pasa por FastAPI.
4. Entrar a `Consultar riesgo`.
5. Mostrar los datos demo precargados de ubicacion y clima.
6. Enviar la prediccion.
7. Mostrar el resultado con riesgo alto, confianza, recomendacion y condiciones para chuno.
8. Abrir `Informacion del modelo` y mostrar version, metricas y fuentes.
9. Abrir `Historial` y explicar que se llena desde Supabase cuando `ENABLE_SUPABASE=true`.
10. Abrir `Fuentes` y explicar Open-Meteo, INEI, SENAMHI y MIDAGRI/SIEA.

## 3. Aprendizaje de Maquina

Explicar que el problema se formulo como clasificacion supervisada multiclase:

- Variable objetivo: `riesgo_helada`.
- Clases: `bajo`, `medio`, `alto`.
- Modelos comparados: Logistic Regression, Decision Tree y Random Forest.
- Metrica principal: `f1-score macro`.
- Limitacion: las etiquetas iniciales son basadas en reglas y deben validarse con datos oficiales y de campo.

## 4. Computacion Paralela y Distribuida

Explicar:

- La ingesta climatica puede ejecutarse por distritos o centros poblados.
- Open-Meteo se consulta en paralelo usando `max-workers`.
- El backend separa responsabilidades en servicios y repositorios.
- CI/CD ejecuta jobs independientes para backend, datos, ML y Flutter.
- La arquitectura puede evolucionar a microservicios reales si crece la carga.

## 5. CI/CD y mejora continua

Mostrar GitHub Actions:

- Backend tests.
- Data validation.
- ML training.
- Model quality gate.
- Flutter build.

Explicar el ciclo:

```text
datos nuevos -> validacion -> entrenamiento -> evaluacion -> quality gate -> versionamiento -> despliegue controlado
```

## 6. Cierre

Concluir que Frost Puno integra datos abiertos, ML, backend modular, base de datos y CI/CD en un MVP defendible para ambos cursos, manteniendo claras sus limitaciones y su ruta de mejora.
