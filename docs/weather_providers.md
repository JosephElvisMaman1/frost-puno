# FrostPuno - proveedores climaticos

FrostPuno usa una arquitectura desacoplada para consultar clima sin atar la prediccion a una sola fuente.

```text
WeatherProvider
├── SenamhiProvider
├── OpenMeteoProvider
└── HybridWeatherProvider
```

## SENAMHI

SENAMHI es la fuente oficial peruana prioritaria para validacion meteorologica, estaciones, avisos y datos hidrometeorologicos. En esta version se incluye un `SenamhiProvider` preparado para ubicar estacion de referencia cercana, exponer distancia a estacion, permitir una futura integracion por descarga oficial/API autenticada/ETL documentado y fallar de forma segura sin romper la prediccion.

No se afirma que exista una API publica estable y anonima para consumo directo del MVP. Por eso, cuando SENAMHI no entrega datos operativos, el sistema usa Open-Meteo como fallback.

## Open-Meteo

`OpenMeteoProvider` consulta clima actual por coordenadas y obtiene temperatura, humedad relativa, sensacion termica, punto de rocio, precipitacion, nubosidad y velocidad de viento.

## HybridWeatherProvider

1. intenta SENAMHI;
2. si no hay datos oficiales disponibles, usa Open-Meteo;
3. cachea resultado por coordenadas redondeadas;
4. devuelve limitaciones y si se uso fallback.

## Contrato API

```text
GET /weather/current?latitude=-15.8402&longitude=-70.0219
```

## Features futuras para ML

- temperatura minima oficial;
- humedad oficial;
- velocidad de viento oficial;
- nubosidad;
- estacion cercana;
- distancia a estacion;
- altitud real;
- sensacion termica;
- presion atmosferica;
- radiacion.

Estos campos no deben incorporarse al modelo productivo sin validacion, limpieza, versionamiento de dataset y comparacion contra el modelo activo.
