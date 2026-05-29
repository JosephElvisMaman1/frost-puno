# FrostPuno - Fuentes de datos

## INEI

Uso en el proyecto: contexto territorial, censal, rural y agropecuario. INEI no se usa como fuente principal de clima.

Fuentes priorizadas:

- EstaDist: indicadores por distrito, centros poblados, mapas y datos tabulares. Fuente: https://www.gob.pe/institucion/inei/pages/27392-consultar-datos-en-el-sistema-de-informacion-distrital-del-inei
- Censos Nacionales 2017 / Redatam: poblacion, area urbana/rural y variables censales. Fuente: https://www.gob.pe/institucion/inei/pages/24120-consultar-base-de-datos-de-los-censos-nacionales-2017-redatam
- Microdatos INEI: encuestas, documentacion y bases descargables. Fuente: https://www.gob.pe/institucion/inei/pages/14307-consultar-bases-de-datos-del-inei
- ENA/CENAGRO: caracterizacion agropecuaria y estructura del sector agrario.

Archivo MVP:

- `data/external/inei_puno_districts.csv`

Este archivo es una semilla curada inicial para ejecutar el pipeline. Sus nombres y ubigeos siguen la estructura administrativa de INEI, pero debe reemplazarse por una exportacion completa de EstaDist/CPV 2017 antes de produccion. La columna `source_note` mantiene esta advertencia dentro del propio dataset.

## Open-Meteo

Uso en el MVP: fuente principal de clima por coordenadas.

API usada:

- Historical Weather API: https://open-meteo.com/en/docs/historical-weather-api
- Endpoint: `https://archive-api.open-meteo.com/v1/archive`

Variables horarias:

- `temperature_2m`
- `relative_humidity_2m`
- `apparent_temperature`
- `dew_point_2m`
- `precipitation`
- `cloud_cover`
- `wind_speed_10m`

## SENAMHI

Uso planificado: validacion oficial, estaciones meteorologicas, temperatura minima/maxima, precipitacion, avisos de heladas/friajes.

Fuente: https://www.senamhi.gob.pe/site/descarga-datos/?p=sedes

Fase 2:

- cruzar predicciones con estaciones cercanas;
- usar avisos de helada como evidencia externa;
- mejorar etiquetas generadas por reglas.

## MIDAGRI/SIEA

Uso planificado: contexto productivo agricola, superficie sembrada/cosechada, rendimiento y cultivos relevantes de Puno.

Fuente de referencia: https://www.gob.pe/institucion/midagri/informes-publicaciones/2730325-compendio-anual-de-produccion-agricola

Fase 2:

- enriquecer `cultivo_relevante`;
- ponderar riesgo por exposicion productiva;
- ajustar recomendaciones para papa, quinua y forrajes altoandinos.
