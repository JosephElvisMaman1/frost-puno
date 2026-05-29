# Comparacion de modelos FrostPuno v0.1.0 vs v0.2.0

## Resumen

FrostPuno mantiene `v0.1.0` como modelo activo en FastAPI. La version `v0.2.0` es experimental y se creo para corregir data leakage en la evaluacion academica sin romper produccion.

| Metrica | v0.1.0 | v0.2.0 |
|--------|--------|--------|
| Modelo registrado | RandomForestClassifier | RandomForestClassifier |
| Dataset | `frost_training_dataset.csv` | `frost_training_dataset_v2.csv` |
| Split | aleatorio estratificado | por distrito |
| Accuracy | 1.0000 | 0.5097 |
| Precision macro | 1.0000 | 0.4697 |
| Recall macro | 1.0000 | 0.4954 |
| F1 macro | 1.0000 | 0.4790 |

## Por que v0.1.0 obtiene 1.0

La version `v0.1.0` usa etiquetas rule-based: `riesgo_helada` se deriva principalmente de `temperatura_minima_diaria` y `horas_bajo_cero`. Esas mismas columnas tambien estaban dentro de las features de entrenamiento.

Eso permite que el modelo aprenda la regla que genero la etiqueta. La metrica perfecta valida que el pipeline reproduce la regla, pero no demuestra desempeno real ante eventos de helada observados.

## Que es data leakage

Data leakage ocurre cuando una feature contiene informacion que no estaria disponible de forma honesta al momento de predecir, o cuando revela directa o indirectamente la etiqueta.

En FrostPuno `v0.1.0`, las columnas filtradas son:

- `temperatura_minima_diaria`
- `horas_bajo_cero`

Ambas participan en la regla que crea `riesgo_helada`, por lo que inflan artificialmente la evaluacion.

## Que cambia en v0.2.0

La version `v0.2.0` crea un dataset nuevo sin sobrescribir el original:

- `data/processed/frost_training_dataset_v2.csv`

Features usadas:

- `latitud`
- `longitud`
- `altitud_estimada`
- `temperature_2m`
- `relative_humidity_2m`
- `apparent_temperature`
- `dew_point_2m`
- `precipitation`
- `cloud_cover`
- `wind_speed_10m`
- `mes`
- `hora`

La etiqueta sigue siendo `riesgo_helada`, por compatibilidad academica y reproducibilidad del MVP.

## Split mas realista

`v0.2.0` implementa dos estrategias:

- `district`: separa distritos completos entre train y test. Es la estrategia usada para el artefacto registrado.
- `time`: entrena con fechas iniciales y evalua con fechas mas recientes.

Split usado en el modelo registrado:

- train: Azangaro, Huancane, Ilave, Macusani, Moho, Puno, Putina, Sandia, Yunguyo
- test: Ayaviri, Juli, Juliaca, Lampa

Esto evita que datos del mismo distrito aparezcan en train y test al mismo tiempo.

## Por que bajan las metricas

Las metricas bajan porque el modelo ya no recibe las variables que revelaban la etiqueta. Ahora debe inferir el riesgo desde variables meteorologicas actuales y contexto geografico.

La matriz de confusion `v0.2.0` muestra errores reales de generalizacion:

| Real \\ Predicho | bajo | medio | alto |
|-----------------|------|-------|------|
| bajo | 287 | 82 | 15 |
| medio | 79 | 330 | 191 |
| alto | 103 | 189 | 68 |

Esto es mas honesto para el informe: permite discutir falsos positivos, falsos negativos y limites del MVP.

## Por que v0.2.0 es mas confiable

`v0.2.0` no es necesariamente mas preciso, pero si es mas confiable como evaluacion porque:

- elimina features derivadas de la etiqueta;
- evalua generalizacion a distritos no vistos;
- conserva trazabilidad de features, split y matriz de confusion;
- no reemplaza el modelo productivo hasta tener validacion externa.

La validacion definitiva requiere etiquetas independientes de eventos reales, por ejemplo estaciones SENAMHI, reportes de heladas o verificacion en campo.

## Produccion intacta

FastAPI sigue usando:

- `ml_pipeline/registry/frost_risk_model.joblib`
- `ml_pipeline/registry/model_metadata.json`

La version `v0.2.0` queda como artefacto experimental:

- `ml_pipeline/registry/frost_risk_model_v0_2_0.joblib`
- `ml_pipeline/registry/model_metadata_v0_2_0.json`
