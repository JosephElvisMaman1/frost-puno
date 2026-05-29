# Frost Puno - Gobierno del modelo

## Principio

El modelo no se actualiza solo por existir un entrenamiento nuevo. Debe pasar validacion de datos, evaluacion y un quality gate.

## Ciclo de mejora continua

```text
datos nuevos
  -> validacion
  -> entrenamiento
  -> evaluacion
  -> quality gate
  -> versionamiento
  -> despliegue controlado
```

## Versionamiento

Cada version debe registrar:

- nombre del modelo;
- algoritmo;
- fecha de creacion;
- features;
- variable objetivo;
- metricas;
- tamano de dataset;
- fuentes de datos;
- limitaciones.

En el MVP esto se guarda en `ml_pipeline/registry/model_metadata.json`.

## Quality gate

El script `ml_pipeline/registry/check_model_quality.py` lee `f1_macro` y lo compara contra `MIN_F1_MACRO`.

Resultado:

- exit code `0`: el modelo cumple el minimo;
- exit code `1`: el modelo falla o el metadata es invalido.

## Comparacion futura contra modelo activo

La siguiente fase debe comparar el modelo candidato contra el modelo activo previo:

- bloquear si `f1_macro` baja mas de un margen permitido;
- bloquear si aumenta demasiado la tasa de falsos negativos para riesgo alto;
- registrar si el dataset cambio de fuente, rango temporal o cobertura territorial.

## Limitacion academica del MVP

Las etiquetas iniciales son reglas basadas en temperatura minima y horas bajo cero. Por eso las metricas pueden ser optimistas. Para un modelo productivo se debe validar con SENAMHI y evidencia de campo.
