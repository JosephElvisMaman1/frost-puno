# FrostPuno - Limitaciones del MVP ML

## Datos territoriales

`data/external/inei_puno_districts.csv` es una semilla curada inicial para poder ejecutar el pipeline. No reemplaza una descarga completa y auditada desde INEI EstaDist, CPV 2017 o CENAGRO.

Accion requerida antes de produccion:

- exportar datos oficiales por distrito desde INEI;
- reemplazar poblacion total, poblacion rural y porcentaje rural;
- agregar centros poblados y variables agropecuarias reales.

## Etiquetas

`riesgo_helada` se etiqueta con reglas termicas iniciales. Esto permite entrenar un primer modelo, pero no representa una verdad observada de dano agricola.

Mejora implementada:

- se agrego `data/validation/senamhi_frost_observations_sample.csv` como contrato de observaciones externas;
- se agrego `ml_pipeline/evaluation/evaluate_observed_events.py` para evaluar modelos contra etiquetas observadas;
- se agrego `supabase/migrations/002_add_feedback_and_observations.sql` para guardar feedback y observaciones oficiales.

Accion requerida antes de produccion:

- validar contra estaciones SENAMHI;
- cruzar con avisos oficiales de heladas;
- incorporar reportes de productores o validacion de campo.

## Modelo v0.1.0

El dataset incluye `temperatura_minima_diaria` y `horas_bajo_cero`, variables usadas para crear la etiqueta. Esto puede inflar las metricas del modelo. Es aceptable como baseline academico inicial, pero debe explicarse en la exposicion.

Mejora implementada:

- `v0.2.0` elimina esas columnas como features;
- usa split por distrito;
- genera matriz de confusion y metricas realistas;
- no reemplaza el modelo productivo hasta tener validacion externa.

## Infraestructura

El pipeline esta pensado para una laptop ASUS A16 con 16 GB RAM y Ryzen 7. Se evita deep learning y se prioriza Scikit-learn.

## Cobertura geografica

La primera version usa distritos seleccionados de Puno. El escalamiento debe incorporar todos los distritos y centros poblados relevantes.
