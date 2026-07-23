# Model Card - FrostPuno Frost Risk MVP

> **Migración a no supervisado:** el modelo productivo es ahora K-Means (clustering),
> evaluado con silhouette / Davies-Bouldin. Ver `docs/clustering_model.md`. Lo descrito
> abajo corresponde al clasificador supervisado previo, conservado como referencia legacy.

## Modelo

Clasificador supervisado tabular para riesgo de helada:

- clases: `bajo`, `medio`, `alto`;
- modelo registrado: mejor candidato por `f1_macro`;
- candidatos: LogisticRegression, DecisionTreeClassifier, RandomForestClassifier.

## Entrada

Variables numericas usadas en la version inicial:

- ubicacion: latitud, longitud, altitud estimada;
- contexto: poblacion total, poblacion rural, porcentaje rural;
- clima horario: temperatura, humedad relativa, sensacion termica, punto de rocio, precipitacion, nubosidad, viento;
- tiempo: mes, hora;
- agregados diarios: temperatura minima diaria, horas bajo cero.

## Salida

Clase de riesgo:

- `bajo`
- `medio`
- `alto`

## Objetivo previsto

Demo academica y prototipo MVP para apoyar alertas tempranas y recomendaciones de produccion de chuno en comunidades altoandinas de Puno.

## Datos

- Open-Meteo Historical API para clima horario.
- CSV territorial inicial compatible con INEI para distritos seleccionados de Puno.
- SENAMHI y MIDAGRI/SIEA documentados para integracion posterior.

## Metricas

La metrica principal es `f1_macro` porque las clases pueden estar desbalanceadas.

Metricas secundarias:

- accuracy;
- precision macro;
- recall macro;
- matriz de confusion.

## Uso responsable

El modelo no debe usarse como unico criterio para decisiones agricolas reales. En produccion debe validarse con SENAMHI, observaciones locales y usuarios de campo.
