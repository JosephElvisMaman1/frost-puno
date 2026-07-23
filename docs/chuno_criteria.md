# Criterios de dominio para el módulo de chuño

Umbrales usados por el módulo estacional de chuño (`/chuno/window` en el backend y la pantalla `chuno/` en Flutter). Son valores **aproximados pero defendibles** para un MVP académico, derivados de las fuentes citadas. Reusar estos números; no inventar otros.

## Temporada

- Producción tradicional en la **estación seca fría**: **mayo–agosto**, núcleo **junio–julio**.
- Requiere altitud alta (> ~3800 m), condición que cumplen los distritos del altiplano de Puno.
- Fuera de mayo–agosto el módulo se marca como **inactivo** (no se evalúan ventanas).

## Congelamiento nocturno (fase de congelado del tubérculo)

| Parámetro | Umbral MVP | Variable Open-Meteo |
|---|---|---|
| Temperatura mínima nocturna | `≤ −5 °C` (excelente `≤ −8 °C`) | `temperature_2m_min` |
| Noches consecutivas | `≥ 3` | — |

Años fuertes de chuño registran noches de −11 a −15 °C.

## Secado diurno (deshidratación por sol y aire seco)

| Parámetro | Umbral MVP | Variable Open-Meteo |
|---|---|---|
| Nubosidad | `≤ 40 %` | `cloud_cover` (mean diurno) |
| Humedad relativa | `≤ 60 %` | `relative_humidity_2m` |
| Precipitación | `≤ 0.2 mm` (sin lluvia) | `precipitation` / `precipitation_sum` |

## Regla MVP de "buen día de chuño"

Un día cuenta como bueno si cumple **todas** las condiciones:

```
temperature_2m_min ≤ −5 °C
precipitation       ≤ 0.2 mm
cloud_cover         ≤ 40 %
relative_humidity   ≤ 60 %
```

**Ventana óptima** = `≥ 3` días consecutivos que cumplen la regla (coincide con el ciclo núcleo de ~3 noches de congelamiento del chuño negro).

### Escalado por niveles (opcional para la UI)

- **Excelente**: `temp_min ≤ −8`, `cloud_cover ≤ 20`, `humedad ≤ 50`, `precip = 0`.
- **Bueno**: umbrales base de arriba.
- **Marginal**: `−5 < temp_min ≤ −2` o `cloud_cover 40–60` (congela débil o seca lento).
- **No apto**: `temp_min > −2` o `precip > 1 mm`.

## Ciclo completo (contexto)

- Chuño negro: ~5 días de fase congelado/secado + ~1 semana de pisado/procesado → **1–2 semanas**.
- Chuño blanco (tunta/moraya): añade remojo en agua ~20–30 días + secado final 5–8 días → **~1 mes**.
- El MVP modela el chuño negro (ciclo núcleo ~3 noches de congelamiento).

## Fuentes

- FAO Mountain Partnership — Chuño Blanco: https://www.fao.org/mountain-partnership/projects/mountain-partnership-products-initiative/chu%C3%B1o-blanco/en
- Wikipedia — Chuño: https://en.wikipedia.org/wiki/Chu%C3%B1o
- La República — "Altiplano, una fábrica de frío...": https://larepublica.pe/sociedad/2021/07/18/altiplano-una-fabrica-de-frio-que-produce-chuno-y-helado-de-oca-lrsd
- La República — "En Puno la helada es indispensable...": https://larepublica.pe/sociedad/2020/07/06/en-puno-la-helada-es-indispensable-para-la-supervivencia-lrsd
- Diario Correo — "Heladas favorecen la producción de chuño y tunta en Puno": https://diariocorreo.pe/edicion/puno/heladas-favorecen-la-produccion-de-chuno-y-tunta-en-puno-820187/
- LEISA-AL — "Chuño blanco, tunta o moraya": https://leisa-al.org/web/revista/volumen-20-numero-03/chuno-blanco-tunta-o-moraya-un-proceso-natural-de-conservacion/

> Nota: los umbrales de −5 °C y 3 noches provienen directamente de las fuentes; los cortes numéricos de humedad y nubosidad son una operacionalización razonable de la descripción cualitativa ("sol intenso, aire seco, sin lluvia") — decisión de diseño del MVP, no cifras citadas.
